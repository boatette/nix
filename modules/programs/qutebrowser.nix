{
  flake.modules.homeManager.qutebrowser =
    { config, pkgs, ... }:
    let
      inherit (config.constants.fonts) mono;
    in
    {
      programs.qutebrowser = {
        enable = true;

        package = pkgs.qutebrowser.overrideAttrs (prev: {
          postPatch = (prev.postPatch or "") + ''
            substituteInPlace qutebrowser/app.py \
              --replace-fail \
                "command_target = config.val.new_instance_open_target" \
                "command_target = 'tab-silent'"
          '';
        });

        settings = {
          fonts.default_family = mono.name;
          fonts.default_size = "${toString mono.size}pt";
          colors.webpage.darkmode.enabled = true;
          tabs.show = "multiple";

          tabs.last_close = "default-page";
          auto_save.session = true;

          url.start_pages = [ "qute://start" ];
          url.default_page = "qute://start";

          new_instance_open_target = "tab";

          content.blocking.method = "both";
          content.blocking.adblock.lists = [
            "https://easylist.to/easylist/easylist.txt"
            "https://easylist.to/easylist/easyprivacy.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/badware.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/unbreak.txt"
            "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/quick-fixes.txt"
          ];
        };

        searchEngines = {
          DEFAULT = "https://www.startpage.com/sp/search?query={}&prfe=f553b88948f2386e97944a17f918362dbaedfb6381ed1bcb684b1f32e856a0fbc55532682719dcb7ce08628290db7ab6f5fc795492b620e0fc5634f33adfb8e816eaf81977d31c2b9322224f1f2432f1";
          search = "https://www.startpage.com/sp/search?query={}&prfe=f553b88948f2386e97944a17f918362dbaedfb6381ed1bcb684b1f32e856a0fbc55532682719dcb7ce08628290db7ab6f5fc795492b620e0fc5634f33adfb8e816eaf81977d31c2b9322224f1f2432f1";
          nixpkg = "https://search.nixos.org/packages?channel=unstable&query={}";
          nixopt = "https://search.nixos.org/options?channel=unstable&query={}";
          hm = "https://home-manager-options.extranix.com/?query={}&release=master";
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

        keyBindings.normal = {
          "<Ctrl-t>" = "open -t ;; cmd-set-text -s :open";

          ",v" = "fake-key <Ctrl-a>";

          ",M" = "spawn umpv {url}";
          ",m" = "hint links spawn umpv {hint-url}";
          ";M" = "hint --rapid links spawn umpv {hint-url}";
        };

        extraConfig = ''
          if (config.configdir / "noctalia" / "colors.py").exists():
              config.source("noctalia/colors.py")
        '';
      };
    };
}
