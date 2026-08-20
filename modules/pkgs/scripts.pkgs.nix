{
  writeShellApplication,

  coreutils,
  findutils,
  gawk,
  gnused,
  gnutar,
  gzip,
  bzip2,
  xz,
  zstd,
  unzip,
  p7zip,

  curl,
  ffmpeg,
  fzf,
  gh,
  imagemagick,
  libwebp,
  python3,
  zellij,
  zoxide,
}:

let
  fromFile =
    name: description: runtimeInputs:
    writeShellApplication {
      inherit name runtimeInputs;
      meta.description = description;

      bashOptions = [ ];
      text = builtins.readFile (./scripts + "/${name}.sh");
    };
in

rec {
  backup = writeShellApplication {
    name = "backup";
    meta.description = "copy a file to <file>.bak";
    text = ''
      cp -- "$1" "$1.bak"
    '';
  };

  copy = writeShellApplication {
    name = "copy";
    meta.description = "cp, recursing automatically when the source is a directory";
    text = ''
      if [ "$#" -eq 2 ] && [ -d "$1" ]; then
          cp -r "''${1%/}" "$2"
      else
          cp "$@"
      fi
    '';
  };

  extract = writeShellApplication {
    name = "extract";
    meta.description = "unpack an archive by extension";

    runtimeInputs = [
      gnutar
      gzip
      bzip2
      xz
      zstd
      unzip
      p7zip
    ];

    text = ''
      file="$1"

      if [ ! -f "$file" ]; then
          echo "'$file' is not a valid file" >&2
          exit 1
      fi

      case "$file" in
          *.tar.bz2 | *.tbz2) tar xjf "$file" ;;
          *.tar.gz | *.tgz)   tar xzf "$file" ;;
          *.tar.xz)           tar xJf "$file" ;;
          *.tar.zst)          tar --zstd -xf "$file" ;;
          *.tar)              tar xvf "$file" ;;
          *.bz2)              bunzip2 "$file" ;;
          *.gz)               gunzip "$file" ;;
          *.rar)              unrar x "$file" ;;
          *.zip)              unzip "$file" ;;
          *.Z)                uncompress "$file" ;;
          *.7z)               7z x "$file" ;;
          *)
              echo "'$file' cannot be extracted via extract" >&2
              exit 1
              ;;
      esac
    '';
  };

  nsh = writeShellApplication {
    name = "nsh";
    meta.description = "open a shell with packages from nixpkgs";
    text = ''
      args=()
      for p in "$@"; do
          args+=("nixpkgs#$p")
      done
      exec nix shell "''${args[@]}"
    '';
  };

  nrun = writeShellApplication {
    name = "nrun";
    meta.description = "run a package from nixpkgs without installing";
    text = ''
      pkg="$1"
      shift
      exec nix run "nixpkgs#$pkg" -- "$@"
    '';
  };

  psg = writeShellApplication {
    name = "psg";
    meta.description = "grep the process list without matching the grep itself";
    text = ''
      # shellcheck disable=SC2009
      ps aux | grep -v grep | grep -i -- "$@"
    '';
  };

  paths = writeShellApplication {
    name = "paths";
    meta.description = "print PATH one entry per line";
    text = ''
      printf '%s' "$PATH" | tr ':' '\n'
    '';
  };

  serve = writeShellApplication {
    name = "serve";
    meta.description = "serve the current dir over http, default port 8000";
    runtimeInputs = [ python3 ];
    text = ''
      exec python3 -m http.server "''${1:-8000}"
    '';
  };

  unowned = writeShellApplication {
    name = "unowned";
    meta.description = "find files not owned by the user";
    text = ''
      find "$@" -not -user "$(whoami)"
    '';
  };

  open-zellij =
    fromFile "open-zellij" "pick a directory with fzf, then attach or start a zellij session there"
      [
        zellij
        zoxide
        fzf
      ];

  prune-small = fromFile "prune-small" "list or delete wallpapers below a minimum resolution" [
    imagemagick
    findutils
  ];

  walls-optimise = fromFile "walls-optimise" "recompress wallpapers to WebP for distribution" [
    libwebp
    ffmpeg
    coreutils
    findutils
    gnused
    gawk
  ];

  walls-pack = fromFile "walls-pack" "build one release tarball per wallpaper theme" [
    walls-optimise
    gnutar
    zstd
    coreutils
  ];

  walls-push = fromFile "walls-push" "publish packed wallpaper tarballs as a dated release" [
    gh
    curl
    coreutils
    findutils
  ];

  walls-pull = fromFile "walls-pull" "fetch wallpapers from the latest GitHub release" [
    curl
    gnutar
    zstd
    coreutils
  ];
}
