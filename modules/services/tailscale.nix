{
  # reaches this pc from the phone, at home or away
  flake.modules.nixos.tailscale = {
    services.tailscale = {
      enable = true;
      # direct connections on the same wi-fi instead of going through a relay
      openFirewall = true;
    };
  };
}
