{ inputs, ... }:
{
  flake-file.inputs.rose-pine-qutebrowser = {
    url = "github:aalbegr/qutebrowser-rose-pine";
    flake = false;
  };

  flake.modules.homeManager.qutebrowser =
    { pkgs, ... }:
    let
      modules = pkgs.linkFarm "qutebrowser-rosepine" [
        {
          name = "rosepine";
          path = inputs.rose-pine-qutebrowser;
        }
      ];
    in
    {
      programs.qutebrowser.extraConfig = ''
        import sys

        sys.path.insert(0, "${modules}")
        import rosepine

        rosepine.setup(c, "rose-pine", True)
      '';
    };
}
