{ inputs, ... }:
{
  flake-file.inputs.rose-pine-rmpc = {
    url = "github:rose-pine/rmpc";
    flake = false;
  };

  flake.modules.nixos.rmpc.networking.firewall.allowedTCPPorts = [ 6600 ];

  flake.modules.homeManager.rmpc =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # replaces the previous notification instead of stacking one per track
      notify = pkgs.writeShellScript "rmpc-notify" ''
        state="$XDG_RUNTIME_DIR/rmpc-notify"
        cover="$state.jpg"
        id=$(cat "$state" 2>/dev/null || echo 0)

        icon=()
        if ${pkgs.rmpc}/bin/rmpc albumart --output "$cover" >/dev/null 2>&1; then
          icon=(--icon "$cover")
        fi

        ${pkgs.libnotify}/bin/notify-send --app-name rmpc --print-id --replace-id "$id" \
          "''${icon[@]}" "''${TITLE:-Unknown}" "''${ARTIST:-Unknown}" >"$state"
      '';
    in
    {
      services.mpd = {
        enable = true;
        musicDirectory = "${config.home.homeDirectory}/Music";
        # inside ~/Music so the ssd backup picks them up
        playlistDirectory = "${config.home.homeDirectory}/Music/Playlists";
        network = {
          startWhenNeeded = true;
          # for an MPD app on the phone; the firewall port is opened by the nixos module above
          listenAddress = "any";
        };

        # host_permissions can't name ::ffff:127.0.0.1, so local clients must arrive over plain IPv4.
        # the password stays out of the repo, in a file like: password "secret@read,add,control"
        extraConfig = ''
          audio_output {
            type "pipewire"
            name "PipeWire"
          }

          auto_update "yes"
          restore_paused "yes"

          host_permissions "127.0.0.1 read,add,control,admin"
          host_permissions "::1 read,add,control,admin"
          local_permissions "read,add,control,admin"
          default_permissions ""
          include_optional "${config.xdg.stateHome}/mpd/remote.conf"
        '';
      };

      # split the dual-stack listener so IPv4 clients aren't seen as ::ffff:127.0.0.1
      systemd.user.sockets.mpd.Socket = {
        BindIPv6Only = "ipv6-only";
        ListenStream = [ "0.0.0.0:6600" ];
      };

      services.mpd-mpris.enable = true;

      # mpd-mpris connects at login and would socket-start mpd, so only run it alongside mpd
      systemd.user.services.mpd-mpris = {
        Unit = {
          BindsTo = [ "mpd.service" ];
          After = [ "mpd.service" ];
        };
        Install.WantedBy = lib.mkForce [ "mpd.service" ];
      };

      home.packages = [ pkgs.cava ];

      xdg.configFile."rmpc/themes/rosepine-main.ron".source =
        "${inputs.rose-pine-rmpc}/rosepine-main/rmpc_default_no_border/themes/rosepine-main.ron";

      # the port's rmpc_default_no_border config.ron, plus a visualiser under the queue
      programs.rmpc = {
        enable = true;
        config = ''
          #![enable(implicit_some)]
          #![enable(unwrap_newtypes)]
          #![enable(unwrap_variant_newtypes)]
          (
              theme: "rosepine-main",
              on_song_change: ["${notify}"],
              album_art: (method: Sixel),
              cava: (
                  input: (method: Pipewire, source: "auto"),
              ),
              tabs: [
                  (
                      name: "Queue",
                      pane: Split(
                          direction: Horizontal,
                          panes: [
                              (size: "35%", pane: Pane(AlbumArt)),
                              (
                                  size: "65%",
                                  pane: Split(
                                      direction: Vertical,
                                      panes: [
                                          (
                                              size: "2",
                                              borders: "BOTTOM",
                                              pane: Split(
                                                  direction: Horizontal,
                                                  panes: [
                                                      (size: "1", pane: Pane(Empty())),
                                                      (size: "100%", pane: Pane(QueueHeader())),
                                                  ],
                                              ),
                                          ),
                                          (
                                              size: "70%",
                                              pane: Split(
                                                  direction: Horizontal,
                                                  panes: [
                                                      (size: "1", pane: Pane(Empty())),
                                                      (size: "100%", pane: Pane(Queue)),
                                                  ],
                                              ),
                                          ),
                                          (size: "30%", borders: "TOP", pane: Pane(Cava)),
                                      ],
                                  ),
                              ),
                          ],
                      ),
                  ),
                  (
                      name: "Directories",
                      borders: "ALL",
                      border_symbols: Rounded,
                      pane: Split(
                          size: "100%",
                          direction: Vertical,
                          panes: [(pane: Pane(Directories), size: "100%", borders: "NONE", border_symbols: Rounded)],
                      ),
                  ),
                  (
                      name: "Artists",
                      borders: "ALL",
                      border_symbols: Rounded,
                      pane: Split(
                          size: "100%",
                          direction: Vertical,
                          panes: [(pane: Pane(Artists), size: "100%", borders: "NONE", border_symbols: Rounded)],
                      ),
                  ),
                  (
                      name: "Album Artists",
                      borders: "ALL",
                      border_symbols: Rounded,
                      pane: Split(
                          size: "100%",
                          direction: Vertical,
                          panes: [(pane: Pane(AlbumArtists), size: "100%", borders: "NONE", border_symbols: Rounded)],
                      ),
                  ),
                  (
                      name: "Albums",
                      borders: "ALL",
                      border_symbols: Rounded,
                      pane: Split(
                          size: "100%",
                          direction: Vertical,
                          panes: [(pane: Pane(Albums), size: "100%", borders: "NONE", border_symbols: Rounded)],
                      ),
                  ),
                  (
                      name: "Playlists",
                      borders: "ALL",
                      border_symbols: Rounded,
                      pane: Split(
                          size: "100%",
                          direction: Vertical,
                          panes: [(pane: Pane(Playlists), size: "100%", borders: "NONE", border_symbols: Rounded)],
                      ),
                  ),
                  (
                      name: "Search",
                      borders: "ALL",
                      border_symbols: Rounded,
                      pane: Split(
                          size: "100%",
                          direction: Vertical,
                          panes: [(pane: Pane(Search), size: "100%", borders: "ALL", border_symbols: Rounded)],
                      ),
                  ),
              ],
          )
        '';
      };
    };
}
