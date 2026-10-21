{
  flake.modules.nvf.nvim =
    { lib, ... }:
    let
      inherit (lib.generators) mkLuaInline;
    in
    {
      vim.diagnostics = {
        enable = true;

        config = {
          underline = true;
          update_in_insert = false;
          severity_sort = true;

          virtual_text.prefix = mkLuaInline ''
            function(diag)
                local icons = { ERROR = " 󰅚 ", WARN = " 󰀪 ", INFO = " 󰋽 ", HINT = " 󰌶 " }
                return icons[vim.diagnostic.severity[diag.severity]]
            end
          '';

          signs.text = mkLuaInline ''
            {
                [vim.diagnostic.severity.ERROR] = "󰅚 ",
                [vim.diagnostic.severity.WARN] = "󰀪 ",
                [vim.diagnostic.severity.INFO] = "󰋽 ",
                [vim.diagnostic.severity.HINT] = "󰌶 ",
            }
          '';
        };
      };
    };
}
