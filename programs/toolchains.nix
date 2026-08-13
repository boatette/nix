{
  flake.modules = {
    homeManager.dev =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          cargo
          clippy
          gcc
          gnumake
          go
          nodejs
          python3
          rustc
          rustfmt
          tree-sitter
        ];
      };

    nixos.base =
      { pkgs, ... }:
      {
        environment.sessionVariables = {
          GOPATH = "$HOME/go";
          CARGO_HOME = "$HOME/.cargo";
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        };
      };
  };
}
