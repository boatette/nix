{ config, ... }:

{
    home = {
        sessionVariables = {
            EDITOR = "nvim";
            SUDO_EDITOR = "nvim";

            GOPATH = "${config.home.homeDirectory}/go";
            CARGO_HOME = "${config.home.homeDirectory}/.cargo";

            MANROFFOPT = "-c";
            MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        };

        sessionPath = [
            "$HOME/.local/bin"
            "$HOME/go/bin"
            "$HOME/.cargo/bin"
        ];
    };
}
