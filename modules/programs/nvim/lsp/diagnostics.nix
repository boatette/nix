{
  flake.modules.nixvim.nvim =
    { lib, ... }:
    let
      inherit (lib.nixvim) mkRaw;
    in
    {
      diagnostic.settings = {
        underline = true;
        update_in_insert = false;
        severity_sort = true;

        virtual_text.prefix = mkRaw ''
          function(diag)
              local icons = { ERROR = " 󰅚 ", WARN = " 󰀪 ", INFO = " 󰋽 ", HINT = " 󰌶 " }
              return icons[vim.diagnostic.severity[diag.severity]]
          end
        '';

        signs.text = mkRaw ''
          {
              [vim.diagnostic.severity.ERROR] = "󰅚 ",
              [vim.diagnostic.severity.WARN] = "󰀪 ",
              [vim.diagnostic.severity.INFO] = "󰋽 ",
              [vim.diagnostic.severity.HINT] = "󰌶 ",
          }
        '';
      };
    };
}
