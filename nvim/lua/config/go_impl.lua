local M = {}

local title = "Go interface implementation"

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = title })
end

local function command_output(command, cwd, label)
  local result = vim.system(command, { cwd = cwd, text = true }):wait()
  if result.code ~= 0 then
    local detail = vim.trim(result.stderr or "")
    if detail == "" then
      detail = label .. " exited with code " .. result.code
    end
    return nil, detail
  end

  return vim.trim(result.stdout or "")
end

local function target_struct()
  local bufnr = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" then
    notify("Save the Go buffer before implementing an interface", vim.log.levels.ERROR)
    return
  end
  if vim.bo[bufnr].modified then
    notify("Save the Go buffer before implementing an interface", vim.log.levels.WARN)
    return
  end
  if #vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" }) == 0 then
    notify("gopls is not attached to this buffer", vim.log.levels.ERROR)
    return
  end

  local parser_ok, parser = pcall(vim.treesitter.get_parser, bufnr, "go")
  if not parser_ok or not parser then
    notify("The Go Tree-sitter parser is unavailable", vim.log.levels.ERROR)
    return
  end
  parser:parse()

  local ok, struct = pcall(require("gopher._utils.ts").get_struct_under_cursor, bufnr)
  if not ok or not struct or not struct.name then
    notify("Place the cursor inside a named struct declaration", vim.log.levels.ERROR)
    return
  end
  if struct.is_varstruct then
    notify("Methods can only be generated for a named struct", vim.log.levels.ERROR)
    return
  end

  local receiver_type = struct.name
  if struct.tparams and #struct.tparams.args > 0 then
    receiver_type = receiver_type .. "[" .. table.concat(struct.tparams.args, ", ") .. "]"
  end

  local commands = require("gopher.config").commands
  local dir = vim.fs.dirname(path)
  local package_name, err = command_output({ commands.go, "list", "-f", "{{.Name}}", "." }, dir, "go list")
  if not package_name or package_name == "" then
    notify("Could not resolve the target package: " .. (err or "empty package name"), vim.log.levels.ERROR)
    return
  end

  return {
    bufnr = bufnr,
    changedtick = vim.api.nvim_buf_get_changedtick(bufnr),
    commands = commands,
    dir = dir,
    insert_row = struct.end_,
    package_name = package_name,
    receiver = vim.fn.strcharpart(struct.name, 0, 1):lower() .. " *" .. receiver_type,
  }
end

local function interface_from_selection(selected, opts)
  local entry = require("fzf-lua.path").entry_to_file(selected[1], opts, opts._uri)
  local path = entry.path or entry.bufname
  if not path and entry.uri and entry.uri:match("^file://") then
    path = vim.uri_to_fname(entry.uri)
  end
  assert(path and path ~= "", "the selected interface has no local source file")

  local lines = vim.fn.readfile(path)
  local source = table.concat(lines, "\n")
  local parser = vim.treesitter.get_string_parser(source, "go")
  local tree = assert(parser:parse()[1], "could not parse the selected interface")
  local row = math.max((entry.line or 1) - 1, 0)
  local col = math.max((entry.col or 1) - 1, 0)
  local node = tree:root():named_descendant_for_range(row, col, row, col + 1)

  while node and node:type() ~= "type_spec" do
    node = node:parent()
  end
  assert(node, "the selected symbol is not a Go type declaration")

  local name_node = node:field("name")[1]
  local type_node = node:field("type")[1]
  assert(name_node and type_node and type_node:type() == "interface_type", "the selected symbol is not an interface")

  return {
    dir = vim.fs.dirname(path),
    generic = node:field("type_parameters")[1] ~= nil,
    name = vim.treesitter.get_node_text(name_node, source),
  }
end

local function insert_stubs(target, interface)
  if not vim.api.nvim_buf_is_valid(target.bufnr) then
    notify("The target buffer was closed; no methods were generated", vim.log.levels.ERROR)
    return
  end
  if vim.api.nvim_buf_get_changedtick(target.bufnr) ~= target.changedtick then
    notify("The target buffer changed while choosing an interface; run the picker again", vim.log.levels.WARN)
    return
  end

  local import_path, list_error =
    command_output({ target.commands.go, "list", "-f", "{{.ImportPath}}", "." }, interface.dir, "go list")
  if not import_path or import_path == "" then
    notify("Could not resolve the interface package: " .. (list_error or "empty import path"), vim.log.levels.ERROR)
    return
  end

  local qualified = import_path .. "." .. interface.name
  local output, impl_error = command_output({
    target.commands.impl,
    "-dir",
    target.dir,
    "-recvpkg",
    target.package_name,
    target.receiver,
    qualified,
  }, target.dir, "impl")
  if not output then
    notify("Could not implement " .. qualified .. ": " .. impl_error, vim.log.levels.ERROR)
    return
  end
  if output == "" then
    notify(target.receiver .. " already implements " .. qualified)
    return
  end

  local lines = vim.split(output, "\n", { plain = true })
  table.insert(lines, 1, "")
  local line_count = vim.api.nvim_buf_line_count(target.bufnr)
  if target.insert_row < line_count then
    table.insert(lines, "")
  end
  vim.api.nvim_buf_set_lines(target.bufnr, target.insert_row, target.insert_row, false, lines)
  notify("Generated methods for " .. qualified)
end

local function implement_selected(target, selected, opts)
  if not selected[1] then
    return
  end

  local ok, interface = pcall(interface_from_selection, selected, opts)
  if not ok then
    notify("Could not read the selected interface: " .. interface, vim.log.levels.ERROR)
    return
  end

  if not interface.generic then
    insert_stubs(target, interface)
    return
  end

  vim.ui.input({
    prompt = "Type arguments for " .. interface.name .. " (for example: string, int): ",
  }, function(arguments)
    arguments = arguments and vim.trim(arguments) or ""
    if arguments == "" then
      notify("Interface implementation cancelled")
      return
    end
    if not arguments:match("^%[.*%]$") then
      arguments = "[" .. arguments .. "]"
    end
    interface.name = interface.name .. arguments
    insert_stubs(target, interface)
  end)
end

function M.pick()
  local target = target_struct()
  if not target then
    return
  end

  require("fzf-lua").lsp_live_workspace_symbols({
    prompt = "Implement interface❯ ",
    jump1 = false,
    regex_filter = function(item)
      return item.kind == "Interface"
    end,
    fzf_opts = {
      ["--multi"] = false,
      ["--no-multi"] = true,
    },
    actions = {
      ["enter"] = function(selected, opts)
        implement_selected(target, selected, opts)
      end,
    },
  })
end

return M
