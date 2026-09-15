{
  flake.modules.nixos.nix-settings =
    { lib, ... }:
    {
      nix = {
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];

          extra-substituters = [
            "https://boatette.cachix.org"
            "https://nix-community.cachix.org"
            "https://noctalia.cachix.org"
          ];
          extra-trusted-public-keys = [
            "boatette.cachix.org-1:5BHq2x06JKALt69vg1d3eCwS0skbfeYT2Da1gorl7Dg="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
          ];
        };

        optimise.automatic = true;
      };

      systemd.services.nix-daemon.serviceConfig = {
        MemoryHigh = lib.mkDefault "10G";
        MemoryMax = lib.mkDefault "14G";
      };
    };
}
