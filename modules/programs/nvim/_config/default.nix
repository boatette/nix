{ inputs }:

{ ... }:

{
  imports = [
    ./options.nix
    ./keymaps.nix
    ./autocmds.nix
    ./ftplugin.nix
    ./ui.nix
    ./editing.nix
    ./files.nix
    ./completion.nix
    ./treesitter.nix
    ./lsp.nix
    ./format.nix
    ./lint.nix
    ./test.nix
    ./debug.nix
    ./colourscheme.nix
    ./languages.nix
  ];

  _module.args.inputs = inputs;

  wrapRc = true;
  performance.byteCompileLua.enable = true;

  extraConfigLua = ''
    vim.loader.enable()
    pcall(function()
        require("vim._core.ui2").enable()
    end)
  '';
}
