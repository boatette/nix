{ inputs, lib, ... }:
let
  # cudaSupport only adds the driver runpath, so btop can load libnvidia-ml
  package = pkgs: pkgs.btop.override { cudaSupport = true; };
in
{
  flake-file.inputs.rose-pine-btop = {
    url = "github:rose-pine/btop";
    flake = false;
  };

  # intel gpu stats need CAP_PERFMON; the wrapper wins as /run/wrappers/bin is first in PATH
  flake.modules.nixos.btop =
    { pkgs, ... }:
    {
      security.wrappers.btop = {
        owner = "root";
        group = "root";
        capabilities = "cap_perfmon+ep";
        source = lib.getExe (package pkgs);
      };
    };

  flake.modules.homeManager.btop =
    { pkgs, ... }:
    {
      programs.btop = {
        enable = true;
        package = package pkgs;

        # btop only finds themes in its theme directories, not by path
        themes.rose-pine = builtins.readFile "${inputs.rose-pine-btop}/rose-pine.theme";

        settings = {
          color_theme = "rose-pine";
          theme_background = false;

          shown_boxes = "cpu mem net proc gpu0 gpu1";

          vim_keys = true;
          rounded_corners = false;

          update_ms = 500;
          background_update = false;

          save_config_on_exit = false;
        };
      };
    };
}
