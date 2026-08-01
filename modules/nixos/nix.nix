{ inputs, ... }:

{
    nix.settings.experimental-features = [
        "nix-command"
        "flakes"
    ];

    nixpkgs = {
        config.allowUnfree = true;

        overlays = [
            inputs.claude-code.overlays.default
            inputs.millennium.overlays.default
        ];
    };
}
