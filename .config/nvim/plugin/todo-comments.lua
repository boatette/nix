vim.pack.add({ "https://github.com/folke/todo-comments.nvim" })

require("todo-comments").setup({
    highlight = { pattern = [[.*<(KEYWORDS)(\([^\)]*\))?:]] },
    search = {
        command = "rg",
        args = { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column" },
        pattern = [[\b(KEYWORDS)(\([^\)]*\))?:]],
    },
})

vim.keymap.set("n", "<leader>st", function()
    require("snacks").picker.todo_comments()
end, { desc = "Todo" })
vim.keymap.set("n", "]t", function()
    require("todo-comments").jump_next()
end, { desc = "Next todo" })
vim.keymap.set("n", "[t", function()
    require("todo-comments").jump_prev()
end, { desc = "Prev todo" })
