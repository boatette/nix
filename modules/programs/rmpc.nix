let
  port = 6600;
  fifo = "/tmp/mpd.fifo";
in
{
  flake.modules.nixos.aspire.networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ port ];

  flake.modules.homeManager.boatette =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      browseTab = name: pane: borders: ''
        (
            name: "${name}",
            borders: "ALL",
            border_symbols: Rounded,
            pane: Split(
                size: "100%",
                direction: Vertical,
                panes: [(pane: Pane(${pane}), size: "100%", borders: "${borders}", border_symbols: Rounded)],
            ),
        ),
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
          # for an mpd app on the phone, over the tailnet
          listenAddress = "any";
        };

        # remote.conf keeps the phone's password out of the repo: password "secret@read,add,control"
        extraConfig = ''
          audio_output {
            type "pipewire"
            name "PipeWire"
          }

          # cava reads this instead of pipewire, which may have no sink yet when rmpc starts
          audio_output {
            type "fifo"
            name "Visualiser"
            path "${fifo}"
            format "44100:16:2"
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

      # host_permissions can't name ::ffff:127.0.0.1, so ipv4 clients get their own listener
      systemd.user.sockets.mpd.Socket = {
        BindIPv6Only = "ipv6-only";
        ListenStream = [ "0.0.0.0:${toString port}" ];
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

      # the port's rmpc_default_no_border config.ron, plus a visualiser under the queue
      programs.rmpc = {
        enable = true;
        config = ''
          #![enable(implicit_some)]
          #![enable(unwrap_newtypes)]
          #![enable(unwrap_variant_newtypes)]
          (
              theme: "rosepine-main",
              album_art: (method: Sixel),
              cava: (
                  input: (
                      method: Fifo,
                      source: "${fifo}",
                      sample_rate: 44100,
                      channels: 2,
                      sample_bits: 16,
                  ),
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
                  ${browseTab "Directories" "Directories" "NONE"}
                  ${browseTab "Artists" "Artists" "NONE"}
                  ${browseTab "Album Artists" "AlbumArtists" "NONE"}
                  ${browseTab "Albums" "Albums" "NONE"}
                  ${browseTab "Playlists" "Playlists" "NONE"}
                  ${browseTab "Search" "Search" "ALL"}
              ],
          )
        '';
      };
    };
}
