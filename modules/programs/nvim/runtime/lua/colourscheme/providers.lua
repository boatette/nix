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
        require("everforest").setup({
            transparent_background_level = 2,
        })
    end,

    kanagawa = function()
        require("kanagawa").setup({
            transparent = true,
        })
    end,

    ["github-monochrome"] = function()
        require("github-monochrome").setup({
            transparent = true,
            styles = { floats = "transparent", sidebars = "transparent" },
        })
    end,

    nord = function()
        vim.g.nord_disable_background = true
        vim.g.nord_cursorline_transparent = true
    end,
}
