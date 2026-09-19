vim.loader.enable()
pcall(function()
    require("vim._core.ui2").enable()
end)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.editorconfig = true

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_rplugin = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zipPlugin = 1

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.g.zig_fmt_autosave = 0

vim.filetype.add({
    extension = {
        comp = "glsl",
        frag = "glsl",
        geom = "glsl",
        gohtml = "gotmpl",
        mdx = "markdown",
        tesc = "glsl",
        tese = "glsl",
        tmpl = "gotmpl",
        vert = "glsl",
    },
})

require("options")
require("diagnostics")

vim.schedule(function()
    require("autocmds")
    require("keymaps")
end)
