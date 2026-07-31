vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-neotest/nvim-nio",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-neotest/neotest",
    "https://github.com/rouge8/neotest-rust",
    "https://github.com/lawrence-laz/neotest-zig",
    "https://github.com/sidlatau/neotest-dart",
})

require("neotest").setup({
    output = { open_on_run = true },
    status = { virtual_text = true, signs = true },
    adapters = {
        require("neotest-rust"),
        require("neotest-zig"),
        require("neotest-dart")({ runner = "flutter" }),
    },
})

local neotest = require("neotest")

local map = vim.keymap.set
map("n", "<leader>tr", function()
    neotest.run.run()
end, { desc = "Run nearest test" })
map("n", "<leader>tf", function()
    neotest.run.run(vim.fn.expand("%"))
end, { desc = "Run file" })
map("n", "<leader>ta", function()
    neotest.run.run(vim.fn.getcwd())
end, { desc = "Run all tests" })
map("n", "<leader>ts", function()
    neotest.run.stop()
end, { desc = "Stop" })
map("n", "<leader>to", function()
    neotest.output.open({ enter = true })
end, { desc = "Output" })
map("n", "<leader>tO", function()
    neotest.output_panel.toggle()
end, { desc = "Output panel" })
map("n", "<leader>tS", function()
    neotest.summary.toggle()
end, { desc = "Summary" })
