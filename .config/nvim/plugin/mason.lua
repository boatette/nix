-- Installs the language servers, linters and formatters this config expects
-- into ~/.local/share/nvim/mason, skipping anything already on PATH.

vim.pack.add({ "https://github.com/mason-org/mason.nvim" })

require("mason").setup()

local ensure_installed = {
    -- LSP
    "bash-language-server",
    "clangd",
    "eslint-lsp",
    "glsl_analyzer",
    "gopls",
    "json-lsp",
    "lua-language-server",
    "nixd",
    "pyright",
    "ruff",
    "rust-analyzer",
    "typescript-language-server",
    "zls",
    -- Linters
    "cpplint",
    "deadnix",
    "eslint_d",
    "golangci-lint",
    "markdownlint-cli2",
    "shellcheck",
    "statix",
    -- Formatters
    "clang-format",
    "gofumpt",
    "goimports",
    "nixfmt",
    "prettierd",
    "shfmt",
    "stylua",
}

require("mason-registry").refresh(function()
    for _, tool in ipairs(ensure_installed) do
        local name, version = tool:match("^([^@]+)@?(.*)$")
        version = version ~= "" and version or nil

        local ok, package = pcall(require("mason-registry").get_package, name)
        if ok and vim.fn.executable(name) ~= 1 and not package:is_installed() then
            package:install({ version = version })
        end
    end
end)
