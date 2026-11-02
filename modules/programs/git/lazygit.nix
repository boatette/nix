{ inputs, ... }:
{
  flake-file.inputs.rose-pine-lazygit = {
    url = "github:rose-pine/lazygit";
    flake = false;
  };

  flake.modules.homeManager.git =
    { config, pkgs, ... }:
    let
      configDir = "${config.xdg.configHome}/lazygit";
    in
    {
      home = {
        packages = [ pkgs.lazygit ];

        # both are home-manager links, so neither goes missing; lazygit won't start if one does
        sessionVariables.LG_CONFIG_FILE = "${configDir}/base.yml,${configDir}/config.yml";
      };

      xdg.configFile = {
        "lazygit/base.yml".source = (pkgs.formats.yaml { }).generate "lazygit-base.yml" {
          gui = {
            nerdFontsVersion = "3";
            showRandomTip = false;
            border = "rounded";
            showFileTree = true;
          };

          git = {
            overrideGpg = true;

            diffRenderers = [
              {
                colorArg = "always";
                command = "delta --paging=never";
              }
            ];
          };

          os.editPreset = "nvim-remote";
        };

        "lazygit/config.yml".source = "${inputs.rose-pine-lazygit}/themes/rose-pine.yml";
      };
    };
}
