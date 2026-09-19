# dotfiles

Raw configuration files, for machines that do not run NixOS.

## Install

```sh
git clone https://github.com/boatette/nix ~/dotfiles -b dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` runs three steps in order:

- `deps`: install the dependencies with the system package manager, building from source where the distribution has no package
- `link`: symlink every tracked file into `$HOME`, moving anything already there to `<name>.bak`
- `bootstrap`: clone the zsh plugins, install the yazi and zellij plugins, enable the user units, set zsh as the login shell

Run one on its own with `./install.sh link`, `./install.sh deps`, and so on.

| Flag            |                                                              |
| --------------- | ------------------------------------------------------------ |
| `-y`, `--yes`   | do not prompt before adding third party package repositories |
| `--no-source`   | install only what is packaged, never build                   |
| `--source-only` | build from source even where a package exists                |
| `PREFIX=…`      | install prefix for source builds, default `/usr/local`       |

Package managers it knows: `yay` (then `paru`, then `pacman`) on Arch, `apt-get` on Debian and Ubuntu, `dnf` on Fedora, `zypper` on openSUSE and `xbps-install` on Void. Anything else falls back to the source builds alone.

## Dependencies

`./install.sh deps` installs everything below. The list is here so you can do it by hand, and because a few names are not what you would guess.

### The desktop core

These are the ones worth knowing about, because most of them live in a third party repository that `deps` offers to add for you.

|                            | Arch              | Debian / Ubuntu         | Fedora                  | openSUSE                 | Void                     |
| -------------------------- | ----------------- | ----------------------- | ----------------------- | ------------------------ | ------------------------ |
| noctalia                   | `extra`           | [pkg.noctalia.dev][deb] | default repos¹          | [OBS][obs]               | [repo.voiders.dev][void] |
| umbriel                    | AUR `umbriel-git` | [pkg.noctalia.dev][deb] | Terra `umbriel-nightly` | [OBS][obs] `umbriel-git` | **source**               |
| xdg-desktop-portal-umbriel | AUR, `-git`       | [pkg.noctalia.dev][deb] | source                  | source                   | source                   |
| selector                   | source            | source                  | source                  | source                   | source                   |

¹ Fedora 44 and up. Older releases get the `lionheartp/Hyprland` copr.

[deb]: https://pkg.noctalia.dev/
[obs]: https://build.opensuse.org/project/show/home:neifua:Noctalia
[void]: https://repo.voiders.dev/

**Noctalia must be v5.** `noctalia-shell` is the unmaintained v4 built on Quickshell, it reads a completely different settings format, and none of the TOML in `.config/noctalia/` will load under it. `noctalia-qs` is the Quickshell toolkit itself and is not a dependency of v5 at all. `deps` warns if it finds the wrong one installed.

Building umbriel from source needs **wlroots 0.20.1 or newer and below 0.21**, as it compiles against wlroots' private struct layouts. Debian trixie ships 0.18, so only sid and forky can build it; `deps` checks the `wlroots-0.20` pkg-config module and skips the build rather than failing an hour in.

### Shell

- `zsh`
- `starship`
- `zoxide`, `fzf`, `fd`, `ripgrep`
- `eza`, `bat`, `dust`
- `direnv`
- `ouch`
- `fastfetch`

### Editor

- `neovim` 0.12 or newer
- `git`, `curl`
- `gh`, the GitHub CLI, `github-cli` on Arch and Void
- `unzip`, mason unpacks several of the language servers from zip archives
- a C compiler for the treesitter parsers, `gcc`, `build-essential` or `gcc-c++` depending on the distribution

Everything else, the language servers, linters and formatters, is installed by mason on first launch. Open nvim once afterwards to let `vim.pack` fetch the plugins.

### Terminal

- `foot`
- `zellij`
- `yazi`
- `lazygit`
- `delta`, packaged as `git-delta` outside Void
- `btop`
- `konsole`

### Desktop

- `umbriel`
- `noctalia`, **v5**
- `selector`, [boatette/selector](https://github.com/boatette/selector), built from source everywhere, a Rust toolchain 1.85 or newer is all it needs
- `xdg-desktop-portal-umbriel`
- `xwayland-satellite`
- `qutebrowser`, `dolphin`, `vesktop`, `qimgv`
- `papirus-icon-theme` and `papirus-folders`
- `adw-gtk3`, Arch calls it `adw-gtk-theme`, Fedora `adw-gtk3-theme`. `deps` falls back to the upstream release tarball
- `capitaine-cursors`, only packaged on Arch and openSUSE
- JetBrainsMono Nerd Font, Arch `ttf-jetbrains-mono-nerd`, Fedora `jetbrains-mono-nerd-fonts`, Void `nerd-fonts`. `deps` falls back to the nerd-fonts release tarball
- Inter, `inter-font`, `fonts-inter`, `rsms-inter-fonts`, `google-inter-fonts` or `font-inter`
- `wl-clipboard`, `libnotify`
- `imagemagick`, `glib`
- `pipewire` and `wireplumber`

`vesktop` is only packaged on Arch; elsewhere take the `.deb`, `.rpm` or AppImage from [vesktop.dev](https://vesktop.dev/).

### Helper scripts

- `gawk`, `jq`
- `socat`
- `procps`, packaged as `procps-ng` on Arch, Fedora and Void
- `rsync`, `util-linux`
- `iproute2`, `lm-sensors`

Some of the shell aliases assume systemd (`systemctl poweroff`, `journalctl`, `run0`) and NetworkManager (`nmtui`), and `serve` assumes `python3`.
