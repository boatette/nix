{
  # petal, the phone app's server, runs on its own; this only lets the tailnet reach it
  flake.modules.nixos.aspire.networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8190 ];
}
