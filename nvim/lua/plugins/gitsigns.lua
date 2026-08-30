return {
  "lewis6991/gitsigns.nvim",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gitsigns.nav_hunk("next")
        end
      end, "Next git hunk")

      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gitsigns.nav_hunk("prev")
        end
      end, "Previous git hunk")

      map("n", "<leader>Gp", gitsigns.preview_hunk, "Preview hunk")
      map("n", "<leader>Gs", gitsigns.stage_hunk, "Stage/unstage hunk")
      map("n", "<leader>Gr", gitsigns.reset_hunk, "Reset hunk")

      map("x", "<leader>Gs", function()
        gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage/unstage selected hunk")
      map("x", "<leader>Gr", function()
        gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset selected hunk")

      map("n", "<leader>Gb", function()
        gitsigns.blame_line({ full = true })
      end, "Blame line")
      map("n", "<leader>GB", gitsigns.blame, "Blame buffer")

      map("n", "<leader>Gd", gitsigns.diffthis, "Diff against index")
      map("n", "<leader>GD", function()
        gitsigns.diffthis("~")
      end, "Diff against last commit")

      map({ "o", "x" }, "ih", gitsigns.select_hunk, "Inside git hunk")
    end,
  },
}
