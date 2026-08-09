{
    inputs,
    configDirectory,
}:

{
    config,
    options,
    pkgs,
    lib,
    ...
}:

let
    inherit (pkgs.stdenv.hostPlatform) system;

    plugins = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
in
{
    options.nvim-lib.pluginsFromPrefix = lib.mkOption {
        type = lib.types.raw;
        readOnly = true;
        default =
            prefix: attrs:
            lib.pipe attrs [
                builtins.attrNames
                (builtins.filter (lib.hasPrefix prefix))
                (map (input: {
                    name = lib.removePrefix prefix input;
                    value = config.nvim-lib.mkPlugin (lib.removePrefix prefix input) attrs.${input};
                }))
                builtins.listToAttrs
            ];
    };

    config = {
        package = inputs.neovim-nightly-overlay.packages.${system}.neovim;

        settings.config_directory = configDirectory;

        hosts = {
            python3.nvim-host.enable = false;
            node.nvim-host.enable = false;
            ruby.nvim-host.enable = false;
        };

        specMods = {
            options.runtimePkgs = options.runtimePkgs // {
                description = ''
                    Packages this spec puts on nvim's PATH.
                    Dropped from the derivation when the spec is disabled.
                '';
            };
        };

        runtimePkgs = config.specCollect (acc: spec: acc ++ (spec.runtimePkgs or [ ])) [ ];

        specs = with pkgs.vimPlugins; {
            libs = [
                plenary-nvim
                nvim-nio
                nui-nvim
            ];

            ui = [
                mini-icons
                snacks-nvim
                bufferline-nvim
                markview-nvim
                todo-comments-nvim
                trouble-nvim
            ];

            editing = [
                mini-ai
                mini-hipatterns
                mini-splitjoin
                mini-surround
                mini-snippets
                dial-nvim
                nvim-spider
                undotree
            ];

            files = [
                oil-nvim
                harpoon2
            ];

            completion = [
                blink-lib
                blink-cmp
            ];

            treesitter = [
                nvim-treesitter.withAllGrammars
                nvim-treesitter-context
            ];

            colourschemes = [
                catppuccin-nvim
                kanagawa-nvim
                nord-nvim
                rose-pine
                tokyonight-nvim
                mini-base16
                plugins.everforest-nvim
                plugins.github-monochrome-nvim
            ];

            lsp = nvim-lspconfig;
            format = conform-nvim;
            lint = nvim-lint;
            test = neotest;

            debug = {
                data = [
                    nvim-dap
                    nvim-dap-view
                ];
                runtimePkgs = [ pkgs.lldb ];
            };

            c = {
                data = null;
                runtimePkgs = with pkgs; [
                    clang-tools
                    cpplint
                ];
            };

            dart.data = [
                flutter-tools-nvim
                neotest-dart
            ];

            fish = {
                data = null;
                runtimePkgs = [ pkgs.fish-lsp ];
            };

            glsl = {
                data = null;
                runtimePkgs = [ pkgs.glsl_analyzer ];
            };

            java = {
                data = nvim-java;
                runtimePkgs = with pkgs; [
                    jdt-language-server
                    google-java-format
                ];
            };

            javascript = {
                data = null;
                runtimePkgs = with pkgs; [
                    typescript-language-server
                    vscode-langservers-extracted
                    eslint_d
                    prettierd
                    vscode-js-debug
                ];
            };

            kotlin = {
                data = null;
                runtimePkgs = [ pkgs.ktlint ];
            };

            lua = {
                data = null;
                runtimePkgs = with pkgs; [
                    lua-language-server
                    stylua
                ];
            };

            markdown = {
                data = null;
                runtimePkgs = [ pkgs.markdownlint-cli2 ];
            };

            nix = {
                data = null;
                runtimePkgs = with pkgs; [
                    nixd
                    nixfmt
                    statix
                    deadnix
                ];
            };

            odin = {
                data = null;
                runtimePkgs = [ pkgs.ols ];
            };

            python = {
                data = null;
                runtimePkgs = with pkgs; [
                    pyright
                    ruff
                    (python3.withPackages (ps: [ ps.debugpy ]))
                ];
            };

            qml = {
                data = null;
                runtimePkgs = [ pkgs.kdePackages.qtdeclarative ];
            };

            rust = {
                data = [
                    rustaceanvim
                    neotest-rust
                ];
                runtimePkgs = [ pkgs.rust-analyzer ];
            };

            shell = {
                data = null;
                runtimePkgs = with pkgs; [
                    bash-language-server
                    shfmt
                ];
            };

            zig = {
                data = neotest-zig;
                runtimePkgs = [ pkgs.zls ];
            };
        };
    };
}
