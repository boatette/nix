vim.api.nvim_create_autocmd("LspAttach", {
    callback = function()
        vim.pack.add({ "https://github.com/folke/trouble.nvim" })

        require("trouble").setup()

        local map = vim.keymap.set
        map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Workspace diagnostics (Trouble)" })
        map(
            "n",
            "<leader>xX",
            "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
            { desc = "Document diagnostics (Trouble)" }
        )
        map("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix list (Trouble)" })
        map("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = "Location list (Trouble)" })
        map("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols panel (Trouble)" })
        map("n", "<leader>xi", "<cmd>Trouble lsp_incoming_calls toggle<cr>", { desc = "Incoming calls (Trouble)" })
        map("n", "<leader>xo", "<cmd>Trouble lsp_outgoing_calls toggle<cr>", { desc = "Outgoing calls (Trouble)" })
    end,
    once = true,
})
