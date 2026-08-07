{ inputs, ... }:

{
    flake.modules.nixos.workstation = {
        nix.settings = {
            experimental-features = [
                "nix-command"
                "flakes"
            ];
            extra-substituters = [
                "https://nix-community.cachix.org"
                "https://noctalia.cachix.org"
            ];
            extra-trusted-public-keys = [
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
            ];
        };

        nixpkgs = {
            config.allowUnfree = true;

            overlays = [
                inputs.claude-code.overlays.default
                inputs.millennium.overlays.default
            ];
        };
    };
}
