{ inputs, ... }:
{
  flake.modules.homeManager.mime =
    { pkgs, lib, ... }:
    let
      archives = [
        "application/zip"
        "application/gzip"
        "application/bzip2"
        "application/zstd"
        "application/vnd.rar"
        "application/x-7z-compressed"
        "application/x-7z-compressed-tar"
        "application/x-bzip"
        "application/x-bzip-compressed-tar"
        "application/x-bzip2-compressed-tar"
        "application/x-compress"
        "application/x-compressed-tar"
        "application/x-cpio"
        "application/x-lha"
        "application/x-lzip"
        "application/x-lzip-compressed-tar"
        "application/x-lzma"
        "application/x-lzma-compressed-tar"
        "application/x-rar-compressed"
        "application/x-tar"
        "application/x-tarz"
        "application/x-xar"
        "application/x-xz"
        "application/x-xz-compressed-tar"
        "application/x-zstd-compressed-tar"
      ];
    in
    lib.mkMerge [
      (inputs.self.lib.mimeHandlers { "extract-here.desktop" = archives; })

      {
        xdg.mimeApps.enable = true;

        xdg.desktopEntries.extract-here = {
          name = "Extract Here";
          exec = "${lib.getExe pkgs.file-roller} --extract-here %U";
          icon = "package-x-generic";
          terminal = false;
          noDisplay = true;
          mimeType = archives;
        };

        home.packages = with pkgs; [
          file-roller
          p7zip
        ];
      }
    ];
}
