local bar = { text = "▎" }
local signs = {
  add = bar,
  change = bar,
  delete = { text = "" },
  topdelete = { text = "" },
  changedelete = bar,
  untracked = bar,
}

return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = signs,
      signs_staged = signs,
      signs_staged_enable = true,
      current_line_blame = false,
      current_line_blame_opts = { delay = 500, virt_text_pos = "eol" },
      preview_config = { border = "rounded" },
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        local function nav(key, dir)
          return function()
            if vim.wo.diff then
              vim.cmd.normal({ key, bang = true })
            else
              gs.nav_hunk(dir)
            end
          end
        end
        local function range()
          return { vim.fn.line("."), vim.fn.line("v") }
        end
        map("n", "]h", nav("]c", "next"), "Next hunk")
        map("n", "[h", nav("[c", "prev"), "Prev hunk")
        map("n", "]H", function()
          gs.nav_hunk("last")
        end, "Last hunk")
        map("n", "[H", function()
          gs.nav_hunk("first")
        end, "First hunk")
        map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        map("x", "<leader>gs", function()
          gs.stage_hunk(range())
        end, "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("x", "<leader>gr", function()
          gs.reset_hunk(range())
        end, "Reset hunk")
        map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage")
        map("n", "<leader>gp", gs.preview_hunk_inline, "Preview hunk")
        map("n", "<leader>gb", function()
          gs.blame_line({ full = true })
        end, "Blame line")
        map({ "o", "x" }, "ih", gs.select_hunk, "Hunk")
        Snacks.toggle({
          name = "Inline blame",
          get = function()
            return require("gitsigns.config").config.current_line_blame
          end,
          set = function(state)
            gs.toggle_current_line_blame(state)
          end,
        }):map("<leader>ub")
      end,
    },
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = { merge_tool = { layout = "diff3_mixed" } },
      file_panel = { win_config = { position = "left", width = 30 } },
    },
  },
}
