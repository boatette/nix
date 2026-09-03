{
  flake.modules.homeManager.qutebrowser =
    { config, ... }:
    let
      inherit (config.constants.fonts) mono;
    in
    {
      programs.qutebrowser = {
        enable = true;

        settings = {
          fonts.default_family = mono.name;
          fonts.default_size = "${toString mono.size}pt";
          colors.webpage.darkmode.enabled = true;
          tabs.show = "multiple";

          tabs.last_close = "default-page";

          url.start_pages = [ "qute://start" ];
          url.default_page = "qute://start";

          new_instance_open_target = "tab-silent";
        };

        searchEngines = {
          DEFAULT = "https://www.startpage.com/sp/search?query={}&prfe=f553b88948f2386e97944a17f918362dbaedfb6381ed1bcb684b1f32e856a0fbc55532682719dcb7ce08628290db7ab6f5fc795492b620e0fc5634f33adfb8e816eaf81977d31c2b9322224f1f2432f1";
          nix = "https://search.nixos.org/packages?query={}";
        };

        keyBindings.normal = {
          "<Ctrl-t>" = "open -t ;; cmd-set-text -s :open";

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
