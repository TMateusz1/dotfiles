-- Helm charts have no built-in filetype in Neovim, yet both the `helm`
-- treesitter parser and helm-ls key off one: nvim-lspconfig declares
-- `filetypes = { "helm", "yaml.helm-values" }` for helm_ls. Without this,
-- chart templates stay `yaml`, helm-ls never attaches, and yaml-language-server
-- attaches instead and reports every `{{ ... }}` as broken YAML.
--
-- Detection keys off the *chart*, not off a directory name: a `Chart.yaml`
-- above a file is what makes that file Helm. Charts in the wild do not all put
-- their templates in `templates/` — `deploy/template/` is just as common — and
-- a rule that hard-codes the directory name fails silently, leaving exactly the
-- broken-YAML behaviour above.
--
-- nvim-lspconfig's own docs point at the vim-helm plugin for this. It is a
-- handful of filetype rules, which `vim.filetype.add()` already does natively,
-- so no plugin is added. See docs/nvim.md#helm.

--- Directory holding the nearest `Chart.yaml` at or above `path`, if any.
--- The search stops at the *nearest* one, so a subchart under `charts/`
--- resolves against its own root rather than its parent's.
---@param path string absolute path of the file being detected
---@return string? root
local function chart_root(path)
  local chart = vim.fs.find("Chart.yaml", {
    upward = true,
    type = "file",
    path = vim.fs.dirname(path),
    limit = 1,
  })[1]
  return chart and vim.fs.dirname(chart) or nil
end

--- Parts of a chart that are plain YAML rather than Go templates.
---
---  * `Chart.yaml` / `Chart.lock` are chart metadata.
---  * `crds/` and `ci/` are never rendered by Helm, by Helm's own definition.
---  * a dotted path segment is infrastructure that merely happens to sit inside
---    the chart — `.github/workflows/*.yaml` when the repository root *is* the
---    chart root.
---
---@param relative string chart-root-relative, slash-separated
---@param name string basename of the file
---@return boolean
local function is_plain_yaml(relative, name)
  if name == "Chart.yaml" or name == "Chart.lock" then
    return true
  end

  local first = relative:match("^([^/]+)/")
  if first == "crds" or first == "ci" then
    return true
  end

  for segment in vim.gsplit(relative, "/", { plain = true }) do
    if segment:sub(1, 1) == "." then
      return true
    end
  end

  return false
end

--- Returning nil leaves the file to Neovim's ordinary detection, which is what
--- every non-chart YAML file wants.
---@param path string
---@return string?
local function yaml_filetype(path)
  local root = chart_root(path)
  if not root then
    return nil
  end

  local relative = vim.fs.relpath(root, path)
  if not relative then
    return nil
  end

  local name = vim.fs.basename(relative)
  if is_plain_yaml(relative, name) then
    return "yaml"
  end

  -- values.yaml is real YAML, so it keeps a yaml-prefixed compound filetype for
  -- tools that understand dotted filetypes. The `.helm-values` suffix lets
  -- helm-ls attach, which is what makes `.Values.*` completion inside a
  -- template resolve against the actual file.
  if name:match("^values.*%.ya?ml$") then
    return "yaml.helm-values"
  end

  return "helm"
end

---@param path string
---@return string?
local function in_chart(path)
  return chart_root(path) and "helm" or nil
end

vim.filetype.add({
  pattern = {
    [".*%.ya?ml"] = yaml_filetype,
    -- Partials and the release notes are Go templates wherever they sit, but
    -- only inside a chart — plenty of unrelated projects ship a `.tpl`.
    [".*%.tpl"] = in_chart,
    [".*/NOTES%.txt"] = in_chart,
  },
})
