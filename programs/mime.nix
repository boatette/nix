{
  flake.modules.homeManager.desktop =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      handlers = {
        "nemo.desktop" = [
          "inode/directory"
          "application/x-gnome-saved-search"
        ];

        "extract-here.desktop" = [
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

        "qimgv.desktop" = [
          "image/avif"
          "image/bmp"
          "image/gif"
          "image/heif"
          "image/jp2"
          "image/jpeg"
          "image/jxl"
          "image/png"
          "image/svg+xml"
          "image/tiff"
          "image/vnd.microsoft.icon"
          "image/webp"
          "image/x-icns"
          "image/x-icon"
          "image/x-portable-bitmap"
          "image/x-portable-graymap"
          "image/x-portable-pixmap"
          "image/x-tga"
        ];

        "gimp.desktop" = [
          "image/x-xcf"
          "image/openraster"
          "image/x-psd"
        ];

        "mpv.desktop" = [
          "application/mxf"
          "application/x-matroska"
          "audio/x-mpegurl"
          "application/vnd.apple.mpegurl"
          "video/3gpp"
          "video/mp2t"
          "video/mp4"
          "video/mpeg"
          "video/ogg"
          "video/quicktime"
          "video/vnd.avi"
          "video/webm"
          "video/x-flv"
          "video/x-m4v"
          "video/x-matroska"
          "video/x-ms-wmv"
          "video/x-msvideo"
        ];

        "io.bassi.Amberol.desktop" = [
          "audio/aac"
          "audio/flac"
          "audio/mp4"
          "audio/mpeg"
          "audio/ogg"
          "audio/opus"
          "audio/wav"
          "audio/x-aac"
          "audio/x-aiff"
          "audio/x-ape"
          "audio/x-flac"
          "audio/x-m4a"
          "audio/x-opus+ogg"
          "audio/x-vorbis+ogg"
          "audio/x-wav"
          "audio/x-wavpack"
        ];

        "zen-beta.desktop" = [
          "application/pdf"
          "application/xhtml+xml"
          "application/x-extension-htm"
          "application/x-extension-html"
          "application/x-extension-shtml"
          "application/x-extension-xht"
          "application/x-extension-xhtml"
          "text/html"
          "x-scheme-handler/chrome"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
        ];

        "nvim.desktop" = [
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

        "writer.desktop" = [
          "application/msword"
          "application/rtf"
          "application/vnd.oasis.opendocument.text"
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        ];

        "calc.desktop" = [
          "application/vnd.ms-excel"
          "application/vnd.oasis.opendocument.spreadsheet"
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          "text/csv"
        ];

        "impress.desktop" = [
          "application/vnd.ms-powerpoint"
          "application/vnd.oasis.opendocument.presentation"
          "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        ];

        "org.prismlauncher.PrismLauncher.desktop" = [
          "application/x-modrinth-modpack+zip"
          "x-scheme-handler/curseforge"
          "x-scheme-handler/prismlauncher"
        ];

        "vesktop.desktop" = [ "x-scheme-handler/discord" ];

        "claude-code-url-handler.desktop" = [ "x-scheme-handler/claude-cli" ];
      };

      associations = lib.concatMapAttrs (desktop: types: lib.genAttrs types (_: desktop)) handlers;
    in
    {
      home.packages = with pkgs; [
        file-roller
        p7zip
      ];

      xdg = {
        mimeApps = {
          enable = true;
          defaultApplications = associations;
          associations.added = associations;
        };

        desktopEntries.extract-here = {
          name = "Extract Here";
          exec = "${lib.getExe pkgs.file-roller} --extract-here %U";
          icon = "package-x-generic";
          terminal = false;
          noDisplay = true;
          mimeType = handlers."extract-here.desktop";
        };

        desktopEntries.nvim = {
          name = "Neovim";
          genericName = "Text Editor";
          comment = "Edit text files";
          exec = "${lib.getExe config.programs.foot.package} nvim %F";
          icon = "nvim";
          terminal = false;
          categories = [
            "Utility"
            "TextEditor"
            "Development"
          ];
          mimeType = handlers."nvim.desktop";
        };
      };
    };
}
