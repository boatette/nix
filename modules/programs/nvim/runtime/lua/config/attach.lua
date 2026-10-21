local M = {}

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
    group = vim.api.nvim_create_augroup("nvim_codelens_retry", { clear = true }),
    desc = "Retry code lens once the server finishes background work",
    callback = function(ev)
        local value = ev.data and ev.data.params and ev.data.params.value
        if value and value.kind == "end" then
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
