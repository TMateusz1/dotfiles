-- Helm charts have no built-in filetype in Neovim, yet both the `helm`
-- treesitter parser and helm-ls key off one: nvim-lspconfig declares
-- `filetypes = { "helm", "yaml.helm-values" }` for helm_ls. Without this,
-- chart templates stay `yaml`, helm-ls never attaches, and yaml-language-server
-- attaches instead and reports every `{{ ... }}` as broken YAML.
--
-- nvim-lspconfig's own docs point at the vim-helm plugin for this. It is one
-- filetype rule, which `vim.filetype.add()` already does natively, so no plugin
-- is added. See docs/nvim.md#helm.

--- A path only counts as part of a chart if a Chart.yaml sits above it.
--- Without this check every `templates/*.yaml` in any repository — Ansible,
--- Rails, a docs site — would be misdetected as Helm.
---@param path string
---@return boolean
local function in_chart(path)
  return #vim.fs.find("Chart.yaml", {
    upward = true,
    type = "file",
    path = vim.fs.dirname(path),
    limit = 1,
  }) > 0
end

vim.filetype.add({
  pattern = {
    -- Templates are Go templates that only look like YAML.
    [".*/templates/.*%.ya?ml"] = function(path)
      return in_chart(path) and "helm" or nil
    end,
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/NOTES%.txt"] = "helm",
    -- values.yaml is real YAML, so it keeps a yaml filetype and yamlls'
    -- schema support. The `yaml.helm-values` suffix additionally lets helm-ls
    -- attach, which is what makes `.Values.*` completion inside templates
    -- resolve against the actual file.
    [".*/values.*%.ya?ml"] = function(path)
      return in_chart(path) and "yaml.helm-values" or nil
    end,
    [".*/Chart%.ya?ml"] = "yaml",
  },
})
