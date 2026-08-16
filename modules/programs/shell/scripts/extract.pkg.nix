{
  writeShellApplication,
  gnutar,
  gzip,
  bzip2,
  xz,
  zstd,
  unzip,
  p7zip,
}:

writeShellApplication {
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
}
