{
    flake.modules.nixos.base =
        { lib, ... }:
        {
            options.preferences.user = {
                name = lib.mkOption {
                    type = lib.types.str;
                    default = "boatette";
                };

                description = lib.mkOption {
                    type = lib.types.str;
                    default = "Jonathan Clark";
                };
            };
        };
}
