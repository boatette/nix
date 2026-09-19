config.load_autoconfig(False)
config.set("auto_save.session", True)
config.set("colors.webpage.darkmode.enabled", True)
config.set("content.blocking.adblock.lists", ["https://easylist.to/easylist/easylist.txt", "https://easylist.to/easylist/easyprivacy.txt", "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt", "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt", "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/badware.txt", "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/unbreak.txt", "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/quick-fixes.txt"])
config.set("content.blocking.method", "both")
config.set("fonts.default_family", "JetBrainsMono Nerd Font")
config.set("fonts.default_size", "12pt")
config.set("new_instance_open_target", "tab")
config.set("tabs.last_close", "default-page")
config.set("tabs.show", "multiple")
config.set("url.default_page", "qute://start")
config.set("url.start_pages", ["qute://start"])
c.url.searchengines['DEFAULT'] = "https://www.startpage.com/sp/search?query={}&prfe=f553b88948f2386e97944a17f918362dbaedfb6381ed1bcb684b1f32e856a0fbc55532682719dcb7ce08628290db7ab6f5fc795492b620e0fc5634f33adfb8e816eaf81977d31c2b9322224f1f2432f1"
c.url.searchengines['archive'] = "https://web.archive.org/web/{}"
c.url.searchengines['aw'] = "https://wiki.archlinux.org/index.php?search={}"
c.url.searchengines['crates'] = "https://crates.io/search?q={}"
c.url.searchengines['docsrs'] = "https://docs.rs/releases/search?query={}"
c.url.searchengines['gh'] = "https://github.com/search?q={}&type=repositories"
c.url.searchengines['ghc'] = "https://github.com/search?q={}&type=code"
c.url.searchengines['hm'] = "https://home-manager-options.extranix.com/?query={}&release=master"
c.url.searchengines['man'] = "https://man.archlinux.org/search?q={}"
c.url.searchengines['mdn'] = "https://developer.mozilla.org/en-US/search?q={}"
c.url.searchengines['nixdisc'] = "https://discourse.nixos.org/search?q={}"
c.url.searchengines['nixopt'] = "https://search.nixos.org/options?channel=unstable&query={}"
c.url.searchengines['nixpkg'] = "https://search.nixos.org/packages?channel=unstable&query={}"
c.url.searchengines['nixwiki'] = "https://wiki.nixos.org/w/index.php?search={}"
c.url.searchengines['noogle'] = "https://noogle.dev/q?term={}"
c.url.searchengines['reddit'] = "https://www.reddit.com/search/?q={}"
c.url.searchengines['search'] = "https://www.startpage.com/sp/search?query={}&prfe=f553b88948f2386e97944a17f918362dbaedfb6381ed1bcb684b1f32e856a0fbc55532682719dcb7ce08628290db7ab6f5fc795492b620e0fc5634f33adfb8e816eaf81977d31c2b9322224f1f2432f1"
c.url.searchengines['so'] = "https://stackoverflow.com/search?q={}"
c.url.searchengines['wiki'] = "https://en.wikipedia.org/w/index.php?search={}"
c.url.searchengines['youtube'] = "https://youtube.com/results?search_query={}"
config.bind(",M", "spawn umpv {url}", mode="normal")
config.bind(",m", "hint links spawn umpv {hint-url}", mode="normal")
config.bind(",v", "fake-key <Ctrl-a>", mode="normal")
config.bind(";M", "hint --rapid links spawn umpv {hint-url}", mode="normal")
config.bind("<Ctrl-t>", "open -t ;; cmd-set-text -s :open", mode="normal")
config.bind("H", "tab-prev", mode="normal")
config.bind("J", "forward", mode="normal")
config.bind("K", "back", mode="normal")
config.bind("L", "tab-next", mode="normal")
if (config.configdir / "noctalia" / "colors.py").exists():
    config.source("noctalia/colors.py")
