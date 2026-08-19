{
  plugins.lint = {
    enable = true;

    autoInstall.enable = false;

    lintersByFt = {
      cpp = [ "cpplint" ];
      kotlin = [ "ktlint" ];
      javascript = [ "eslint_d" ];
      javascriptreact = [ "eslint_d" ];
      markdown = [ "markdownlint-cli2" ];
      nix = [
        "statix"
        "deadnix"
      ];
      python = [ "ruff" ];
      typescript = [ "eslint_d" ];
      typescriptreact = [ "eslint_d" ];
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
}
