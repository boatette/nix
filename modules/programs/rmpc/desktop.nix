{
  # launch in foot with its own app-id so window rules can tell it apart from other terminals
  flake.modules.homeManager.rmpc =
    { config, lib, ... }:
    {
      xdg.desktopEntries.rmpc = {
        name = "rmpc";
        genericName = "Music Player";
        comment = "Terminal MPD client";
        exec = "${lib.getExe config.programs.foot.package} --app-id=rmpc rmpc";
        icon = "multimedia-audio-player";
        terminal = false;
        categories = [
          "AudioVideo"
          "Audio"
          "Player"
        ];
      };
    };
}
