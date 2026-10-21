{
  flake.modules.homeManager.toolchains =
    { pkgs, config, ... }:
    {
      home = {
        packages = with pkgs; [
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
          zig
        ];

        sessionVariables = {
          GOPATH = "${config.xdg.dataHome}/go";
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        };

        sessionPath = [
          "${config.home.sessionVariables.GOPATH}/bin"
          "$HOME/.cargo/bin"
        ];
      };
    };
}
