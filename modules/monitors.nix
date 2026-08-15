{
  flake.modules.nixos.monitors =
    { lib, ... }:
    {
      options.preferences.monitors = lib.mkOption {
        default = { };
        description = "Connected outputs, keyed by connector name.";
        example = lib.literalExpression ''
          {
              "eDP-1" = {
                  mode = "1920x1080@144";
                  primary = true;
              };
          }
        '';
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              mode = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "e.g. \"1920x1080@144\"; null lets niri pick.";
              };

              scale = lib.mkOption {
                type = lib.types.either lib.types.int lib.types.float;
                default = 1;
              };

              transform = lib.mkOption {
                type = lib.types.str;
                default = "normal";
              };

              position = {
                x = lib.mkOption {
                  type = lib.types.int;
                  default = 0;
                };
                y = lib.mkOption {
                  type = lib.types.int;
                  default = 0;
                };
              };

              primary = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = ''
                  The output that named workspaces open on and that
                  the lockscreen is drawn on. Exactly one output
                  should set this.
                '';
              };
            };
          }
        );
      };
    };
}
