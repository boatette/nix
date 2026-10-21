{ inputs, ... }:
{
  flake.modules.nixos.desktop.imports = with inputs.self.modules.nixos; [
    base

    session
    login
    plymouth
    fonts
    graphics
    bluetooth
    audio
    appimage
    localsend

    dolphin
    aion
  ];

  flake.modules.homeManager.desktop.imports = with inputs.self.modules.homeManager; [
    base

    kde
    appearance
    mime

    apps
    media
    prism

    foot
    konsole
    dolphin
    qutebrowser
    aion
  ];
}
