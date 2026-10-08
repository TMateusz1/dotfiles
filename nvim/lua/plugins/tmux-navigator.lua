return {
  "christoomey/vim-tmux-navigator",
  -- Not lazy-loaded: the plugin defines its own <C-h/j/k/l> mappings when it
  -- loads, so deferring it would leave those keys unmapped until something
  -- else triggered the load.
  lazy = false,
  config = function()
    -- The plugin's tmux command goes straight to `select-pane`, bypassing the
    -- tmux key binding that hands off to Kitty. Detect the combined Neovim +
    -- tmux edge first, then emit the same narrow SetUserVar request as tmux.
    local directions = {
      left = { wincmd = "h", command = "TmuxNavigateLeft", pane_edge = "pane_at_left", value = "bGVmdA==" },
      bottom = { wincmd = "j", command = "TmuxNavigateDown", pane_edge = "pane_at_bottom", value = "Ym90dG9t" },
      top = { wincmd = "k", command = "TmuxNavigateUp", pane_edge = "pane_at_top", value = "dG9w" },
      right = { wincmd = "l", command = "TmuxNavigateRight", pane_edge = "pane_at_right", value = "cmlnaHQ=" },
    }

    local function notify_kitty(value)
      local sequence = "\27]1337;SetUserVar=tmux_kitty_navigate=" .. value .. "\7"
      if vim.env.TMUX and vim.env.TMUX ~= "" then
        sequence = "\27Ptmux;" .. sequence:gsub("\27", "\27\27") .. "\27\\"
      end
      vim.api.nvim_ui_send(sequence)
    end

    local function tmux_is_at_edge(edge)
      local result = vim
        .system({
          "tmux",
          "display-message",
          "-p",
          "-t",
          vim.env.TMUX_PANE,
          "#{" .. edge .. "}",
        }, { text = true })
        :wait()
      return result.code == 0 and vim.trim(result.stdout) == "1"
    end

    local function navigate(direction)
      local spec = directions[direction]
      local original_window = vim.api.nvim_get_current_win()
      local ok = pcall(vim.cmd.wincmd, spec.wincmd)
      if not ok or original_window ~= vim.api.nvim_get_current_win() then
        return
      end

      if not vim.env.TMUX or vim.env.TMUX == "" or tmux_is_at_edge(spec.pane_edge) then
        notify_kitty(spec.value)
      else
        vim.cmd(spec.command)
      end
    end

    -- Disable tmux's normal wraparound as a fallback if the layout changes
    -- between the edge check and vim-tmux-navigator's select-pane command.
    vim.g.tmux_navigator_no_wrap = 1

    local map = function(lhs, direction, desc)
      vim.keymap.set("n", lhs, function()
        navigate(direction)
      end, { silent = true, desc = desc })
    end

    map("<C-h>", "left", "Move to left split/pane")
    map("<C-j>", "bottom", "Move to lower split/pane")
    map("<C-k>", "top", "Move to upper split/pane")
    map("<C-l>", "right", "Move to right split/pane")
    map("<C-Left>", "left", "Move to left split/pane")
    map("<C-Down>", "bottom", "Move to lower split/pane")
    map("<C-Up>", "top", "Move to upper split/pane")
    map("<C-Right>", "right", "Move to right split/pane")
  end,
}
