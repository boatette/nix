vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
            if not ev.data.active then
                vim.cmd.packadd("nvim-treesitter")
            end
            vim.cmd("TSUpdate")
        end
    end,
    desc = "vim.pack post-change hooks",
})

vim.pack.add({
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-treesitter/nvim-treesitter-context",
})

vim.api.nvim_create_autocmd("FileType", {
    callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        local available_langs = require("nvim-treesitter").get_available()
        local is_available = vim.tbl_contains(available_langs, lang)
        if is_available then
            local installed_langs = require("nvim-treesitter").get_installed()
            local installed = vim.tbl_contains(installed_langs, lang)
            if not installed then
                require("nvim-treesitter").install(lang):wait()
            end
            vim.treesitter.start()
            require("nvim-treesitter").indentexpr()
        end
    end,
})

require("treesitter-context").setup({ max_lines = 3 })
