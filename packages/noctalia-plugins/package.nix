{
  lib,
  runCommand,
  formats,
}:

let
  pluginsDir = ./plugins;

  names = lib.attrNames (
    lib.filterAttrs (
      name: type: type == "directory" && builtins.pathExists (pluginsDir + "/${name}/plugin.toml")
    ) (builtins.readDir pluginsDir)
  );

  manifest = name: fromTOML (builtins.readFile (pluginsDir + "/${name}/plugin.toml"));

  timestamps = {
    "boatette/auto-theme" = {
      added_at = 1785571102;
      updated_at = 1785860204;
    };
    "boatette/binary-clock" = {
      added_at = 1786372503;
      updated_at = 1786372503;
    };
  };

  entry =
    name:
    let
      m = manifest name;
      ts =
        timestamps.${m.id} or {
          added_at = 0;
          updated_at = 0;
        };
    in
    {
      inherit (m)
        id
        name
        version
        author
        license
        icon
        description
        plugin_api
        ;
      tags = m.tags or [ ];
      inherit (ts) added_at updated_at;
    };

  catalog = (formats.toml { }).generate "noctalia-plugin-catalog.toml" {
    plugin = map entry names;
  };
in
runCommand "noctalia-plugins"
  {

    passthru.pluginIds = map (name: (manifest name).id) names;
    meta.description = "local noctalia plugin source";
  }
  ''
    mkdir -p $out
    cp -r ${lib.concatStringsSep " " (map (n: "${pluginsDir}/${n}") names)} $out/
    cp ${catalog} $out/catalog.toml

    chmod -R u+w $out
  ''
