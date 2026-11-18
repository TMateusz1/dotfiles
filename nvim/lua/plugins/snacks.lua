return {
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      notifier = { enabled = true, timeout = 3000, style = "compact" },
      input = { enabled = true },
      indent = { enabled = true, animate = { enabled = false }, scope = { enabled = true } },
      scope = { enabled = true },
      words = {
        enabled = true,
        debounce = 200,
        -- Only highlight references of names: on keywords (Go's `return`, `for`, `break`) LSPs
        -- highlight every exit point or loop branch instead. Keywords are anonymous TS nodes.
        filter = function(buf)
          if vim.g.snacks_words == false or vim.b[buf].snacks_words == false then
            return false
          end
          local win = vim.fn.bufwinid(buf)
          if win == -1 then
            return false
          end
          local row, col = unpack(vim.api.nvim_win_get_cursor(win))
          local ok, node =
            pcall(vim.treesitter.get_node, { bufnr = buf, pos = { row - 1, col }, include_anonymous = true })
          return not (ok and node and not node:named())
        end,
      },
      statuscolumn = {
        enabled = true,
        left = { "mark", "sign" },
        right = { "fold", "git" },
        folds = { open = false, git_hl = true },
      },
      dashboard = {
        enabled = true,
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { icon = " ", title = "Recent Files", section = "recent_files", cwd = true, indent = 2, padding = 1 },
          { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          { section = "startup" },
        },
      },
      explorer = { enabled = false },
      picker = {
        ui_select = true,
        layout = { preset = "default", cycle = true },
        matcher = { frecency = true },
        formatters = { file = { filename_first = true } },
        win = {
          input = {
            keys = {
              ["<C-x>"] = { "edit_split", mode = { "i", "n" } },
            },
          },
          list = {
            keys = {
              ["<C-x>"] = "edit_split",
            },
          },
        },
        sources = {
          files = { hidden = true },
          grep = { hidden = true },
        },
      },
      lazygit = { configure = false }, -- keep the repo's Catppuccin lazygit theme
      gitbrowse = { enabled = true },
      bufdelete = { enabled = true },
      rename = { enabled = true },
      zen = { enabled = true },
      toggle = { enabled = true },
      scroll = { enabled = false },
      animate = { enabled = false },
      dim = { enabled = false },
    },
    -- stylua: ignore
    keys = {
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      -- find
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Files" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>fG", function() Snacks.picker.git_status() end, desc = "Git status" },
      { "<leader>fs", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace symbols" },
      { "<leader>fS", function() Snacks.picker.lsp_symbols() end, desc = "Document symbols" },
      { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Grep word/selection", mode = { "n", "x" } },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fr", function() Snacks.picker.recent({ filter = { cwd = true } }) end, desc = "Recent files" },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "Help" },
      { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>fD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer diagnostics" },
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Config files" },
      { "<leader>fR", function() Snacks.picker.resume() end, desc = "Resume picker" },
      { "<leader>f/", function() Snacks.picker.lines() end, desc = "Buffer lines" },
      { "<leader>fN", function() Snacks.picker.notifications() end, desc = "Notifications" },
      -- git
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit log" },
      { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit file history" },
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Browse on remote", mode = { "n", "x" } },
      -- buffers
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete buffer" },
      { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete other buffers" },
      -- ui
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss notifications" },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          local t = Snacks.toggle
          t.option("wrap", { name = "Wrap" }):map("<leader>uw")
          t.option("spell", { name = "Spell" }):map("<leader>us")
          -- A global flag, so the normal/insert autocmd doesn't undo the toggle.
          t.new({
            id = "relativenumber",
            name = "Relative numbers",
            get = function()
              return vim.g.relativenumber ~= false
            end,
            set = function(state)
              vim.g.relativenumber = state
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.wo[win].number and vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
                  vim.wo[win].relativenumber = state
                end
              end
            end,
          }):map("<leader>ul")
          t.option("conceallevel", { off = 0, on = 2, name = "Conceal" }):map("<leader>uc")
          t.diagnostics():map("<leader>ud")
          t.inlay_hints():map("<leader>uh")
          t.zen():map("<leader>uz")
          t.new({
            id = "virtual_lines",
            name = "Diagnostic virtual lines",
            get = function()
              return vim.diagnostic.config().virtual_lines ~= false
            end,
            set = function(state)
              vim.diagnostic.config({ virtual_lines = state and { current_line = true } or false })
            end,
          }):map("<leader>uv")
          t.new({
            id = "autopairs",
            name = "Autopairs",
            get = function()
              return not vim.g.minipairs_disable
            end,
            set = function(state)
              vim.g.minipairs_disable = not state
            end,
          }):map("<leader>up")
        end,
      })
    end,
  },
}
