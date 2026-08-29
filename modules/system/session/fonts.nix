{
  flake.modules.nixos.fonts =
    { config, pkgs, ... }:
    let
      inherit (config.constants.fonts) mono sans;
    in
    {
      fonts = {
        packages = with pkgs; [
          nerd-fonts.jetbrains-mono
          nerd-fonts.symbols-only
          inter
        ];

        fontconfig.defaultFonts = {
          monospace = [ mono.name ];
          sansSerif = [ sans.name ];
        };
      };
    };
}
