{
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.treefmt.withConfig {
        runtimeInputs = [
          pkgs.nixfmt
          pkgs.stylua
        ];

        settings = {
          tree-root-file = "flake.nix";

          formatter.nixfmt = {
            command = "nixfmt";
            includes = [ "*.nix" ];
          };

          formatter.stylua = {
            command = "stylua";
            options = [
              "--column-width=120"
              "--indent-type=Spaces"
              "--indent-width=4"
              "--quote-style=AutoPreferDouble"
            ];
            includes = [ "*.lua" ];
          };
        };
      };
    };
}
