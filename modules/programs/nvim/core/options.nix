{
  flake.modules.nvf.core =
    { lib, ... }:
    let
      inherit (lib.generators) mkLuaInline;
      inherit (lib.nvim.dag) entryAfter;
    in
    {
      vim = {
        searchCase = "smart";

        globals = {
          maplocalleader = " ";

          loaded_netrw = 1;
          loaded_netrwPlugin = 1;
          loaded_rplugin = 1;
          loaded_tarPlugin = 1;
          loaded_zipPlugin = 1;
        };

        options = {
          laststatus = 3;

          cursorline = true;
          colorcolumn = "120";
          scrolloff = 8;
          sidescrolloff = 8;
          wrap = false;

          winborder = "rounded";

          updatetime = 250;

          shiftwidth = 4;
          tabstop = 4;
          softtabstop = 4;
          smartindent = true;
          breakindent = true;

          inccommand = "split";

          completeopt = [
            "menu"
            "menuone"
            "noinsert"
          ];
          pumheight = 10;

          undofile = true;
          confirm = true;

          foldlevel = 99;
          foldlevelstart = 99;

          list = true;
          listchars = {
            tab = "→ ";
            trail = "·";
            extends = "⟩";
            precedes = "⟨";
          };
          fillchars = {
            foldopen = "▾";
            foldclose = "▸";
            eob = " ";
          };

          mouse = "a";
          whichwrap = "b,s,<,>,[,],h,l";

          grepprg = mkLuaInline ''vim.fn.executable("rg") == 1 and "rg --vimgrep --smart-case --hidden" or vim.o.grepprg'';
        };

        luaConfigRC.core-options = entryAfter [ "optionsScript" ] ''
          vim.schedule(function()
              vim.opt.clipboard = "unnamedplus"
          end)
        '';
      };
    };
}
