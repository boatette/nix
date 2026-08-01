{ pkgs, ... }:

with pkgs.vimPlugins;
[
    mini-icons
    snacks-nvim
    plenary-nvim
    nvim-nio
    nui-nvim

    catppuccin-nvim
    pkgs.neovimPlugins.everforest-nvim
    kanagawa-nvim
    pkgs.neovimPlugins.github-monochrome-nvim
    nord-nvim
    rose-pine
    tokyonight-nvim
    mini-base16

    mini-ai
    mini-hipatterns
    mini-splitjoin
    mini-surround
    mini-snippets
    dial-nvim
    nvim-spider
    undotree

    oil-nvim
    harpoon2
    bufferline-nvim
    todo-comments-nvim
    markview-nvim

    blink-lib
    blink-cmp

    nvim-lspconfig
    nvim-lint
    conform-nvim
    trouble-nvim

    nvim-treesitter.withAllGrammars
    nvim-treesitter-context

    nvim-dap
    nvim-dap-view

    neotest
    neotest-rust
    neotest-zig
    neotest-dart

    rustaceanvim
    flutter-tools-nvim
    nvim-java
]
