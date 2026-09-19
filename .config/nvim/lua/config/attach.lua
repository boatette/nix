local M = {}

function M.on_attach(ev)
    local buf = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
        return
    end

    if client:supports_method("textDocument/codeLens") then
        vim.lsp.codelens.enable(true, { bufnr = buf })
    end

    if client:supports_method("textDocument/documentHighlight") then
        local group = vim.api.nvim_create_augroup("nvim_doc_hl_" .. buf, { clear = true })
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

return M
