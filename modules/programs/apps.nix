{
  flake.modules.homeManager.apps =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        vesktop
        gimp
        stremio-linux-shell
        qbittorrent
        proton-pass
        ventoy

        libreoffice-qt
        hunspell
      ];
    };
}
