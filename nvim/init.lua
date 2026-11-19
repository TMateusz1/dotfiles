vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- No remote-plugin providers are used.
for _, p in ipairs({ "node", "perl", "python3", "ruby" }) do
  vim.g["loaded_" .. p .. "_provider"] = 0
end

require("config.options")
require("config.clipboard")
require("config.diagnostics")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
