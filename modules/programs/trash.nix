{
  flake.modules.homeManager.boatette =
    { pkgs, ... }:
    {
      home = {
        packages = with pkgs; [ trash-cli ];

        # trash-put takes rm's -r, -f, -i, -d and -v, so habits and muscle memory keep working
        shellAliases.rm = "trash-put";
      };
    };
}
