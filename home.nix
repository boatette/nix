{
    config,
    lib,
    pkgs,
    inputs,
    ...
}:

let
    repo = "${config.home.homeDirectory}/nix";
    dotfiles = "${repo}/config";
    create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

    configs = [
        "fastfetch"
        "fish"
        "foot"
        "niri"
        "noctalia"
        "nvim"
        "starship"
        "wayland-select"
        "zellij"
    ];

    starshipConfig = "${config.xdg.configHome}/starship/starship.toml";
in

{
    imports = [ inputs.nixCats.homeModule ];

    home.username = "boatette";
    home.homeDirectory = "/home/boatette";

    home.pointerCursor = {
        enable = true;
        package = pkgs.capitaine-cursors;
        name = "capitaine-cursors";
        size = 24;
        x11.enable = true;
        gtk.enable = true;
    };

    home.packages = with pkgs; [
        foot
        inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
        rustup

        nixfmt
        statix
        deadnix

        wl-clipboard
        libnotify

        bat
        eza
        dust
        fastfetch
        btop
        lm_sensors
        fzf
        fd
        ripgrep
        jq
        unzip
        zstd
        lazygit

        gcc
        gnumake
        go
        nodejs
        python3
        tree-sitter

        adw-gtk3
        nwg-look

        inputs.wayland-select.packages.${pkgs.stdenv.hostPlatform.system}.default

        capitaine-cursors
    ];

    programs.starship = {
        enable = true;
        configPath = starshipConfig;
    };

    programs.zoxide = {
        enable = true;
        options = [ "--cmd cd" ];
    };

    home.sessionVariables = {
        EDITOR = "nvim";
        SUDO_EDITOR = "nvim";

        GOPATH = "${config.home.homeDirectory}/go";
        CARGO_HOME = "${config.home.homeDirectory}/.cargo";

        MANROFFOPT = "-c";
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    };

    home.sessionPath = [
        "$HOME/.local/bin"
        "$HOME/go/bin"
        "$HOME/.cargo/bin"
    ];

    home.file.".local/bin".source = create_symlink "${repo}/.local/bin";

    xdg.configFile = lib.genAttrs configs (name: {
        source = create_symlink "${dotfiles}/${name}";
        recursive = true;
    });

    nixCats = {
        enable = true;

        nixpkgs_version = inputs.nixpkgs-unstable;
        addOverlays = [ (inputs.nixCats.utils.sanitizedPluginOverlay inputs) ];

        packageNames = [ "nvim" ];

        luaPath = ./config/nvim;

        categoryDefinitions.replace = (
            { pkgs, ... }:
            let
                pythonEnv = pkgs.python3.withPackages (ps: [ ps.debugpy ]);
            in
            {
                lspsAndRuntimeDeps = {
                    general = with pkgs; [
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

                        google-java-format
                        prettierd
                        shfmt
                        stylua

                        lldb
                        vscode-js-debug
                        pythonEnv
                    ];
                };

                startupPlugins = {
                    general = with pkgs.vimPlugins; [
                        mini-icons
                        snacks-nvim

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
                        pkgs.neovimPlugins.select-undo-nvim
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
                        nui-nvim

                        plenary-nvim
                        nvim-nio
                    ];
                };
            }
        );

        packageDefinitions.replace = {
            nvim =
                { pkgs, ... }:
                {
                    settings = {
                        suffix-path = true;
                        suffix-LD = true;
                        wrapRc = false;
                        neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
                    };
                    categories = {
                        general = true;
                    };
                };
        };
    };

    home.stateVersion = "26.05";
}
