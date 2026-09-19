vim.pack.add({
    "https://github.com/folke/trouble.nvim",
})

require("trouble").setup({})

vim.keymap.set(
    "n",
    "<leader>xx",
    "<cmd>Trouble toggle diagnostics<CR>",
    { desc = "Workspace diagnostics [trouble]", silent = true }
)
vim.keymap.set(
    "n",
    "<leader>xX",
    "<cmd>Trouble toggle diagnostics filter.buf=0<CR>",
    { desc = "Document diagnostics [trouble]", silent = true }
)
vim.keymap.set(
    "n",
    "gr",
    "<cmd>Trouble toggle lsp_references<CR>",
    { desc = "LSP References [trouble]", silent = true }
)
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble toggle quickfix<CR>", { desc = "QuickFix [trouble]", silent = true })
vim.keymap.set("n", "<leader>xl", "<cmd>Trouble toggle loclist<CR>", { desc = "LOCList [trouble]", silent = true })

vim.keymap.set("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols panel (Trouble)" })
vim.keymap.set("n", "<leader>xi", "<cmd>Trouble lsp_incoming_calls toggle<cr>", { desc = "Incoming calls (Trouble)" })
vim.keymap.set("n", "<leader>xo", "<cmd>Trouble lsp_outgoing_calls toggle<cr>", { desc = "Outgoing calls (Trouble)" })
vim.keymap.set("n", "gd", "<cmd>Trouble lsp_definitions toggle<cr>", { desc = "Go to definition (Trouble)" })
vim.keymap.set("n", "gI", "<cmd>Trouble lsp_implementations toggle<cr>", { desc = "Go to implementations (Trouble)" })
vim.keymap.set("n", "gy", "<cmd>Trouble lsp_type_definitions toggle<cr>", { desc = "Go to type definition (Trouble)" })
