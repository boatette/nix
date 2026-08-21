{ inputs, ... }:
{
  flake.modules.nixvim.nvim =
    {
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib.nixvim) mkRaw;

      mkFlakePlugin =
        name: src:
        pkgs.vimUtils.buildVimPlugin {
          inherit name src;
        };
    in
    {
      extraFiles = lib.listToAttrs (
        map
          (name: {
            name = "lua/colourscheme/${name}.lua";
            value.source = ./lua/colourscheme/${name}.lua;
          })
          [
            "init"
            "palette"
            "schemes"
          ]
      );

      extraPlugins =
        (with pkgs.vimPlugins; [
          catppuccin-nvim
          kanagawa-nvim
          nord-nvim
          rose-pine
          tokyonight-nvim

          mini-base16
        ])
        ++ [
          (mkFlakePlugin "everforest-nvim" inputs.plugins-everforest-nvim)
          (mkFlakePlugin "github-monochrome-nvim" inputs.plugins-github-monochrome-nvim)
        ];

      userCommands.ThemeReload = {
        command = mkRaw ''function() require("colourscheme").apply() end'';
        desc = "Re-apply the colorscheme from noctalia's current palette";
      };

      extraConfigLua = ''
        do
            local FLOAT_GROUPS = { "NormalFloat", "FloatBorder", "FloatShadow", "FloatTitle" }

            local function clear_floats(hl, palette)
                for _, group in ipairs(FLOAT_GROUPS) do
                    hl[group] = { bg = palette.none }
                end
            end

            require("colourscheme").setup({
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
                        on_highlights = clear_floats,
                    })
                end,

                kanagawa = function()
                    require("kanagawa").setup({
                        transparent = true,
                        overrides = function()
                            local overrides = { LineNr = { bg = "NONE" }, SignColumn = { bg = "NONE" } }
                            for _, group in ipairs(FLOAT_GROUPS) do
                                overrides[group] = { bg = "NONE" }
                            end
                            return overrides
                        end,
                    })
                end,

                ["github-monochrome"] = function()
                    require("github-monochrome").setup({
                        transparent = true,
                        styles = { floats = "transparent", sidebars = "transparent" },
                    })
                end,

                nord = function()
                    require("nord").setup({
                        transparent = true,
                        on_highlights = clear_floats,
                    })
                end,
            })
        end
      '';
    };
}
