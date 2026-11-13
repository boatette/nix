local M = {}

-- global, so they reach every client that attaches later and supports them
vim.lsp.codelens.enable(true)
vim.lsp.inlay_hint.enable(true)

local pending = {}

local function refresh_codelens(client_id)
    if pending[client_id] then
        return
    end
    pending[client_id] = true
    vim.defer_fn(function()
        pending[client_id] = nil
        local ok, codelens = pcall(require, "vim.lsp.codelens")
        if ok and codelens.on_refresh then
            codelens.on_refresh(nil, nil, { client_id = client_id })
        end
    end, 500)
end

vim.api.nvim_create_autocmd("LspProgress", {
    group = vim.api.nvim_create_augroup("CodelensRetry", { clear = true }),
    desc = "Retry code lens once the server finishes background work",
    callback = function(ev)
        local value = ev.data and ev.data.params and ev.data.params.value
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if value and value.kind == "end" and client and client:supports_method("textDocument/codeLens") then
            refresh_codelens(ev.data.client_id)
        end
    end,
})

function M.on_attach(ev)
    local buf = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
        return
    end

    -- nvf's clangd preset defines the command, per buffer
    if client.name == "clangd" then
        vim.keymap.set(
            "n",
            "<leader>ch",
            "<cmd>ClangdSwitchSourceHeader<cr>",
            { buffer = buf, desc = "Switch source/header" }
        )
    end

    if client:supports_method("textDocument/documentHighlight") then
        local group = vim.api.nvim_create_augroup("DocumentHighlight" .. buf, { clear = true })
        vim.api.nvim_create_autocmd("CursorHold", {
            buffer = buf,
            group = group,
            callback = vim.lsp.buf.document_highlight,
            desc = "Highlight symbol under cursor",
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
            buffer = buf,
            group = group,
            callback = vim.lsp.buf.clear_references,
            desc = "Clear highlight on cursor move",
        })
    end
end

-- drops the symbol highlight once no client left on the buffer can provide it
function M.on_detach(ev)
    local buf = ev.buf
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
        if client.id ~= ev.data.client_id and client:supports_method("textDocument/documentHighlight") then
            return
        end
    end
    pcall(vim.api.nvim_del_augroup_by_name, "DocumentHighlight" .. buf)
    vim.lsp.util.buf_clear_references(buf)
end

return M
