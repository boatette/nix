{
  flake.modules.nixos.session-path.environment.sessionVariables.PATH = [
    "$HOME/.local/bin"
    "$HOME/go/bin"
    "$HOME/.cargo/bin"
  ];
}
