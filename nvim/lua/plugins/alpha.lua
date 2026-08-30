return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- Must be loaded at startup: alpha decides whether to draw from its own
  -- VimEnter autocommand, and there is no command or key to lazy-load from.
  lazy = false,
  config = function()
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      [[███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
      [[████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
      [[██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
      [[██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
      [[██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
      [[╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
    }
    -- The dashboard theme's own defaults are generic groups ("Type" for the
    -- header, "Number" for the footer, "Keyword" for shortcuts). Naming the
    -- Alpha* groups is what hands the colors to catppuccin's alpha
    -- integration — see docs/nvim.md#dashboard.
    dashboard.section.header.opts.hl = "AlphaHeader"

    -- Sessions are keyed by directory, so which directory this is matters.
    local cwd = {
      type = "text",
      val = vim.fn.fnamemodify(vim.fn.getcwd(), ":~"),
      opts = { position = "center", hl = "AlphaHeaderLabel" },
    }

    dashboard.section.buttons.val = {
      dashboard.button("f", "  Find file", "<cmd>FzfLua files<cr>"),
      dashboard.button("r", "  Recent files", "<cmd>FzfLua oldfiles<cr>"),
      dashboard.button("g", "  Live grep", "<cmd>FzfLua live_grep<cr>"),
      dashboard.button("n", "  New file", "<cmd>ene<bar>startinsert<cr>"),
      dashboard.button("e", "  File explorer", "<cmd>Yazi cwd<cr>"),
      dashboard.button("s", "  Restore session", "<cmd>SessionRestore<cr>"),
      dashboard.button("c", "  Config", "<cmd>FzfLua files cwd=" .. vim.fn.stdpath("config") .. "<cr>"),
      dashboard.button("l", "󰒲  Lazy", "<cmd>Lazy<cr>"),
      dashboard.button("q", "  Quit", "<cmd>qa<cr>"),
    }
    for _, b in ipairs(dashboard.section.buttons.val) do
      b.opts.hl = "AlphaButtons"
      b.opts.hl_shortcut = "AlphaShortcut"
    end

    dashboard.section.footer.opts.hl = "AlphaFooter"

    dashboard.config.layout = {
      { type = "padding", val = 2 },
      dashboard.section.header,
      { type = "padding", val = 1 },
      cwd,
      { type = "padding", val = 2 },
      dashboard.section.buttons,
      { type = "padding", val = 1 },
      dashboard.section.footer,
    }

    require("alpha").setup(dashboard.config)

    -- lazy.nvim only computes `startuptime` once a UI has attached (UIEnter),
    -- which is not ordered against the VimEnter that draws the dashboard — so
    -- the footer is filled in whenever the numbers become real, and the buffer
    -- redrawn. AlphaRedraw is a no-op when the dashboard isn't showing (e.g.
    -- `nvim .` opened the tree instead).
    local function set_footer()
      local stats = require("lazy").stats()
      dashboard.section.footer.val =
        string.format("󱐋 %d/%d plugins loaded in %.2f ms", stats.loaded, stats.count, stats.startuptime)
      pcall(vim.cmd.AlphaRedraw)
    end

    if next(vim.api.nvim_list_uis()) then
      vim.schedule(set_footer) -- UI already attached, so UIEnter won't fire again
    else
      vim.api.nvim_create_autocmd("UIEnter", { once = true, callback = set_footer })
    end
  end,
}
