{ inputs, ... }:

let
    home = "/home/boatette";
    configDir = "${home}/.config/noctalia";
in
{
    flake.modules.homeManager.workstation =
        { pkgs, ... }:
        {
            home.packages = [ inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia ];
        };

    perSystem =
        { pkgs, ... }:
        {
            packages.noctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap [
                { inherit pkgs; }
                (
                    { config, lib, ... }:
                    {
                        config = {
                            package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;

                            outOfStoreConfig = configDir;
                            autoCopyConfig = true;

                            # this wrapper module predates v5 toml config so the file is constructed directly
                            constructFiles = {
                                configToml = {
                                    key = "configToml";
                                    relPath = lib.mkOverride 0 "${config.generatedConfigDirname}/config.toml";
                                    output = lib.mkOverride 0 config.configDrvOutput;
                                    content = builtins.toJSON (import ./_config.nix { inherit home; });
                                    builder = ''${pkgs.remarshal}/bin/json2toml "$1" "$2"'';
                                };
                            }
                            // lib.mapAttrs' (
                                name: _:
                                lib.nameValuePair "template_${lib.replaceStrings [ "." "-" ] [ "_" "_" ] name} " {
                                    key = "template_${name}";
                                    relPath = lib.mkOverride 0 "${config.generatedConfigDirname}/templates/${name}";
                                    output = lib.mkOverride 0 config.configDrvOutput;
                                    content = builtins.readFile (./templates + "/${name}");
                                    builder = ''cp -f "$1" "$2"'';
                                }
                            ) (builtins.readDir ./templates)
                            // {
                                footLiveTheme = {
                                    key = "footLiveTheme";
                                    relPath = lib.mkOverride 0 "${config.generatedConfigDirname}/scripts/foot-live-theme";
                                    output = lib.mkOverride 0 config.configDrvOutput;
                                    content = builtins.readFile ./scripts/foot-live-theme;
                                    builder = ''cp "$1" "$2" && chmod +x "$2"'';
                                };
                            };
                        };
                    }
                )
            ];
        };
}
