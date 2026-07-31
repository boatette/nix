vim.pack.add({
    "https://github.com/nvim-mini/mini.ai",
    "https://github.com/nvim-mini/mini.hipatterns",
    "https://github.com/nvim-mini/mini.splitjoin",
    "https://github.com/nvim-mini/mini.surround",
})

require("mini.ai").setup()

vim.schedule(function()
    local hipatterns = require("mini.hipatterns")
    hipatterns.setup({ highlighters = { hex_color = hipatterns.gen_highlighter.hex_color() } })

    local splitjoin = require("mini.splitjoin")
    splitjoin.setup()
    vim.keymap.set("n", "gS", function()
        splitjoin.toggle()
    end, { desc = "Split/join" })

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
end)
