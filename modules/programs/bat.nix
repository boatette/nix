{
  flake.modules.homeManager.bat =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.bat ];
    };

  flake.modules.nixos.bat.environment.sessionVariables = {
    MANROFFOPT = "-c";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };
}
