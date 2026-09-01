{
  flake.modules.homeManager.archive-tools =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ouch
        gnutar
        gzip
        bzip2
        xz
        zstd
        unzip
        p7zip
      ];
    };
}
