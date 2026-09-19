vim.pack.add({ "https://github.com/mfussenegger/nvim-lint" })

local lint = require("lint")

lint.linters_by_ft = {
    bash = { "shellcheck" },
    cpp = { "cpplint" },
    go = { "golangcilint" },
    javascript = { "eslint_d" },
    javascriptreact = { "eslint_d" },
    markdown = { "markdownlint-cli2" },
    nix = { "statix", "deadnix" },
    python = { "ruff" },
    sh = { "shellcheck" },
    typescript = { "eslint_d" },
    typescriptreact = { "eslint_d" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
    group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
    desc = "Auto-lint on read and save",
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if lint.linters_by_ft[ft] then
            lint.try_lint()
        end
    end,
})
