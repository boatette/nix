vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    { src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
})

require("harpoon").setup({
    defaults = {
        key = function()
            return vim.uv.cwd()
        end,
        save_on_toggle = false,
        sync_on_ui_close = false,
    },
})

vim.keymap.set("n", "<leader>a", function()
    require("harpoon"):list():add()
end, { desc = "Harpoon: add file" })
vim.keymap.set("n", "<leader>h", function()
    local harpoon = require("harpoon")
    harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon: menu" })
vim.keymap.set("n", "<leader>1", function()
    require("harpoon"):list():select(1)
end, { desc = "Harpoon: file 1" })
vim.keymap.set("n", "<leader>2", function()
    require("harpoon"):list():select(2)
end, { desc = "Harpoon: file 2" })
vim.keymap.set("n", "<leader>3", function()
    require("harpoon"):list():select(3)
end, { desc = "Harpoon: file 3" })
vim.keymap.set("n", "<leader>4", function()
    require("harpoon"):list():select(4)
end, { desc = "Harpoon: file 4" })
vim.keymap.set("n", "<leader>5", function()
    require("harpoon"):list():select(5)
end, { desc = "Harpoon: file 5" })
