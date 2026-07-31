vim.pack.add({
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/mfussenegger/nvim-dap",

    "https://github.com/nvim-java/nvim-java",
})

require("java").setup({ spring_boot_tools = { enable = false } })
vim.lsp.enable("jdtls")
