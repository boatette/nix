let
  port = 53317;
in
{
  flake-file.inputs.noctalia-community-plugins = {
    url = "github:noctalia-dev/community-plugins";
    flake = false;
  };

  flake.modules.nixos.aspire.networking.firewall = {
    allowedTCPPorts = [ port ];
    allowedUDPPorts = [ port ];
  };

  # the daemon and file picker of noctalia's localsend plus
  flake.modules.homeManager.boatette =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        local.localsend-controller
        zenity
      ];
    };
}
