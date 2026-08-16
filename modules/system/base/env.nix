{
  flake.modules.nixos.base.environment.sessionVariables.PATH = [
    "$HOME/.local/bin"
    "$HOME/go/bin"
    "$HOME/.cargo/bin"
  ];
}
