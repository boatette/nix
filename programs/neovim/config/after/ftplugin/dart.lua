vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4

require("flutter-tools").setup({
    ui = { notification_style = "native" },
    debugger = { enabled = true },
    widget_guides = { enabled = true },
    lsp = { color = { enabled = true } },
})
