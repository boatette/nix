{
  # reaches this pc from the phone, at home or away
  flake.modules.nixos.aspire.services.tailscale = {
    enable = true;
    # direct connections on the same wi-fi instead of through a relay
    openFirewall = true;
    # ssh from the phone with the tailnet login instead of keys, for pi and claude in zellij
    extraSetFlags = [ "--ssh" ];
  };
}
