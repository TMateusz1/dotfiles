local group = vim.api.nvim_create_augroup("user", { clear = true })
local function au(event, opts)
  vim.api.nvim_create_autocmd(event, vim.tbl_extend("force", { group = group }, opts))
end

-- Relative numbers in normal mode, absolute in insert mode.
au("InsertEnter", {
  callback = function()
    if vim.wo.number and vim.bo.buftype == "" then
      vim.wo.relativenumber = false
    end
  end,
})
au({ "InsertLeave", "FocusGained", "BufEnter" }, {
  callback = function()
    if vim.g.relativenumber ~= false and vim.wo.number and vim.bo.buftype == "" and vim.fn.mode() ~= "i" then
      vim.wo.relativenumber = true
    end
  end,
})

au("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

au("BufReadPost", {
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    if ft == "gitcommit" or ft == "gitrebase" or vim.b[ev.buf].last_loc_restored then
      return
    end
    vim.b[ev.buf].last_loc_restored = true
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

au("FileType", {
  pattern = {
    "help",
    "qf",
    "man",
    "lspinfo",
    "checkhealth",
    "snacks_notif",
    "grug-far",
    "gitsigns-blame",
    "dbout",
    "nvim-undotree",
  },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true, desc = "Close" })
  end,
})

au("BufWritePre", {
  callback = function(ev)
    if ev.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(ev.match) or ev.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Zellij lock follows nvim's focus; leaving via Ctrl+arrows syncs from the smart-splits keymaps.
if vim.env.ZELLIJ then
  local zellij = require("config.zellij")
  au({ "VimEnter", "FocusGained", "FocusLost", "VimResume" }, { callback = zellij.sync })
  au("VimSuspend", {
    callback = function()
      zellij.mode("normal")
    end,
  })
  au("VimLeave", {
    callback = function()
      zellij.stop()
      zellij.mode("normal"):wait(500)
    end,
  })
end

-- Zellij pane resizes resize the whole nvim UI.
au("VimResized", {
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. tab)
  end,
})

au({ "FocusGained", "TermClose", "TermLeave" }, {
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

au("FileType", {
  pattern = { "gitcommit", "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- `nvim <dir>`: explorer on the left, dashboard on the right.
au("VimEnter", {
  callback = function()
    local argv = vim.fn.argv()
    if #argv ~= 1 or vim.fn.isdirectory(argv[1]) == 0 then
      return
    end
    vim.cmd.cd(vim.fn.fnamemodify(argv[1], ":p"))
    -- snacks' netrw replacement has already opened the explorer and emptied this buffer.
    local main = vim.iter(vim.api.nvim_tabpage_list_wins(0)):find(function(win)
      return vim.api.nvim_win_get_config(win).relative == ""
        and vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_layout_box"
    end)
    if main then
      local buf = vim.api.nvim_win_get_buf(main)
      Snacks.dashboard.open({ win = main })
      if vim.api.nvim_buf_get_name(buf) == "" and buf ~= vim.api.nvim_win_get_buf(main) then
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end
    end
    if #Snacks.picker.get({ source = "explorer" }) == 0 then
      Snacks.explorer()
    end
    -- The explorer grabs focus when it opens; start on the dashboard instead.
    if main then
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(main) then
          vim.api.nvim_set_current_win(main)
        end
      end)
    end
  end,
})

-- `:q` on the last editor window also closes the sidebars, so nvim quits instead of leaving
-- only the explorer (or outline/trouble/quickfix) open.
local sidebars = { snacks_layout_box = true, aerial = true, trouble = true, qf = true }
au("QuitPre", {
  callback = function()
    local cur = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_config(cur).relative ~= "" or sidebars[vim.bo.filetype] then
      return
    end
    local others = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if win ~= cur and vim.api.nvim_win_get_config(win).relative == "" then
        if not sidebars[vim.bo[vim.api.nvim_win_get_buf(win)].filetype] then
          return -- another editor window remains; plain :q is fine
        end
        others[#others + 1] = win
      end
    end
    for _, picker in ipairs(Snacks.picker.get({ source = "explorer" })) do
      picker:close()
    end
    for _, win in ipairs(others) do
      pcall(vim.api.nvim_win_close, win, true)
    end
  end,
})
