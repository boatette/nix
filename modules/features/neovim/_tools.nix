{ pkgs, ... }:

with pkgs;
[
    bash-language-server
    clang-tools
    fish-lsp
    glsl_analyzer
    jdt-language-server
    lua-language-server
    nixd
    ols
    pyright
    ruff
    rust-analyzer
    typescript-language-server
    vscode-langservers-extracted
    zls
    kdePackages.qtdeclarative

    cpplint
    eslint_d
    ktlint
    markdownlint-cli2
    statix
    deadnix

    google-java-format
    prettierd
    shfmt
    stylua
    nixfmt

    lldb
    vscode-js-debug
    (python3.withPackages (ps: [ ps.debugpy ]))

]
