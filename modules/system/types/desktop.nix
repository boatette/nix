{ inputs, ... }:
{

  flake.modules.nixos.desktop.imports = with inputs.self.modules.nixos; [
    base

    session
    greeter
    plymouth
    fonts
    graphics
    bluetooth
    audio
    fingerprint
    appimage
    localsend

    dolphin
    noctalia
    niri
  ];

  flake.modules.homeManager.desktop.imports = with inputs.self.modules.homeManager; [
    base

    appearance
    mime

    apps
    media
    prism
    selector

    foot
    ghostty
    konsole
    dolphin
    zen
    noctalia
    niri
  ];
}
