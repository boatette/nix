vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-flutter/flutter-tools.nvim",
})
require("flutter-tools").setup({
    ui = { notification_style = "native" },
    debugger = { enabled = true },
    widget_guides = { enabled = true },
    lsp = { color = { enabled = true } },
})
