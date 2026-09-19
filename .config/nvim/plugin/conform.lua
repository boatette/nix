vim.pack.add({ "https://github.com/stevearc/conform.nvim" })

require("conform").setup({
    default_format_opts = { lsp_format = "fallback" },
    format_on_save = { lsp_format = "fallback" },
    formatters = {},
    formatters_by_ft = {
        bash = { "shfmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        glsl = { "clang_format" },
        go = { "goimports", "gofumpt" },
        javascript = { "prettierd" },
        javascriptreact = { "prettierd" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        lua = { "stylua" },
        markdown = { "prettierd" },
        nix = { "nixfmt" },
        python = { "ruff_format", "ruff_organize_imports" },
        rust = { "rustfmt" },
        sh = { "shfmt" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
    },
})

vim.keymap.set("n", "<leader>cf", function()
    require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })
