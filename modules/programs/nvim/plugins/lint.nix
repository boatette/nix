{
  flake.modules.nvf.nvim =
    { lib, pkgs, ... }:
    let
      inherit (lib.generators) mkLuaInline;
    in
    {
      vim = {
        extraPackages = with pkgs; [
          cpplint
          deadnix
          eslint_d
          golangci-lint
          ktlint
          markdownlint-cli2
          statix
        ];

        diagnostics.nvim-lint = {
          enable = true;

          linters_by_ft = {
            cpp = [ "cpplint" ];
            go = [ "golangcilint" ];
            kotlin = [ "ktlint" ];
            markdown = [ "markdownlint-cli2" ];

            nix = [
              "statix"
              "deadnix"
            ];
          }
          // lib.genAttrs [
            "javascript"
            "javascriptreact"
            "typescript"
            "typescriptreact"
          ] (_: [ "eslint_d" ]);

          lint_after_save = false;
        };

        autocmds = [
          {
            event = [
              "BufWritePost"
              "BufReadPost"
            ];
            desc = "Auto-lint on read and save";
            # golangci-lint checks the whole package, too slow to run on every open
            callback = mkLuaInline ''
              function(args)
                  if args.event == "BufReadPost" and vim.bo[args.buf].filetype == "go" then
                      return
                  end
                  nvf_lint(args.buf)
              end
            '';
          }
        ];
      };
    };

}
