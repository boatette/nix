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

local group = vim.api.nvim_create_augroup("Treesitter", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "*",
    desc = "Treesitter highlighting, indent and folding",
    callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        vim.wo[0][0].foldmethod = "expr"
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end,
})

require("treesitter-context").setup({
    line_numbers = true,
    max_lines = 3,
    min_window_height = 0,
    mode = "cursor",
    multiline_threshold = 20,
    trim_scope = "outer",
    zindex = 20,
})

do
    local underline_group = vim.api.nvim_create_augroup("TreesitterContextUnderline", { clear = true })

    local function underline()
        local sp = vim.api.nvim_get_hl(0, { name = "Comment", link = false }).fg
        for _, name in ipairs({ "TreesitterContextBottom", "TreesitterContextLineNumberBottom" }) do
            vim.api.nvim_set_hl(0, name, { underline = true, sp = sp })
        end
    end

    vim.api.nvim_create_autocmd("User", {
        pattern = "ColourschemeApplied",
        group = underline_group,
        desc = "Underline the context after a theme change",
        callback = underline,
    })

    underline()
end
