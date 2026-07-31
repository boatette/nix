vim.pack.add({ "https://github.com/mbbill/undotree" })

vim.keymap.set("n", "<leader>ou", "<cmd>UndotreeToggle<cr>", { desc = "Toggle undo tree" })
