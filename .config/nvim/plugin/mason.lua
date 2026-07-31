if vim.uv.fs_stat("/etc/NIXOS") then
    return
end

-- If not all tools are installed run the following command:
-- :MasonInstall bash-language-server clangd eslint-lsp fish-lsp glsl_analyzer gradle-language-server jdtls json-lsp lua-language-server ols pyright ruff rust-analyzer typescript-language-server zls codelldb dart-debug-adapter debugpy js-debug-adapter kotlin-debug-adapter cpplint ktlint markdownlint markdownlint-cli2 clang-format google-java-format prettierd shfmt stylua

vim.pack.add({ "https://github.com/mason-org/mason.nvim" })

require("mason").setup()

local ensure_installed = {
    -- LSP
    "bash-language-server",
    "clangd",
    "eslint-lsp",
    "fish-lsp",
    "glsl_analyzer",
    "gradle-language-server",
    "jdtls",
    "json-lsp",
    "lua-language-server",
    "ols",
    "pyright",
    "ruff",
    "rust-analyzer",
    "typescript-language-server",
    "zls",
    -- DAP
    "codelldb",
    "dart-debug-adapter",
    "debugpy",
    "js-debug-adapter",
    "kotlin-debug-adapter",
    -- Linters
    "cpplint",
    "eslint_d",
    "ktlint",
    "markdownlint",
    "markdownlint-cli2",
    -- Formatters
    "clang-format",
    "google-java-format",
    "prettierd",
    "shfmt",
    "stylua",
}

require("mason-registry").refresh(function()
    for _, tool in ipairs(ensure_installed) do
        local name, version = tool:match("^([^@]+)@?(.*)$")
        version = version ~= "" and version or nil

        local package = require("mason-registry").get_package(name)
        local is_globally_installed = vim.fn.executable(name) == 1
        if not is_globally_installed and not package:is_installed() then
            package:install({ version = version })
        end
    end
end)
