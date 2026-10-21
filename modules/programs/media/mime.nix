{ inputs, ... }:
{
  flake.modules.homeManager.mime = inputs.self.lib.mimeHandlers {
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

    "mpv.desktop" = [
      "application/mxf"
      "application/vnd.apple.mpegurl"
      "application/x-matroska"
      "audio/x-mpegurl"
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
  };
}
