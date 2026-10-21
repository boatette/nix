{
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.treefmt.withConfig {
        runtimeInputs = [
          pkgs.nixfmt
          pkgs.stylua
          pkgs.prettier
          pkgs.shfmt
          pkgs.ruff
          pkgs.taplo
        ];

        settings = {
          tree-root-file = "flake.nix";

          formatter = {
            nixfmt = {
              command = "nixfmt";
              includes = [ "*.nix" ];
            };

            stylua = {
              command = "stylua";
              includes = [ "*.lua" ];
            };

            prettier = {
              command = "prettier";
              options = [ "--write" ];
              includes = [
                "*.md"
                "*.html"
                "*.css"
                "*.js"
                "*.mjs"
                "*.ts"
                "*.json"
                "*.jsonc"
                "*.yaml"
                "*.yml"
              ];
            };

            shfmt = {
              command = "shfmt";
              options = [ "-w" ];
              includes = [
                "*.sh"
                "*.bash"
              ];
            };

            ruff-format = {
              command = "ruff";
              options = [ "format" ];
              includes = [ "*.py" ];
            };

            ruff-isort = {
              command = "ruff";
              options = [
                "check"
                "--select"
                "I"
                "--fix"
              ];
              includes = [ "*.py" ];
              priority = -1;
            };

            taplo = {
              command = "taplo";
              options = [ "format" ];
              includes = [ "*.toml" ];
            };
          };
        };
      };
    };
}
