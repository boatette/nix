vim.pack.add({
    "https://github.com/nvim-mini/mini.ai",
    "https://github.com/nvim-mini/mini.diff",
    "https://github.com/nvim-mini/mini.hipatterns",
    "https://github.com/nvim-mini/mini.move",
    "https://github.com/nvim-mini/mini.splitjoin",
    "https://github.com/nvim-mini/mini.surround",
})

require("mini.ai").setup({})

require("mini.diff").setup({})

local hipatterns = require("mini.hipatterns")
hipatterns.setup({ highlighters = { hex_color = hipatterns.gen_highlighter.hex_color() } })

require("mini.move").setup({
    mappings = {
        down = "J",
        up = "K",
        left = "",
        right = "",
        line_down = "",
        line_left = "",
        line_right = "",
        line_up = "",
    },
})

require("mini.splitjoin").setup({})

require("mini.surround").setup({
    mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
    },
})

vim.keymap.set("n", "gS", function()
    require("mini.splitjoin").toggle()
end, { desc = "Split/join" })
