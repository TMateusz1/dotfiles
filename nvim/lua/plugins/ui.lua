-- LSP clients and formatters attached to the current buffer, e.g. `gopls │ 󰉿 stylua`.
local function lsp_and_formatters()
  local names = vim.tbl_map(function(c)
    return c.name
  end, vim.lsp.get_clients({ bufnr = 0 }))
  local parts = { table.concat(names, ", ") }
  local ok, conform = pcall(require, "conform")
  if ok then
    -- Resolving formatters walks the filesystem; cache per buffer (cleared by the autocmd below).
    if vim.b.formatter_names == nil then
      vim.b.formatter_names = vim.tbl_map(function(f)
        return f.name
      end, conform.list_formatters(0))
    end
    local fmt = vim.b.formatter_names
    if vim.g.autoformat == false or vim.b.autoformat == false then
      table.insert(parts, "󰉿 off")
    elseif #fmt > 0 then
      table.insert(parts, "󰉿 " .. table.concat(fmt, ", "))
    end
  end
  return table.concat(
    vim.tbl_filter(function(s)
      return s ~= ""
    end, parts),
    " │ "
  )
end

return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    init = function()
      vim.api.nvim_create_autocmd({ "BufWritePost", "FileType", "LspAttach", "LspDetach" }, {
        group = vim.api.nvim_create_augroup("user_statusline", { clear = true }),
        callback = function(ev)
          vim.b[ev.buf].formatter_names = nil
        end,
      })
    end,
    opts = {
      options = {
        theme = "catppuccin-nvim", -- follows the active flavour
        globalstatus = true,
        component_separators = "",
        section_separators = { left = "", right = "" },
        disabled_filetypes = { statusline = { "snacks_dashboard" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          "branch",
          {
            "diff",
            source = function()
              local g = vim.b.gitsigns_status_dict
              if g then
                return { added = g.added, modified = g.changed, removed = g.removed }
              end
            end,
          },
        },
        lualine_c = {
          "diagnostics",
          {
            "grapple",
            cond = function()
              return package.loaded["grapple"] and require("grapple").exists()
            end,
          },
          { "filetype", icon_only = true, padding = { left = 1, right = 0 } },
          { "filename", path = 1, symbols = { modified = " ●", readonly = "󰌾 ", unnamed = "" } },
        },
        lualine_x = { lsp_and_formatters },
        lualine_y = { "progress", "location" },
        -- Zellij's zjstatus already displays the clock on the top bar.
        lualine_z = vim.env.ZELLIJ and {} or {
          function()
            return os.date(" %R")
          end,
        },
      },
      extensions = { "lazy", "quickfix", "man", "trouble", "aerial", "neo-tree" },
    },
  },

  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "catppuccin" },
    keys = {
      { "<leader><space>", "<cmd>BufferLinePick<cr>", desc = "Pick buffer (by letter)" },
      { "<leader>bc", "<cmd>BufferLinePickClose<cr>", desc = "Pick buffer to close" },
      { "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", desc = "Close buffers to the left" },
      { "<leader>bl", "<cmd>BufferLineCloseRight<cr>", desc = "Close buffers to the right" },
      { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle pin" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Close unpinned" },
    },
    opts = function()
      return {
        highlights = require("catppuccin.special.bufferline").get_theme(),
        options = {
          mode = "buffers",
          close_command = function(n)
            Snacks.bufdelete(n)
          end,
          right_mouse_command = function(n)
            Snacks.bufdelete(n)
          end,
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(_, _, diag)
            local s = {}
            if diag.error then
              table.insert(s, " " .. diag.error)
            end
            if diag.warning then
              table.insert(s, " " .. diag.warning)
            end
            return table.concat(s, " ")
          end,
          always_show_bufferline = true,
          show_buffer_close_icons = false,
          separator_style = "thin",
          -- Keep tabs clear of the explorer (left) and aerial (right).
          offsets = {
            { filetype = "neo-tree", text = "Explorer", highlight = "Directory", separator = true },
            { filetype = "aerial", text = "Outline", highlight = "Directory", separator = true },
            { filetype = "DiffviewFiles", text = "Diffview", highlight = "Directory", separator = true },
          },
        },
      }
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      delay = 300,
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>c", group = "code" },
        { "<leader>x", group = "diagnostics/quickfix" },
        { "<leader>b", group = "buffer" },
        { "<leader>u", group = "ui/toggles" },
        { "<leader>S", group = "session" },
        { "<leader>r", group = "replace" },
        { "<leader>t", group = "test" },
        { "<leader>w", group = "window" },
        { "[", group = "prev" },
        { "]", group = "next" },
        { "g", group = "goto" },
        { "gs", group = "surround" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer keymaps",
      },
    },
  },

  {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialOpen", "AerialClose" },
    keys = { { "<leader>o", "<cmd>AerialToggle<cr>", desc = "Outline" } },
    opts = {
      backends = { "lsp", "treesitter", "markdown", "man" },
      layout = {
        default_direction = "right",
        placement = "edge", -- docked far right regardless of splits
        min_width = 30,
        max_width = { 40, 0.2 },
        resize_to_content = false,
      },
      attach_mode = "global",
      show_guides = true,
      highlight_on_hover = true,
      autojump = false,
      close_on_select = false,
      filter_kind = false,
      keymaps = { ["<C-j>"] = "actions.down_and_scroll", ["<C-k>"] = "actions.up_and_scroll" },
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    opts = { completions = { blink = { enabled = true } }, latex = { enabled = false } },
    config = function(_, opts)
      local rm = require("render-markdown")
      rm.setup(opts)
      Snacks.toggle({
        name = "Render markdown",
        get = rm.get,
        set = rm.set,
      }):map("<leader>um")
    end,
  },

  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    -- stylua: ignore
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev todo" },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todos (Trouble)" },
      { "<leader>ft", function() Snacks.picker.todo_comments() end, desc = "Todos" },
    },
  },

  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      -- Keep snacks.notifier in charge of vim.notify; fidget handles LSP progress only.
      notification = {
        override_vim_notify = false,
        window = { winblend = 0 },
      },
    },
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    opts = {
      preset = "modern",
      options = {
        show_source = { enabled = true, if_many = true },
        multilines = { enabled = true },
      },
    },
  },

  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = { focus = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
    },
  },
}
