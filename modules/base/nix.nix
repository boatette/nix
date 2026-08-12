{ inputs, ... }:

let
    config = {
        allowUnfree = true;
    };

    overlays = [
        inputs.claude-code.overlays.default
        inputs.millennium.overlays.default
    ];
in
{
    flake.modules.nixos.base =
        { lib, ... }:
        {
            nix.settings = {
                experimental-features = [
                    "nix-command"
                    "flakes"
                ];

                max-jobs = lib.mkDefault 6;

                extra-substituters = [
                    "https://nix-community.cachix.org"
                    "https://noctalia.cachix.org"
                ];
                extra-trusted-public-keys = [
                    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
                ];
            };

            systemd.services.nix-daemon.serviceConfig = {
                MemoryHigh = lib.mkDefault "10G";
                MemoryMax = lib.mkDefault "14G";
            };

            nixpkgs = { inherit config overlays; };
        };

    perSystem =
        { system, ... }:
        {
            _module.args.pkgs = import inputs.nixpkgs { inherit system config overlays; };
        };
}
