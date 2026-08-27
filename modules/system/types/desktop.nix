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
    umbriel
  ];

  flake.modules.homeManager.desktop.imports = with inputs.self.modules.homeManager; [
    base

    appearance
    mime

    apps
    media
    prism
    selector

    ghostty
    konsole
    dolphin
    zen
    noctalia
    umbriel
  ];
}
