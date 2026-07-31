vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

vim.diagnostic.config({
    virtual_text = {
        prefix = function(diag)
            local icons = { ERROR = " 󰅚 ", WARN = " 󰀪 ", INFO = " 󰋽 ", HINT = " 󰌶 " }
            return icons[vim.diagnostic.severity[diag.severity]]
        end,
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
    },
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("nvim_lsp_attach", { clear = true }),
    callback = function(ev)
        local buf = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then
            return
        end

        local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc, silent = true })
        end

        map("n", "gd", "<cmd>Trouble lsp_definitions toggle<cr>", "Go to definition")
        map("n", "gr", "<cmd>Trouble lsp_references toggle<cr>", "Go to references")
        map("n", "gI", "<cmd>Trouble lsp_implementations toggle<cr>", "Go to implementations")
        map("n", "gy", "<cmd>Trouble lsp_type_definitions toggle<cr>", "Go to type definition")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "K", vim.lsp.buf.hover, "Hover documentation")

        if client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = buf })
            vim.keymap.set("n", "<leader>uh", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, { desc = "Toggle inlay hints" })
        end

        if client:supports_method("textDocument/codeLens") then
            vim.lsp.codelens.enable(true, { bufnr = buf })
        end

        if client:supports_method("textDocument/documentHighlight") then
            local hl_group = vim.api.nvim_create_augroup("nvim_doc_hl_" .. buf, { clear = true })
            vim.api.nvim_create_autocmd("CursorHold", {
                buffer = buf,
                group = hl_group,
                callback = vim.lsp.buf.document_highlight,
                desc = "Highlight symbol under cursor",
            })
            vim.api.nvim_create_autocmd("CursorMoved", {
                buffer = buf,
                group = hl_group,
                callback = vim.lsp.buf.clear_references,
                desc = "Clear highlight on cursor move",
            })
        end
    end,
    desc = "LSP on-attach configuration",
})

vim.lsp.enable({
    "bashls",
    "clangd",
    "eslint",
    "fish_lsp",
    "glsl_analyzer",
    "gradle_ls",
    "lua_ls",
    "jsonls",
    "nixd",
    "ols",
    "pyright",
    "qmlls",
    "ruff",
    "rust_analyzer",
    "ts_ls",
    "zls",
})
