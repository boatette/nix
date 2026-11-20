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
    luciole
    rmpc
    searxng
    umbriel
  ];

  flake.modules.homeManager.desktop.imports = with inputs.self.modules.homeManager; [
    base

    appearance
    mime

    apps
    vm
    media
    rmpc
    prism
    bedrock

    foot
    luciole
    qutebrowser
    vesktop
    umbriel
    noctalia
    selector
    toothless
  ];
}
