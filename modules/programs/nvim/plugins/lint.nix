{
  flake.modules.nixvim.nvim =
    { pkgs, ... }:
    {
      extraPackages = with pkgs; [
        cpplint
        deadnix
        eslint_d
        golangci-lint
        ktlint
        markdownlint-cli2
        ruff
        shellcheck
        statix
      ];

      plugins.lint = {
        enable = true;
        autoInstall.enable = false;

        lintersByFt = {
          bash = [ "shellcheck" ];
          sh = [ "shellcheck" ];

          cpp = [ "cpplint" ];
          go = [ "golangcilint" ];
          kotlin = [ "ktlint" ];
          markdown = [ "markdownlint-cli2" ];
          python = [ "ruff" ];

          javascript = [ "eslint_d" ];
          javascriptreact = [ "eslint_d" ];
          typescript = [ "eslint_d" ];
          typescriptreact = [ "eslint_d" ];

          nix = [
            "statix"
            "deadnix"
          ];
        };

        autoCmd = {
          event = [
            "BufWritePost"
            "BufReadPost"
            "InsertLeave"
          ];
          desc = "Auto-lint on save and text change";
        };
      };
    };
}
