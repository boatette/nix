return {
    catppuccin = function()
        require("catppuccin").setup({
            transparent_background = true,
            float = { transparent = true },
        })
    end,

    ["rose-pine"] = function()
        require("rose-pine").setup({
            dim_inactive_windows = false,
            styles = { transparency = true },
        })
    end,

    tokyonight = function()
        require("tokyonight").setup({
            transparent = true,
            styles = { sidebars = "transparent", floats = "transparent" },
        })
    end,

    everforest = function()
        vim.g.everforest_transparent_background = 2
    end,

    kanagawa = function()
        require("kanagawa").setup({
            transparent = true,
        })
    end,

    zenwritten = function()
        vim.g.zenwritten = { transparent_background = true }
    end,

    nord = function()
        vim.g.nord_disable_background = true
        vim.g.nord_cursorline_transparent = true
    end,
}
