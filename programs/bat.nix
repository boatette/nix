{
    flake.modules = {
        homeManager.dev =
            { pkgs, ... }:
            {
                home.packages = [ pkgs.bat ];
            };

        nixos.base.environment.sessionVariables = {
            MANROFFOPT = "-c";
            MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        };
    };
}
