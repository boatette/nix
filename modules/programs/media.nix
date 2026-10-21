{
  flake.modules.homeManager.media =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ffmpeg
        libwebp

        qimgv
        mpv
        # FIX: remove on upstream fix
        # nixpkgs' reuse currently fails to produce its man output; amberol
        # only needs the binary at build time, so skip the docs.
        (amberol.override {
          reuse = python3Packages.reuse.overridePythonAttrs {
            outputs = [ "out" ];
            sphinxBuilders = [ ];
          };
        })
      ];
    };
}
