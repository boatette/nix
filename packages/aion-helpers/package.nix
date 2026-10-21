{
  lib,
  symlinkJoin,
  writeShellApplication,
  coreutils,
  findutils,
  gawk,
  git,
  glib,
  gnugrep,
  libnotify,
  systemd,
  swaylock,
  wireplumber,
  brightnessctl,
  grim,
  slurp,
  wl-clipboard,
}:
let
  script =
    name: description: runtimeInputs:
    writeShellApplication {
      inherit name runtimeInputs;
      meta.description = description;
      text = builtins.readFile ./${lib.removePrefix "aion-" name}.sh;
    };
in
symlinkJoin {
  name = "aion-helpers";
  meta.description = "small scripts the aion session binds to keys";

  paths = [
    (script "aion-status" "status text for the aion bar, one line every 30 s" [ coreutils ])
    (script "aion-updates" "flag the bar when nixos-unstable is ahead of the running system" [
      coreutils
      git
    ])
    (script "aion-power" "lock, suspend, log out, reboot or shut down, given as the argument" [
      coreutils
      systemd
      swaylock
    ])
    (script "aion-apps" "list desktop entries for the bar launcher, or launch one" [
      coreutils
      findutils
      gawk
      glib
    ])
    (script "aion-caffeine" "toggle swayidle" [
      systemd
      libnotify
    ])
    (script "aion-volume" "change volume or mute, with a notification" [
      coreutils
      gnugrep
      wireplumber
      libnotify
    ])
    (script "aion-brightness" "change backlight brightness, with a notification" [
      coreutils
      brightnessctl
      libnotify
    ])
    (script "aion-screenshot" "screenshot the whole desktop or a region to file and clipboard" [
      coreutils
      grim
      slurp
      wl-clipboard
      libnotify
    ])
  ];
}
