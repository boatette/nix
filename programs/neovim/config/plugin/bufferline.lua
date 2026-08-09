vim.schedule(function()
    require("bufferline").setup({
        options = {
            always_show_bufferline = true,
            sort_by = "id",
            diagnostics = "nvim_lsp",
            diagnostics_update_in_insert = false,
        },
    })
    vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev tab" })
    vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next tab" })
end)
