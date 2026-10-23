{
  # compilers come from per-project devshells; this only sets where their installs land
  flake.modules.homeManager.toolchains =
    { config, ... }:
    {
      home = {
        sessionVariables.GOPATH = "${config.xdg.dataHome}/go";

        sessionPath = [
          "${config.home.sessionVariables.GOPATH}/bin"
          "$HOME/.cargo/bin"
        ];
      };
    };
}
