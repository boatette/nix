{
  flake.modules.nixvim.core =
    { lib, ... }:
    let
      inherit (lib.nixvim) mkRaw;
    in
    {
      globals = {
        mapleader = " ";
        maplocalleader = " ";

        loaded_netrw = 1;
        loaded_netrwPlugin = 1;
        loaded_rplugin = 1;
        loaded_tarPlugin = 1;
        loaded_zipPlugin = 1;
      };

      opts = {
        number = true;
        relativenumber = true;
        signcolumn = "yes";
        termguicolors = true;
        laststatus = 3;

        cursorline = true;
        colorcolumn = "120";
        scrolloff = 8;
        sidescrolloff = 8;
        wrap = false;

        splitright = true;
        splitbelow = true;
        winborder = "rounded";

        updatetime = 50;
        timeoutlen = 500;

        expandtab = true;
        shiftwidth = 4;
        tabstop = 4;
        softtabstop = 4;
        smartindent = true;
        autoindent = true;
        breakindent = true;

        ignorecase = true;
        smartcase = true;
        inccommand = "split";

        completeopt = [
          "menu"
          "menuone"
          "noinsert"
        ];
        pumheight = 10;
        pumblend = 0;

        undofile = true;
        swapfile = false;
        backup = false;
        writebackup = false;
        confirm = true;
        autoread = true;

        foldenable = true;
        foldlevel = 99;
        foldlevelstart = 99;
        foldmethod = "expr";
        foldexpr = "v:lua.vim.treesitter.foldexpr()";

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

        grepprg = mkRaw ''vim.fn.executable("rg") == 1 and "rg --vimgrep --smart-case --hidden" or vim.o.grepprg'';
        grepformat = mkRaw ''vim.fn.executable("rg") == 1 and "%f:%l:%c:%m" or vim.o.grepformat'';
      };

      extraConfigLua = ''
        vim.schedule(function()
            vim.opt.clipboard = "unnamedplus"
        end)

        vim.opt.whichwrap:append("<>[]hl")
      '';
    };
}
