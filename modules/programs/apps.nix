{
  flake.modules.homeManager.apps =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        vesktop
        pinta
        blender
        stremio-linux-shell
        qbittorrent
        proton-pass
        ventoy
        # bambu-studio

        libreoffice-qt
        hunspellDicts.en_AU
      ];
    };
}
