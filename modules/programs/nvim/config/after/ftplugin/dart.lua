vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2

require("flutter-tools").setup({
    ui = { notification_style = "native" },
    debugger = { enabled = true },
    widget_guides = { enabled = true },
    lsp = { color = { enabled = true } },
})
