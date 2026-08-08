{
    flake.nixosModules.base.environment.sessionVariables = {
        EDITOR = "nvim";
        SUDO_EDITOR = "nvim";

        GOPATH = "$HOME/go";
        CARGO_HOME = "$HOME/.cargo";

        MANROFFOPT = "-c";
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";

        PATH = [
            "$HOME/.local/bin"
            "$HOME/go/bin"
            "$HOME/.cargo/bin"
        ];
    };
}
