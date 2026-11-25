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
          inter
          # only the JetBrainsMono Nerd Font family; the Mono, Propo and NL variants are 190M of its 230M
          (nerd-fonts.jetbrains-mono.overrideAttrs {
            postInstall = "find $out -name '*.ttf' ! -name 'JetBrainsMonoNerdFont-*' -delete";
          })
          nerd-fonts.symbols-only
        ];

        fontconfig.defaultFonts = {
          monospace = [ mono.name ];
          sansSerif = [ sans.name ];
        };
      };
    };
}
