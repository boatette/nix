{ inputs, lib, ... }:

{
    options.flake = inputs.flake-parts.lib.mkSubmoduleOptions {
        homeModules = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.deferredModule;
            default = { };
        };
    };

    config.systems = [
        "x86_64-linux"
        "aarch64-linux"
    ];
}
