{
  lib,
  symlinkJoin,
  makeWrapper,
  runCommand,
  fish,
  starship,
  zoxide,
  eza,
  bat,
  fzf,
  ripgrep,
  fd,
  jq,
  zellij,
  yazi,
  git,
  lazygit,

  backup,
  copy,
  extract,
  nsh,
  nrun,
  psg,

  serve,
  unowned,
  open-zellij,
  prune-small,
}:

let
  flakeDir = "$HOME/nix";

  aliases = import ./_aliases.nix { inherit flakeDir; };

  onPath = [
    starship
    zoxide
    eza
    bat
    fzf
    ripgrep
    fd
    jq
    zellij
    yazi
    git
    lazygit

    backup
    copy
    extract
    nsh
    nrun
    psg

    serve
    unowned
    open-zellij
    prune-small
  ];

  conf = runCommand "shell-env-conf" { } ''
    mkdir -p $out/share/fish/vendor_conf.d
    cat > $out/share/fish/vendor_conf.d/00-shell-env.fish <<'CONF'
    ${builtins.readFile ./_init.fish}

    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        name: value: "alias ${lib.escapeShellArg name}=${lib.escapeShellArg value}"
      ) aliases
    )}
    CONF
    cat >> $out/share/fish/vendor_conf.d/00-shell-env.fish <<CONF
    ${lib.getExe zoxide} init fish --cmd cd | source
    ${lib.getExe starship} init fish | source
    CONF
  '';
in
symlinkJoin {
  name = "shell-env";
  paths = [ fish ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/fish \
        --prefix PATH : ${lib.makeBinPath onPath} \
        --prefix XDG_DATA_DIRS : ${conf}/share
  '';

  meta = {
    description = "This config's fish shell, with its aliases, functions and tools";
    mainProgram = "fish";
  };
}
