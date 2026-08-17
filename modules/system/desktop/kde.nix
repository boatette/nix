{
  flake.modules.homeManager.desktop =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      kwriteconfig = lib.getExe' pkgs.kdePackages.kconfig "kwriteconfig6";

      writeKey = file: group: key: value: ''
        run ${kwriteconfig} --file ${lib.escapeShellArg "${config.xdg.configHome}/${file}"} \
            --group ${lib.escapeShellArg group} --key ${lib.escapeShellArg key} \
            ${lib.escapeShellArg (if lib.isBool value then lib.boolToString value else toString value)}
      '';
    in
    {
      options.kde.settings = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.attrsOf (
            lib.types.attrsOf (
              lib.types.oneOf [
                lib.types.bool
                lib.types.int
                lib.types.str
              ]
            )
          )
        );
        default = { };
        example = lib.literalExpression ''{ kdeglobals.Icons.Theme = "Papirus"; }'';
        description = "KDE settings, keyed by file under $XDG_CONFIG_HOME, then group, then key.";
      };

      config.home.activation.kdeSettings = lib.mkIf (config.kde.settings != { }) (
        lib.hm.dag.entryAfter [ "writeBoundary" ] (
          lib.concatStrings (
            lib.flatten (
              lib.mapAttrsToList (
                file: lib.mapAttrsToList (group: lib.mapAttrsToList (writeKey file group))
              ) config.kde.settings
            )
          )
        )
      );
    };
}
