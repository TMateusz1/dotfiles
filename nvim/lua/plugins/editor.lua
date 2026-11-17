return {
  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {},
    init = function()
      -- Plugins that expect nvim-web-devicons get mini.icons instead.
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    dependencies = { "nvim-mini/mini.extra" },
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- CamelCase / snake_case word part
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          g = require("mini.extra").gen_ai_spec.buffer(),
          u = ai.gen_spec.function_call(),
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
        },
      }
    end,
  },
  { "nvim-mini/mini.extra", lazy = true, opts = {} },

  {
    "nvim-mini/mini.surround",
    keys = {
      { "gsa", mode = { "n", "x" }, desc = "Add surrounding" },
      { "gsd", desc = "Delete surrounding" },
      { "gsf", desc = "Find right surrounding" },
      { "gsF", desc = "Find left surrounding" },
      { "gsh", desc = "Highlight surrounding" },
      { "gsr", desc = "Replace surrounding" },
      { "gsn", desc = "Update n_lines" },
    },
    -- gs prefix keeps flash's `s` free.
    opts = {
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
      },
    },
  },

  {
    "nvim-mini/mini.pairs",
    event = "InsertEnter",
    opts = {
      modes = { insert = true, command = true, terminal = false },
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      skip_ts = { "string" },
      skip_unbalanced = true,
      markdown = true,
    },
    -- skip_ts / skip_unbalanced / markdown are handled here; mini.pairs lacks them.
    config = function(_, opts)
      local pairs = require("mini.pairs")
      pairs.setup(opts)
      local open = pairs.open
      ---@diagnostic disable-next-line: duplicate-set-field
      pairs.open = function(pair, neigh_pattern)
        if vim.fn.getcmdline() ~= "" then
          return open(pair, neigh_pattern)
        end
        local o, c = pair:sub(1, 1), pair:sub(2, 2)
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        local before, after = line:sub(1, col), line:sub(col + 1)
        -- ``` in markdown opens a fenced block.
        if opts.markdown and o == "`" and vim.bo.filetype == "markdown" and before:match("^%s*``$") then
          return "`\n```" .. vim.api.nvim_replace_termcodes("<up>", true, true, true)
        end
        if opts.skip_next and after:sub(1, 1):match(opts.skip_next) then
          return o
        end
        if opts.skip_ts and #opts.skip_ts > 0 then
          local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, vim.fn.line(".") - 1, math.max(col - 1, 0))
          for _, capture in ipairs(ok and captures or {}) do
            if vim.tbl_contains(opts.skip_ts, capture.capture) then
              return o
            end
          end
        end
        if opts.skip_unbalanced and c ~= o and after:sub(1, 1) == c then
          local _, opening = line:gsub("%" .. o, "")
          local _, closing = line:gsub("%" .. c, "")
          if closing > opening then
            return o
          end
        end
        return open(pair, neigh_pattern)
      end
    end,
  },

  {
    "nvim-mini/mini.bracketed",
    event = "VeryLazy",
    opts = {
      buffer = { suffix = "" }, -- bufferline owns [b ]b (visual order)
      comment = { suffix = "" }, -- [c ]c = treesitter classes
      diagnostic = { suffix = "" }, -- native [d ]d
      file = { suffix = "" }, -- [f ]f = treesitter functions
      treesitter = { suffix = "" }, -- [t ]t = todo-comments
      indent = { suffix = "" }, -- snacks.scope owns [i ]i
    },
  },

  { "nvim-mini/mini.splitjoin", keys = { { "gS", desc = "Split/join" } }, opts = {} },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = { modes = { search = { enabled = false }, char = { enabled = true, jump_labels = true } } },
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter search" },
    },
  },

  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = { headerMaxWidth = 80, transient = true },
    keys = {
      {
        "<leader>rr",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          local prefills = { filesFilter = ext and ext ~= "" and "*." .. ext or nil }
          if vim.fn.mode():match("[vV\22]") then
            grug.with_visual_selection({ prefills = prefills })
          else
            grug.open({ prefills = prefills })
          end
        end,
        mode = { "n", "x" },
        desc = "Search and replace",
      },
      {
        "<leader>rw",
        function()
          require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
        end,
        desc = "Replace word",
      },
    },
  },

  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { branch = true, need = 1 },
    -- stylua: ignore
    keys = {
      { "<leader>Ss", function() require("persistence").load() end, desc = "Restore session" },
      { "<leader>Sl", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>SS", function() require("persistence").select() end, desc = "Select session" },
      { "<leader>Sd", function() require("persistence").stop() end, desc = "Don't save session" },
    },
    init = function()
      -- Sidebars would come back as empty windows.
      vim.api.nvim_create_autocmd("User", {
        pattern = "PersistenceSavePre",
        callback = function()
          if package.loaded["neo-tree.command"] then
            require("neo-tree.command").execute({ action = "close" })
          end
          pcall(vim.cmd, "AerialCloseAll")
        end,
      })
    end,
  },

  {
    "smart-splits-nvim/smart-splits.nvim",
    version = "^3.0.0",
    lazy = false,
    dependencies = {
      {
        "smart-splits-nvim/backend-zellij-lua",
        main = "smart-splits-backend-zellij-lua",
        opts = {
          move_cursor = { pane_or_tab = true },
          fullscreen = { block_nav = true },
          split = { left = false, right = false, up = false, down = false },
        },
      },
    },
    opts = {
      mux = { backend = "smart-splits-backend-zellij-lua" },
      -- Only affect resizing (and at_edge = "split"); <C-Arrow> still enters the explorer.
      ignored_buftypes = { "nofile", "quickfix", "prompt" },
      ignored_filetypes = { "neo-tree" },
      -- At nvim's edge the backend runs `zellij action move-focus-or-tab`, matching Zellij's own
      -- Ctrl+arrows; "wrap" would make the backend jump to the opposite Zellij pane instead.
      move = { at_edge = "stop" },
      resize = { amount = 3 },
    },
    config = function(_, opts)
      local ss = require("smart-splits")
      ss.setup(opts)
      local modes = { "n", "i", "t" }
      for key, dir in pairs({ Left = "left", Down = "down", Up = "up", Right = "right" }) do
        local lhs = "<C-" .. key .. ">"
        vim.keymap.set(modes, lhs, function()
          -- Keep <C-Arrow> intact inside floating windows (pickers, inputs, terminals).
          if vim.api.nvim_win_get_config(0).relative ~= "" then
            vim.api.nvim_feedkeys(vim.keycode(lhs), "n", false)
            return
          end
          local win = vim.api.nvim_get_current_win()
          ss["move_cursor_" .. dir]()
          -- At nvim's edge the backend moved Zellij focus; leaving a tab sends no FocusLost.
          if win == vim.api.nvim_get_current_win() then
            require("config.zellij").sync()
          end
        end, { desc = "Move to " .. dir })
        vim.keymap.set(modes, "<A-" .. key .. ">", ss["resize_" .. dir], { desc = "Resize " .. dir })
        vim.keymap.set("n", "<leader><C-" .. key .. ">", function()
          -- Never swap a buffer into or out of the explorer sidebar.
          local target = vim.fn.win_getid(vim.fn.winnr(({ left = "h", down = "j", up = "k", right = "l" })[dir]))
          if
            vim.api.nvim_win_get_config(0).relative ~= ""
            or vim.bo[vim.api.nvim_win_get_buf(target)].filetype == "neo-tree"
          then
            return
          end
          ss["swap_buf_" .. dir]()
        end, { desc = "Swap buffer " .. dir })
      end
    end,
  },
}
