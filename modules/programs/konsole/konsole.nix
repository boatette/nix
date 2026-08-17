{
  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      xdg.dataFile."konsole/Noctalia.profile".source =
        (pkgs.formats.ini { }).generate "Noctalia.profile"
          (import ./_settings.nix);

      kde.settings.konsolerc."Desktop Entry".DefaultProfile = "Noctalia.profile";
    };
}
