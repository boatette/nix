{ inputs, ... }:
{
  flake.modules.nixos.desktop.imports = with inputs.self.modules.nixos; [
    base

    session
    greeter
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
    niri
  ];

  flake.modules.homeManager.desktop.imports = with inputs.self.modules.homeManager; [
    base

    kde
    appearance
    mime

    apps
    vm
    media
    rmpc
    prism
    bedrock

    foot
    konsole
    dolphin
    qutebrowser
    vesktop
    niri
    noctalia
    selector
    toothless
  ];
}
