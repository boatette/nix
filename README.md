# dotfiles

Raw configuration files, for machines that do not run NixOS.

## Install

```sh
git clone https://github.com/boatette/nix ~/dotfiles -b dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` symlinks every tracked file into `$HOME`, moving anything already there to `<name>.bak`, then clones the zsh plugins, installs the yazi and zellij plugins, and enables the user units. Run `./install.sh link` to only link, or `./install.sh bootstrap` to only fetch.

## Dependencies

Install via method of choice.

Shell: `zsh`, `starship`, `zoxide`, `fzf`, `fd`, `ripgrep`, `eza`, `bat`, `dust`, `direnv`, `ouch`, `microfetch`

Editor: `neovim` 0.12 or newer, `git`, `curl`, plus a C compiler for treesitter parsers. Everything else (language servers, linters, formatters) is installed by mason on first launch.

Terminal: `foot`, `zellij`, `yazi` (with `ya`), `lazygit`, `delta`, `btop`, `konsole`

Desktop: `umbriel`, `noctalia`, `selector`, `qutebrowser`, `dolphin`, `vesktop`, `qimgv`, `papirus-icon-theme`, `adw-gtk3`, `capitaine-cursors`, `JetBrainsMono Nerd Font`, `Inter`

Helper scripts: `gawk`, `socat`, `jq`, `procps`

Some of the shell aliases assume systemd (`systemctl poweroff`, `journalctl`, `run0`) and NetworkManager (`nmtui`).
