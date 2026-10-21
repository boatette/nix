{
  flake.modules.nixos.appimage =
    { pkgs, ... }:
    {
      programs.appimage = {
        enable = true;
        binfmt = true;

        package = pkgs.appimage-run.override {
          extraPkgs = p: [
            p.webkitgtk_4_1
            p.gtk3
            p.glib
          ];
        };
      };
    };
}
