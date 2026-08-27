{
  flake.modules.homeManager.mime =
    { lib, ... }:
    let
      associations = lib.genAttrs [ "x-scheme-handler/claude-cli" ] (
        _: "claude-code-url-handler.desktop"
      );
    in
    {
      xdg.mimeApps = {
        defaultApplications = associations;
        associations.added = associations;
      };
    };
}
