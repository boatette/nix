vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

vim.lsp.config("*", {
    capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("nvim_lsp_attach", { clear = true }),
    desc = "LSP on-attach configuration",
    callback = function(ev)
        local buf = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then
            return
        end

        local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc, silent = true })
        end

        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "K", vim.lsp.buf.hover, "Trigger hover")

        if client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = buf })
        end

        require("config.attach").on_attach(ev)
    end,
})

vim.lsp.enable({
    "bashls",
    "clangd",
    "eslint",
    "glsl_analyzer",
    "gopls",
    "jsonls",
    "lua_ls",
    "nixd",
    "pyright",
    "ruff",
    "ts_ls",
    "zls",
})
