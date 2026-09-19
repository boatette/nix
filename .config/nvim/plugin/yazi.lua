vim.pack.add({ "https://github.com/mikavilpas/yazi.nvim" })

require("yazi").setup({ open_for_directories = true })

vim.keymap.set("n", "<leader>e", "<cmd>Yazi<cr>", { desc = "File explorer" })
vim.keymap.set("n", "<leader>E", "<cmd>Yazi cwd<cr>", { desc = "File explorer (cwd)" })
