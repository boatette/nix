{ inputs, ... }:
{
  flake.modules.nixos.aspire =
    { pkgs, ... }:
    let
      inherit (inputs.self.constants.fonts) mono sans;
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
