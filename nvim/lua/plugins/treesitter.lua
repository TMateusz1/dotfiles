return {
  {
    -- `main` doesn't support lazy-loading.
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
      ts.install(require("config.parsers")) -- async; no-op when installed
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(ev)
          if not pcall(vim.treesitter.start, ev.buf) then
            return
          end
          local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
          if lang and vim.treesitter.query.get(lang, "indents") then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    opts = { move = { set_jumps = true } },
    config = function(_, opts)
      require("nvim-treesitter-textobjects").setup(opts)
      local move = require("nvim-treesitter-textobjects.move")
      local function map(lhs, fn, query, desc)
        vim.keymap.set({ "n", "x", "o" }, lhs, function()
          -- Vim's own ]c / [c jump between changes in diff mode.
          if vim.wo.diff and lhs:find("[cC]") then
            return vim.cmd.normal({ lhs, bang = true })
          end
          move[fn](query, "textobjects")
        end, { desc = desc })
      end
      map("]f", "goto_next_start", "@function.outer", "Next function start")
      map("[f", "goto_previous_start", "@function.outer", "Prev function start")
      map("]F", "goto_next_end", "@function.outer", "Next function end")
      map("[F", "goto_previous_end", "@function.outer", "Prev function end")
      map("]c", "goto_next_start", "@class.outer", "Next class start")
      map("[c", "goto_previous_start", "@class.outer", "Prev class start")
      map("]C", "goto_next_end", "@class.outer", "Next class end")
      map("[C", "goto_previous_end", "@class.outer", "Prev class end")
      map("]a", "goto_next_start", "@parameter.inner", "Next parameter")
      map("[a", "goto_previous_start", "@parameter.inner", "Prev parameter")
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = { max_lines = 3, multiline_threshold = 1, mode = "cursor" },
    config = function(_, opts)
      local tsc = require("treesitter-context")
      tsc.setup(opts)
      Snacks.toggle({
        name = "Treesitter context",
        get = tsc.enabled,
        set = function(state)
          if state then
            tsc.enable()
          else
            tsc.disable()
          end
        end,
      }):map("<leader>ut")
    end,
  },

  { "windwp/nvim-ts-autotag", event = "BufReadPre", opts = {} },
}
