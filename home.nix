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
    home.username = "boatette";
    home.homeDirectory = "/home/boatette";

    home.packages = with pkgs; [
        foot
        inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default
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

    programs.fish.enable = true;

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

    xdg.configFile =
        lib.genAttrs configs (name: {
            source = create_symlink "${dotfiles}/${name}";
            recursive = true;
        })
        // {
            "fish/conf.d".source = create_symlink "${dotfiles}/fish/conf.d";
            "fish/functions".source = create_symlink "${dotfiles}/fish/functions";
        };

    home.stateVersion = "26.05";
}
