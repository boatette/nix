vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-neotest/nvim-nio",
    "https://github.com/nvim-neotest/neotest",
    "https://github.com/fredrikaverpil/neotest-golang",
    "https://github.com/rouge8/neotest-rust",
    "https://github.com/lawrence-laz/neotest-zig",
    "https://github.com/sidlatau/neotest-dart",
})

require("neotest").setup({
    adapters = {
        require("neotest-golang"),
        require("neotest-rust"),
        require("neotest-zig"),
        require("neotest-dart")({ runner = "flutter" }),
    },
    output = { open_on_run = true },
    status = { virtual_text = true, signs = true },
})

vim.keymap.set("n", "<leader>tr", function()
    require("neotest").run.run()
end, { desc = "Run nearest test" })
vim.keymap.set("n", "<leader>tf", function()
    require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Run file" })
vim.keymap.set("n", "<leader>ta", function()
    require("neotest").run.run(vim.fn.getcwd())
end, { desc = "Run all tests" })
vim.keymap.set("n", "<leader>ts", function()
    require("neotest").run.stop()
end, { desc = "Stop" })
vim.keymap.set("n", "<leader>to", function()
    require("neotest").output.open({ enter = true })
end, { desc = "Output" })
vim.keymap.set("n", "<leader>tO", function()
    require("neotest").output_panel.toggle()
end, { desc = "Output panel" })
vim.keymap.set("n", "<leader>tS", function()
    require("neotest").summary.toggle()
end, { desc = "Summary" })
