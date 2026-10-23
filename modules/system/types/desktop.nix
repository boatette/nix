{ inputs, ... }:
{
  flake.modules.nixos.desktop.imports = with inputs.self.modules.nixos; [
    base

    session
    login
    console
    plymouth
    fonts
    graphics
    bluetooth
    audio
    appimage
    localsend
    rmpc

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
    rmpc
    prism

    foot
    konsole
    dolphin
    qutebrowser
    vesktop
    aion
  ];
}
