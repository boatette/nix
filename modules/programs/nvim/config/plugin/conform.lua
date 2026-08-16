require("conform").setup({
    formatters_by_ft = {
        bash = { "shfmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        glsl = { "clang_format" },
        java = { "google-java-format" },
        javascript = { "prettierd" },
        javascriptreact = { "prettierd" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        kotlin = { "ktlint" },
        rust = { "rustfmt" },
        lua = { "stylua" },
        markdown = { "prettierd" },
        nix = { "nixfmt" },
        python = { "ruff_format", "ruff_organize_imports" },
        sh = { "shfmt" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        zig = { "zigfmt" },
    },
    formatters = {
        ["google-java-format"] = { prepend_args = { "--aosp" } },
    },
    format_on_save = { lsp_format = "fallback" },
})

vim.keymap.set("n", "<leader>cf", function()
    require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })
