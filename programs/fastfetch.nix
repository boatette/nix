{
    flake.homeModules.dev =
        { pkgs, ... }:
        {
            home.packages = with pkgs; [
                fastfetch
                figlet
            ];
        };
}
