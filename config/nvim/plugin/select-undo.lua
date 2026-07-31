vim.pack.add({ "https://github.com/SunnyTamang/select-undo.nvim" })

require("select-undo").setup({
    line_mapping = "zu",
    sweep_mapping = "zU",
    partial_mapping = "zcu",
})
