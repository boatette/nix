{
  flake.modules.homeManager.git =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      configDir = "${config.xdg.configHome}/lazygit";

      baseConfig = "${configDir}/base.yml";
      themeConfig = "${configDir}/config.yml";

      ensureThemeConfig = pkgs.writeShellApplication {
        name = "lazygit-ensure-theme-config";
        runtimeInputs = [ pkgs.coreutils ];
        text = ''
          mkdir -p "${configDir}"
          [ -f "${themeConfig}" ] || printf '{}\n' > "${themeConfig}"
        '';
      };
    in
    {
      home = {
        packages = [ pkgs.lazygit ];

        activation.lazygitThemeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run ${lib.getExe ensureThemeConfig}
        '';

        sessionVariables.LG_CONFIG_FILE = "${baseConfig},${themeConfig}";
      };

      xdg.configFile."lazygit/base.yml".source = (pkgs.formats.yaml { }).generate "lazygit-base.yml" {
        gui = {
          nerdFontsVersion = "3";
          showRandomTip = false;
          border = "rounded";
          showFileTree = true;
        };

        git.paging = {
          colorArg = "always";
          pager = "delta --paging=never";
        };
      };
    };
}
