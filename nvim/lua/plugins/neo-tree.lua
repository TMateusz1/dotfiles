return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-mini/mini.icons",
    },
    keys = {
      {
        "<leader>e",
        function()
          require("neo-tree.command").execute({ toggle = true, source = "filesystem", position = "left" })
        end,
        desc = "Explorer",
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({ toggle = true, source = "buffers", position = "left" })
        end,
        desc = "Buffer explorer",
      },
    },
    opts = function(_, opts)
      local events = require("neo-tree.events")
      local function on_move(data)
        Snacks.rename.on_rename_file(data.source, data.destination)
      end

      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
      })

      opts.sources = { "filesystem", "buffers" }
      opts.source_selector = {
        sources = {
          { source = "filesystem" },
          { source = "buffers" },
        },
      }
      opts.close_if_last_window = true
      opts.enable_git_status = true
      opts.enable_diagnostics = true

      opts.window = {
        position = "left",
        width = 30,
        mappings = {
          -- Keep <Space> free as mapleader.
          ["<space>"] = "none",
          ["<C-v>"] = "open_vsplit",
          ["<C-x>"] = "open_split",
        },
      }

      -- File icons come from mini.icons via editor.lua's nvim-web-devicons mock;
      -- git status symbols and indent/folder glyphs use neo-tree's built-in Nerd Font defaults.
      opts.default_component_configs = {
        indent = { with_expanders = true },
        diagnostics = {
          symbols = {
            error = "",
            warn = "",
            info = "",
            hint = "󰌵",
          },
        },
      }

      opts.filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        hijack_netrw_behavior = "open_default",
        filtered_items = {
          hide_dotfiles = true,
          hide_gitignored = true,
        },
      }

      opts.buffers = {
        follow_current_file = { enabled = true },
        show_unloaded = true,
      }
    end,
  },
}
