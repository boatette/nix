require("lint").linters_by_ft = {
    cpp = { "cpplint" },
    kotlin = { "ktlint" },
    javascript = { "eslint_d" },
    javascriptreact = { "eslint_d" },
    markdown = { "markdownlint-cli2" },
    nix = { "statix", "deadnix" },
    python = { "ruff" },
    typescript = { "eslint_d" },
    typescriptreact = { "eslint_d" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
    callback = function()
        require("lint").try_lint()
    end,
    desc = "Auto-lint on save and text change",
})
