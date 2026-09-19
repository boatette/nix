vim.pack.add({
    { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
    "https://github.com/sainnhe/everforest",
    "https://github.com/rebelot/kanagawa.nvim",
    "https://github.com/shaunsingh/nord.nvim",
    { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
    "https://github.com/folke/tokyonight.nvim",
    "https://github.com/rktjmp/lush.nvim",
    "https://github.com/zenbones-theme/zenbones.nvim",
    "https://github.com/nvim-mini/mini.base16",
})

-- Deferred so every "User ColourschemeApplied" listener in plugin/ is registered
-- before the first apply.
vim.schedule(function()
    require("colourscheme").setup(require("colourscheme.providers"))
end)
