{
    flake = {
        homeModules.dev =
            { pkgs, ... }:
            {
                home.packages = with pkgs; [
                    gcc
                    gnumake
                    go
                    nodejs
                    python3
                    rustup
                    tree-sitter
                ];
            };

        nixosModules.base.environment.sessionVariables = {
            GOPATH = "$HOME/go";
            CARGO_HOME = "$HOME/.cargo";
        };
    };
}
