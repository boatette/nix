require("oil").setup({
    default_file_explorer = true,
    view_options = { show_hidden = true },
    float = {
        max_width = 90,
        max_height = 30,
    },
})

vim.keymap.set("n", "<leader>e", "<cmd>Oil --float<cr>", { desc = "File explorer" })
vim.keymap.set("n", "<leader>E", "<cmd>Oil . --float<cr>", { desc = "File explorer (cwd)" })
