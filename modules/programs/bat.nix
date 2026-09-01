{
  flake.modules.homeManager.bat =
    { pkgs, ... }:
    {
      home = {
        packages = [ pkgs.bat ];

        sessionVariables = {
          MANROFFOPT = "-c";
          MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        };
      };
    };
}
