{
  flake.modules.homeManager.mime =
    {
      config,
      lib,
      ...
    }:
    let
      types = [
        "application/json"
        "application/toml"
        "application/x-shellscript"
        "application/xml"
        "text/markdown"
        "text/plain"
        "text/x-c"
        "text/x-c++"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-makefile"
        "text/x-python"
      ];

      associations = lib.genAttrs types (_: "nvim.desktop");
    in
    {
      xdg = {
        mimeApps.defaultApplications = associations;
        mimeApps.associations.added = associations;

        desktopEntries.nvim = {
          name = "Neovim";
          genericName = "Text Editor";
          comment = "Edit text files";
          exec = "${lib.getExe config.programs.ghostty.package} nvim %F";
          icon = "nvim";
          terminal = false;
          categories = [
            "Utility"
            "TextEditor"
            "Development"
          ];
          mimeType = types;
        };
      };
    };
}
