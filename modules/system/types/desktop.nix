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

    dolphin
    localsend
    luciole
    rmpc
    umbriel
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
    luciole
    qutebrowser
    vesktop
    umbriel
    noctalia
    selector
    toothless
  ];
}
