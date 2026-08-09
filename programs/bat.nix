{
    flake = {
        homeModules.dev =
            { pkgs, ... }:
            {
                home.packages = [ pkgs.bat ];
            };

        nixosModules.base.environment.sessionVariables = {
            MANROFFOPT = "-c";
            MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        };
    };
}
