{ inputs, ... }:
{
  flake.modules.homeManager.boatette =
    {
      lib,
      osConfig,
      pkgs,
      ...
    }:
    let
      inherit (inputs.self.constants) homeManagerBranch release;
      inherit (inputs.self.constants.fonts) mono;
      inherit (osConfig.services.searx.settings) server;

      searxngOrigin = "http://${server.bind_address}:${toString server.port}";

      editUrl = "spawn --userscript ${
        lib.getExe (pkgs.local.qute-edit-url.override { searxng = searxngOrigin; })
      }";
      searxng = "${searxngOrigin}/search?q={}";
    in
    {
      programs.qutebrowser = {
        enable = true;

        # wrapped rather than overridden, so qutebrowser itself still comes from the cache
        package = pkgs.symlinkJoin {
          inherit (pkgs.qutebrowser)
            name
            pname
            version
            meta
            ;
          paths = [ pkgs.qutebrowser ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/qutebrowser \
              --set QT_QPA_PLATFORMTHEME xdgdesktopportal \
              --set QTWEBENGINEPROCESS_PATH ${pkgs.qt6Packages.qtwebengine}/libexec/QtWebEngineProcess \
              --set QTWEBENGINE_LOCALES_PATH ${pkgs.qt6Packages.qtwebengine}/qtwebengine_locales
          '';
        };

        settings = {
          fonts = {
            default_family = mono.name;
            default_size = "${toString mono.size}pt";
            web.family = {
              standard = mono.name;
              fixed = mono.name;
              sans_serif = mono.name;
              serif = mono.name;
            };
          };
          colors.webpage.darkmode.enabled = true;
          auto_save.session = true;

          tabs = {
            show = "multiple";
            last_close = "default-page";
          };

          url = {
            start_pages = [ "qute://start" ];
            default_page = "qute://start";
          };

          new_instance_open_target = "tab";

          content.blocking = {
            method = "both";
            adblock.lists = [
              "https://easylist.to/easylist/easylist.txt"
              "https://easylist.to/easylist/easyprivacy.txt"
              "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt"
              "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt"
              "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/badware.txt"
              "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/unbreak.txt"
              "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/quick-fixes.txt"
            ];
          };
        };

        # searxng is already rose pine, and darkmode would recolour it
        perDomainSettings."${searxngOrigin}/*".colors.webpage.darkmode.enabled = false;

        searchEngines = {
          DEFAULT = searxng;
          search = searxng;
          google = "https://www.google.com/search?q={}";
          nixpkg = "https://search.nixos.org/packages?channel=${release}&query={}";
          nixopt = "https://search.nixos.org/options?channel=${release}&query={}";
          hm = "https://home-manager-options.extranix.com/?query={}&release=${homeManagerBranch}";
          noogle = "https://noogle.dev/q?term={}";
          nixwiki = "https://wiki.nixos.org/w/index.php?search={}";
          nixdisc = "https://discourse.nixos.org/search?q={}";

          youtube = "https://youtube.com/results?search_query={}";
          gh = "https://github.com/search?q={}&type=repositories";
          ghc = "https://github.com/search?q={}&type=code";
          so = "https://stackoverflow.com/search?q={}";
          reddit = "https://www.reddit.com/search/?q={}";
          wiki = "https://en.wikipedia.org/w/index.php?search={}";
          aw = "https://wiki.archlinux.org/index.php?search={}";
          man = "https://man.archlinux.org/search?q={}";
          mdn = "https://developer.mozilla.org/en-US/search?q={}";
          crates = "https://crates.io/search?q={}";
          docsrs = "https://docs.rs/releases/search?query={}";
          archive = "https://web.archive.org/web/{}";
        };

        keyBindings.normal =
          lib.genAttrs' (lib.range 1 8) (
            n: lib.nameValuePair "<Alt-${toString n}>" "tab-focus ${toString n} --no-last"
          )
          // {
            "<Alt-9>" = "tab-focus -1 --no-last";

            "H" = "tab-prev";
            "L" = "tab-next";
            "J" = "forward";
            "K" = "back";

            ",v" = "fake-key <Ctrl-a>";

            "go" = editUrl;
            "gO" = "${editUrl} -t -r";

            ",M" = "spawn umpv {url}";
            ",m" = "hint links spawn umpv {hint-url}";
            ";M" = "hint --rapid links spawn umpv {hint-url}";
          };
      };
    };
}
