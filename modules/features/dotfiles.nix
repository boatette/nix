{
    flake.modules.homeManager.base =
        { config, lib, ... }:
        let
            repo = "${config.home.homeDirectory}/nix/dotfiles";

            link = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";

            links = {
                ".local/bin" = "bin";
            };

            configDirs = lib.attrNames (
                lib.filterAttrs (_: type: type == "directory") (builtins.readDir ../../dotfiles/config)
            );
        in
        {
            home.file = lib.mapAttrs (_: path: { source = link path; }) links;

            xdg.configFile = lib.genAttrs configDirs (name: {
                source = link "config/${name}";
                recursive = true;
            });
        };
}
