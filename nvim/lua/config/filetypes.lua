-- Chart-aware Helm detection; unrelated YAML/tpl files retain native detection.
local function chart_root(path)
  return vim.fs.root(vim.fs.dirname(path), "Chart.yaml")
end

local function yaml_filetype(path)
  local root = chart_root(path)
  local relative = root and vim.fs.relpath(root, path)
  if not relative then
    return
  end

  local name = vim.fs.basename(relative)
  -- Chart metadata, CRDs, CI and hidden directories are not Helm templates.
  if
    name == "Chart.yaml"
    or name == "Chart.lock"
    or relative:match("^crds/")
    or relative:match("^ci/")
    or relative:match("^%.")
    or relative:match("/%.")
  then
    return "yaml"
  end
  return name:match("^values.*%.ya?ml$") and "yaml.helm-values" or "helm"
end

local function in_chart(path)
  return chart_root(path) and "helm" or nil
end

vim.filetype.add({
  pattern = {
    [".*%.ya?ml"] = yaml_filetype,
    [".*%.tpl"] = in_chart,
    [".*/NOTES%.txt"] = in_chart,
  },
})
