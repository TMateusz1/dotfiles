return {
  "ibhagwan/fzf-lua",
  event = "VeryLazy",
  cmd = "FzfLua",
  keys = {
    { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
    { "<leader>fF", "<cmd>FzfLua global<cr>", desc = "Find files / buffers / symbols" },
    { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Find buffers" },
    { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
    { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
    { "<leader>fh", "<cmd>FzfLua helptags<cr>", desc = "Help tags" },
    { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document symbols" },
    { "<leader>fS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "Workspace symbols" },
    { "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document diagnostics" },
    { "<leader>fG", "<cmd>FzfLua git_status<cr>", desc = "Git status" },
    { "<leader>f.", "<cmd>FzfLua resume<cr>", desc = "Resume last picker" },
    { "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Find keymaps" },
    { "<leader>fq", "<cmd>FzfLua quickfix<cr>", desc = "Find check results (quickfix)" },
  },
  opts = function()
    local fzf_actions = require("fzf-lua.actions")
    local trouble_actions = require("trouble.sources.fzf").actions

    return {
      actions = {
        files = {
          -- Inherit split-opening and hidden/ignored-file toggles.
          true,
          -- Keep single-result Enter fast; send a multi-selection to Trouble.
          ["enter"] = {
            fn = function(selected, opts)
              if #selected > 1 then
                return trouble_actions.open_selected.fn(selected, opts)
              end
              return fzf_actions.file_edit(selected, opts)
            end,
            desc = "open-or-send-to-trouble",
          },
          ["ctrl-t"] = trouble_actions.open,
          -- Do not send selected results to Neovim's plain quickfix window.
          ["alt-q"] = false,
          ["alt-Q"] = false,
        },
      },
      buffers = {
        fzf_opts = { ["--multi"] = true },
      },
      lsp = {
        code_actions = {
          jump1 = false,
          previewer = "codeaction",
        },
      },
      ui_select = {},
    }
  end,
}
