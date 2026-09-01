local M = {}

local poll_interval_ms = 15
local paste_timeout_ms = 2000
local paste_in_progress = false

local function run(args)
  local result = vim.system(args, { text = true }):wait()
  if result.code == 0 then
    return result.stdout or ""
  end

  local stderr = vim.trim(result.stderr or "")
  if stderr == "" then
    stderr = "exit code " .. result.code
  end
  return nil, stderr
end

local function fail(message)
  vim.notify_once("Clipboard: " .. message, vim.log.levels.WARN)
  return { {}, "v" }
end

local function buffer_names()
  local stdout, err = run({ "tmux", "list-buffers", "-F", "#{buffer_name}" })
  if not stdout then
    return nil, err
  end

  local names = {}
  for name in stdout:gmatch("[^\r\n]+") do
    names[#names + 1] = name
  end
  return names
end

local function clipboard_lines(stdout)
  -- Match systemlist(), which Neovim's built-in tmux provider uses: the
  -- command separator is not clipboard data, but embedded newlines are.
  if stdout == "" then
    return {}
  end
  if stdout:sub(-1) == "\n" then
    stdout = stdout:sub(1, -2)
  end
  return vim.split(stdout, "\n", { plain = true })
end

local function read_tmux_clipboard()
  local client, client_err = run({ "tmux", "display-message", "-p", "#{client_name}" })
  if not client then
    return fail("could not identify the tmux client: " .. client_err)
  end
  client = vim.trim(client)
  if client == "" then
    return fail("could not identify the tmux client")
  end

  local before, list_err = buffer_names()
  if not before then
    return fail("could not list tmux buffers: " .. list_err)
  end
  local existing = {}
  for _, name in ipairs(before) do
    existing[name] = true
  end

  local _, refresh_err = run({ "tmux", "refresh-client", "-l", "-t", client })
  if refresh_err then
    return fail("could not request the terminal clipboard: " .. refresh_err)
  end

  local new_buffer
  local poll_err
  local received, wait_reason = vim.wait(paste_timeout_ms, function()
    local current, err = buffer_names()
    if not current then
      poll_err = err
      return true
    end

    -- tmux lists the newest paste buffer first. The first name that was not
    -- present before refresh-client is the OSC 52 reply, even when its text is
    -- empty or identical to the previous clipboard contents.
    for _, name in ipairs(current) do
      if not existing[name] then
        new_buffer = name
        return true
      end
    end
    return false
  end, poll_interval_ms)

  if poll_err then
    return fail("lost access to tmux buffers while waiting: " .. poll_err)
  end
  if not received or not new_buffer then
    local reason = wait_reason == -2 and "clipboard request was interrupted" or "terminal clipboard reply timed out"
    return fail(reason)
  end

  local stdout, save_err = run({ "tmux", "save-buffer", "-b", new_buffer, "-" })
  if not stdout then
    return fail("could not read the terminal clipboard: " .. save_err)
  end
  return { clipboard_lines(stdout), "v" }
end

local function paste()
  if paste_in_progress then
    return fail("a clipboard read is already in progress")
  end

  paste_in_progress = true
  local ok, result = pcall(read_tmux_clipboard)
  paste_in_progress = false

  if not ok then
    return fail("unexpected tmux provider error: " .. tostring(result))
  end
  return result
end

function M.setup()
  if not (vim.env.SSH_TTY or vim.env.SSH_CONNECTION) then
    return
  end

  if not vim.env.TMUX then
    vim.g.clipboard = "osc52"
    return
  end

  vim.g.clipboard = {
    name = "tmux OSC 52 (synchronized)",
    copy = {
      ["+"] = { "tmux", "load-buffer", "-w", "-" },
      ["*"] = { "tmux", "load-buffer", "-w", "-" },
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
    cache_enabled = 0,
  }
end

return M
