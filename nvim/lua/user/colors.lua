-- Transparent background for AstroVim + terminal passthrough
vim.opt.termguicolors = true
vim.opt.winblend = 0
vim.opt.pumblend = 0
vim.opt.background = "dark"

-- Helper to (re)apply transparent backgrounds and soft cursor line
local function apply_transparency()
  local transparent_groups = {
    -- Core
    "Normal",
    "NormalNC",
    "NormalFloat",
    "FloatBorder",
    "SignColumn",
    "LineNr",
    "EndOfBuffer",
    "MsgArea",
    "StatusLine",
    "StatusLineNC",
    "FoldColumn",
    "WinSeparator",
    -- Statusline & Winbar
    "StatusLine",
    "StatusLineNC",
    "WinBar",
    "WinBarNC",
    -- Tabline
    "TabLine",
    "TabLineFill",
    "TabLineSel",
    -- Bufferline (akinsho/bufferline)
    "BufferLineFill",
    "BufferLineBackground",
    "BufferLineSeparator",
    "BufferLineSeparatorVisible",
    "BufferLineSeparatorSelected",
    "BufferLineTab",
    "BufferLineTabSelected",
    "BufferLineTabClose",
    "BufferLineBufferVisible",
    "BufferLineBufferSelected",
    "BufferLineOffsetSeparator",
    -- Heirline (AstroNvim UI pieces)
    "HeirlineNormal",
    "HeirlineWinbar",
    "HeirlineWinbarNC",

    -- Neo-tree
    "NeoTreeNormal",
    "NeoTreeNormalNC",
    "NeoTreeEndOfBuffer",
    "NeoTreeFloatNormal",
  }

  for _, g in ipairs(transparent_groups) do
    vim.cmd(("hi %s guibg=NONE ctermbg=NONE"):format(g))
  end

  -- Keep the current line readable on busy wallpapers
  vim.cmd [[
    hi CursorLine guibg=#24283b ctermbg=236
    hi CursorLineNr gui=bold
    hi NeoTreeCursorLine guibg=#24283b ctermbg=236
  ]]
end

-- Run now and whenever the colorscheme changes
apply_transparency()
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function() apply_transparency() end,
})
return {}
