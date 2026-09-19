#!/usr/bin/env bash

set -euo pipefail

REPO=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

PREFIX=${PREFIX:-/usr/local}
SRC=$XDG_CACHE_HOME/dotfiles/src

assume_yes=0
with_source=1
only_source=0

distro=
family=unknown
codename=
helper=

say() { printf '\033[32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33m  !\033[0m %s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

ask() {
    if ((assume_yes)); then
        return 0
    fi

    if [[ ! -t 0 ]]; then
        warn "not a terminal, declining: $1"
        return 1
    fi

    local reply
    read -r -p "  ? $1 [y/N] " reply
    [[ $reply == [yY]* ]]
}

as_root() {
    if [[ $EUID -eq 0 ]]; then
        "$@"
    elif have sudo; then
        sudo "$@"
    else
        warn "root privileges needed for: $*"
        return 1
    fi
}

# name              | probe                 | arch        | debian          | fedora                   | opensuse              | void        | source
dep_table() {
    cat <<'TABLE'
rustup              | cargo                 | .           | .               | .                        | .                     | .           | src:rustup

zsh                 | zsh                   | .           | .               | .                        | .                     | .           | -
starship            | starship              | .           | .               | .                        | .                     | .           | crate:starship
zoxide              | zoxide                | .           | .               | .                        | .                     | .           | crate:zoxide
fzf                 | fzf                   | .           | .               | .                        | .                     | .           | -
fd                  | fd                    | .           | fd-find         | fd-find                  | .                     | .           | crate:fd-find
ripgrep             | rg                    | .           | .               | .                        | .                     | .           | crate:ripgrep
eza                 | eza                   | .           | .               | .                        | .                     | .           | crate:eza
bat                 | bat                   | .           | .               | .                        | .                     | .           | crate:bat
dust                | dust                  | .           | du-dust         | .                        | .                     | .           | crate:du-dust
direnv              | direnv                | .           | .               | .                        | .                     | .           | -
ouch                | ouch                  | .           | .               | .                        | .                     | .           | crate:ouch
fastfetch           | fastfetch             | .           | .               | .                        | .                     | .           | -

neovim              | nvim                  | .           | .               | .                        | .                     | .           | -
git                 | git                   | .           | .               | .                        | .                     | .           | -
gh                  | gh                    | github-cli  | gh              | gh                       | gh                    | github-cli  | -
curl                | curl                  | .           | .               | .                        | .                     | .           | -
cc                  | cc gcc clang          | gcc         | build-essential | gcc-c++                  | gcc-c++               | gcc         | -
unzip               | unzip                 | .           | .               | .                        | .                     | .           | -

foot                | foot                  | .           | .               | .                        | .                     | .           | -
zellij              | zellij                | .           | .               | .                        | .                     | .           | crate:zellij
yazi                | ya                    | .           | .               | .                        | .                     | .           | crate:yazi-fm,yazi-cli
lazygit             | lazygit               | .           | .               | .                        | .                     | .           | go:github.com/jesseduffield/lazygit@latest
delta               | delta                 | git-delta   | git-delta       | git-delta                | git-delta             | delta       | crate:git-delta
btop                | btop                  | .           | .               | .                        | .                     | .           | -
konsole             | konsole               | .           | .               | .                        | .                     | .           | -

umbriel             | umbriel               | umbriel-git | .               | umbriel umbriel-nightly  | umbriel-git umbriel   | .           | src:umbriel
noctalia            | noctalia              | noctalia    | noctalia        | noctalia noctalia-git    | noctalia noctalia-git | noctalia    | src:noctalia
selector            | selector              | -           | -               | -                        | -                     | -           | src:selector
xdg-desktop-portal-umbriel | @path:xdg-desktop-portal/portals/umbriel.portal | xdg-desktop-portal-umbriel-git | . | . | . | . | src:portal
xwayland-satellite  | xwayland-satellite    | .           | .               | .                        | .                     | .           | -
qutebrowser         | qutebrowser           | .           | .               | .                        | .                     | .           | -
dolphin             | dolphin               | .           | .               | .                        | .                     | .           | -
vesktop             | vesktop               | .           | .               | .                        | .                     | .           | -
qimgv               | qimgv                 | .           | .               | .                        | .                     | .           | -
papirus-icon-theme  | @path:icons/Papirus   | .           | .               | .                        | .                     | .           | -
papirus-folders     | papirus-folders       | .           | .               | .                        | .                     | .           | -
adw-gtk3            | @path:themes/adw-gtk3 | adw-gtk-theme | .             | adw-gtk3-theme           | .                     | .           | gh:lassekongo83/adw-gtk3:adw-gtk3v.*[.]tar[.]xz$:themes
capitaine-cursors   | @path:icons/capitaine-cursors | .   | .               | .                        | .                     | .           | -
jetbrains-mono-nerd | @font:JetBrainsMono Nerd | ttf-jetbrains-mono-nerd | . | jetbrains-mono-nerd-fonts | .                    | nerd-fonts  | gh:ryanoasis/nerd-fonts:JetBrainsMono[.]tar[.]xz$:fonts/JetBrainsMonoNerd
inter               | @font:Inter           | inter-font  | fonts-inter     | rsms-inter-fonts         | google-inter-fonts    | font-inter  | -
wl-clipboard        | wl-copy               | .           | .               | .                        | .                     | .           | -
libnotify           | notify-send           | .           | libnotify-bin   | .                        | libnotify-tools       | .           | -
imagemagick         | magick convert        | .           | .               | ImageMagick              | ImageMagick           | ImageMagick | -
glib                | gdbus                 | glib2       | libglib2.0-bin  | glib2                    | glib2-tools           | glib        | -
pipewire            | pipewire              | .           | .               | .                        | .                     | .           | -
wireplumber         | wireplumber           | .           | .               | .                        | .                     | .           | -

gawk                | gawk                  | .           | .               | .                        | .                     | .           | -
socat               | socat                 | .           | .               | .                        | .                     | .           | -
jq                  | jq                    | .           | .               | .                        | .                     | .           | -
procps              | pgrep                 | procps-ng   | procps          | procps-ng                | procps                | procps-ng   | -
rsync               | rsync                 | .           | .               | .                        | .                     | .           | -
util-linux          | findmnt               | .           | .               | .                        | .                     | .           | -
iproute2            | ss                    | .           | .               | iproute                  | .                     | .           | -
lm-sensors          | sensors               | lm_sensors  | lm-sensors      | lm_sensors               | sensors               | lm_sensors  | -
TABLE
}

detect() {
    if [[ ! -r /etc/os-release ]]; then
        warn "no /etc/os-release, cannot detect the distribution"
        return
    fi

    local id_like
    local -a fields=()
    # shellcheck disable=SC1091
    mapfile -t fields < <(. /etc/os-release &&
        printf '%s\n%s\n%s\n' "${ID:-}" "${ID_LIKE:-}" "${VERSION_CODENAME:-}")

    distro=${fields[0]:-}
    id_like=${fields[1]:-}
    codename=${fields[2]:-}

    local candidate
    for candidate in "$distro" $id_like; do
        case $candidate in
        arch | archarm | cachyos | endeavouros | manjaro) family=arch ;;
        debian | ubuntu | linuxmint | pop | raspbian) family=debian ;;
        fedora | rhel | centos | nobara | bazzite) family=fedora ;;
        opensuse* | suse | sles) family=opensuse ;;
        void) family=void ;;
        *) continue ;;
        esac
        return
    done
}

pick_helper() {
    case $family in
    arch)
        local candidate
        for candidate in yay paru; do
            if have "$candidate"; then
                helper=$candidate
                return
            fi
        done
        helper=pacman
        warn "neither yay nor paru found, using pacman. AUR packages will fall back to a source build"
        warn "install yay first for umbriel, the portal and the rest of the AUR set"
        ;;
    debian) helper=apt-get ;;
    fedora) helper=dnf ;;
    opensuse) helper=zypper ;;
    void) helper=xbps-install ;;
    esac
}

pm_sync() {
    case $family in
    arch)
        local -a flags=(-Syu)
        if ((assume_yes)); then
            flags+=(--noconfirm)
        fi

        if ask "run '$helper ${flags[*]}' first? installing against stale databases can break Arch"; then
            if [[ $helper == pacman ]]; then
                as_root pacman "${flags[@]}" || warn "the upgrade failed"
            else
                "$helper" "${flags[@]}" || warn "the upgrade failed"
            fi
        else
            warn "leaving the package databases alone, anything missing from them will be built from source"
        fi
        ;;
    debian) as_root apt-get update || warn "apt-get update failed" ;;
    fedora) as_root dnf -q makecache || warn "dnf makecache failed" ;;
    opensuse) as_root zypper --non-interactive --gpg-auto-import-keys refresh || warn "zypper refresh failed" ;;
    void) as_root xbps-install -S || warn "xbps-install -S failed" ;;
    esac
}

pm_has() {
    local pkg=$1
    case $family in
    arch)
        if pacman -Si -- "$pkg" >/dev/null 2>&1; then
            return 0
        fi
        if [[ $helper != pacman ]]; then
            "$helper" -Si -- "$pkg" >/dev/null 2>&1
            return
        fi
        return 1
        ;;
    debian) apt-cache show -- "$pkg" >/dev/null 2>&1 ;;
    fedora) dnf -q info -- "$pkg" >/dev/null 2>&1 ;;
    opensuse) zypper --non-interactive search --match-exact -- "$pkg" >/dev/null 2>&1 ;;
    void) xbps-query -R -- "$pkg" >/dev/null 2>&1 ;;
    *) return 1 ;;
    esac
}

pm_install() {
    if (($# == 0)); then
        return 0
    fi

    case $family in
    arch)
        if [[ $helper == pacman ]]; then
            as_root pacman -S --needed --noconfirm -- "$@"
        else
            "$helper" -S --needed --noconfirm -- "$@"
        fi
        ;;
    debian) as_root apt-get install -y -- "$@" ;;
    fedora) as_root dnf install -y -- "$@" ;;
    opensuse) as_root zypper --non-interactive install --no-recommends -- "$@" ;;
    void) as_root xbps-install -y -- "$@" ;;
    *) return 1 ;;
    esac
}

install_known() {
    local what=$1
    shift

    local pkg
    local -a known=() unknown=()
    for pkg in "$@"; do
        if pm_has "$pkg"; then
            known+=("$pkg")
        else
            unknown+=("$pkg")
        fi
    done

    if ((${#unknown[@]})); then
        warn "$what: no package named ${unknown[*]}"
    fi

    if ((${#known[@]} == 0)); then
        return 0
    fi

    pm_install "${known[@]}" || warn "$what: install failed"
}

probe_ok() {
    local spec=$1

    case $spec in
    @path:*)
        local rel=${spec#@path:} dir
        local -a dirs=("$PREFIX/share" /usr/local/share /usr/share "$XDG_DATA_HOME") extra=()
        IFS=: read -r -a extra <<<"${XDG_DATA_DIRS:-}"
        dirs+=("${extra[@]}")
        for dir in "${dirs[@]}"; do
            if [[ -n $dir && -e $dir/$rel ]]; then
                return 0
            fi
        done
        return 1
        ;;
    @font:*)
        local pattern=${spec#@font:} dir hit
        if have fc-list; then
            hit=$(fc-list : family 2>/dev/null || true)
            if grep -qi -- "$pattern" <<<"$hit"; then
                return 0
            fi
            return 1
        fi
        for dir in "$PREFIX/share/fonts" /usr/local/share/fonts /usr/share/fonts \
            "$XDG_DATA_HOME/fonts" "$HOME/.fonts"; do
            if [[ ! -d $dir ]]; then
                continue
            fi
            hit=$(find "$dir" -iname "*${pattern// /*}*" -print -quit 2>/dev/null || true)
            if [[ -n $hit ]]; then
                return 0
            fi
        done
        return 1
        ;;
    *)
        local cmd
        for cmd in $spec; do
            if have "$cmd"; then
                return 0
            fi
        done
        return 1
        ;;
    esac
}

fetch_src() {
    local name=$1 url=$2
    local dir=$SRC/$name

    mkdir -p -- "$SRC"

    if [[ -d $dir/.git ]]; then
        git -C "$dir" pull --quiet --ff-only || warn "could not update the $name checkout, building what is there"
    else
        git clone --quiet --depth 1 "$url" "$dir" || {
            warn "could not clone $url"
            return 1
        }
    fi
}

rust_path() {
    local bin=${CARGO_HOME:-$HOME/.cargo}/bin
    if [[ -d $bin && :$PATH: != *:$bin:* ]]; then
        PATH=$bin:$PATH
        export PATH
        hash -r 2>/dev/null || true
    fi
}

rust_ready() {
    have cargo && cargo --version >/dev/null 2>&1
}

ensure_rust() {
    rust_path

    if rust_ready; then
        return 0
    fi

    if ! have rustup; then
        warn "no rust toolchain and no rustup to install one with"
        return 1
    fi

    say "initialising the rust toolchain with rustup"
    rustup default stable || {
        warn "rustup default stable failed"
        return 1
    }

    rust_path
    rust_ready || {
        warn "rustup ran but cargo still does not work"
        return 1
    }
}

install_rustup() {
    rust_path

    if have rustup; then
        ensure_rust
        return
    fi

    if ! have curl; then
        warn "curl not found, cannot install rustup"
        return 1
    fi

    say "installing rustup from rustup.rs"
    curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs |
        sh -s -- -y --no-modify-path --default-toolchain stable || {
        warn "the rustup installer failed"
        return 1
    }

    rust_path
    rust_ready || {
        warn "rustup installed but cargo still does not run"
        return 1
    }
}

cargo_install() {
    ensure_rust || {
        warn "skipping $*"
        return 1
    }

    local crate
    for crate in "$@"; do
        say "cargo install $crate"
        cargo install --locked "$crate" || warn "cargo install $crate failed"
    done
}

go_install() {
    if ! have go; then
        warn "go not found, skipping $1"
        return 1
    fi

    say "go install $1"
    go install "$1" || warn "go install $1 failed"
}

install_release() {
    local repo=$1 pattern=$2 dest=$XDG_DATA_HOME/$3

    if ! have curl; then
        warn "curl not found, skipping $repo"
        return 1
    fi

    local url
    url=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null |
        grep -o '"browser_download_url": *"[^"]*"' | cut -d'"' -f4 |
        grep -m1 -- "$pattern") || true

    if [[ -z $url ]]; then
        warn "no asset matching $pattern in the latest $repo release"
        return 1
    fi

    say "unpacking ${url##*/} into $dest"
    mkdir -p -- "$dest"

    local tmp status=0
    tmp=$(mktemp -d)
    if curl -fsSL -o "$tmp/asset" "$url" && tar -xf "$tmp/asset" -C "$dest"; then
        if [[ $3 == fonts/* ]] && have fc-cache; then
            fc-cache -f "$dest" >/dev/null 2>&1 || true
        fi
    else
        warn "could not install $repo"
        status=1
    fi
    rm -rf -- "$tmp"

    return $status
}

build_deps() {
    case $1/$family in
    noctalia/arch)
        printf '%s\n' meson gcc just wayland wayland-protocols libglvnd freetype2 fontconfig \
            cairo pango harfbuzz libxkbcommon glib2 libsecret libsodium sdbus-cpp libpipewire \
            wireplumber polkit pam curl libwebp libjxl libsndfile librsvg libqalculate libxml2 \
            md4c tomlplusplus libical nlohmann-json stb jemalloc
        ;;
    noctalia/debian)
        printf '%s\n' meson g++ just libwayland-dev wayland-protocols libegl-dev libgles-dev \
            libfreetype-dev libfontconfig-dev libcairo2-dev libpango1.0-dev libharfbuzz-dev \
            libxkbcommon-dev libglib2.0-dev libsecret-1-dev libsodium-dev libsdbus-c++-dev \
            libpipewire-0.3-dev libwireplumber-0.5-dev libpam0g-dev libpolkit-agent-1-dev \
            libpolkit-gobject-1-dev libcurl4-openssl-dev libwebp-dev libjxl-dev libsndfile1-dev \
            librsvg2-dev libqalculate-dev libxml2-dev libmd4c-dev libtomlplusplus-dev libical-dev \
            nlohmann-json3-dev libstb-dev libjemalloc-dev
        ;;
    noctalia/fedora)
        printf '%s\n' meson gcc-c++ just wayland-devel wayland-protocols-devel libEGL-devel \
            mesa-libGLES-devel freetype-devel fontconfig-devel cairo-devel pango-devel \
            harfbuzz-devel libxkbcommon-devel glib2-devel libsecret-devel libsodium-devel \
            sdbus-cpp-devel pipewire-devel wireplumber-devel pam-devel polkit-devel \
            libcurl-devel libwebp-devel libjxl-devel libsndfile-devel librsvg2-devel \
            libqalculate-devel libxml2-devel md4c-devel tomlplusplus-devel libical-devel \
            json-devel stb_image_resize2-devel stb_image_write-devel jemalloc-devel
        ;;
    noctalia/opensuse)
        printf '%s\n' meson gcc-c++ just wayland-devel wayland-protocols-devel Mesa-libEGL-devel \
            Mesa-libGLESv2-devel freetype2-devel fontconfig-devel cairo-devel pango-devel \
            harfbuzz-devel libxkbcommon-devel glib2-devel libsecret-devel libsodium-devel \
            sdbus-cpp-devel pipewire-devel wireplumber-devel pam-devel polkit-devel libcurl-devel \
            libwebp-devel libjxl-devel libsndfile-devel librsvg-devel libqalculate-devel \
            libxml2-devel md4c-devel tomlplusplus-devel libical-devel nlohmann_json-devel \
            stb-devel jemalloc-devel
        ;;
    noctalia/void)
        printf '%s\n' meson ninja pkg-config git wayland-devel wayland-protocols libepoxy-devel \
            MesaLib-devel libglvnd-devel cairo-devel pango-devel fontconfig-devel freetype-devel \
            harfbuzz-devel libxkbcommon-devel pipewire-devel wireplumber-devel libsecret-devel \
            libsodium-devel libcurl-devel pam-devel libwebp-devel libjxl-devel libsndfile-devel \
            basu-devel sdbus-c++-devel libmd4c-devel tomlplusplus libical-devel json-c++ stb \
            polkit-devel librsvg-devel libqalculate-devel libxml2-devel jemalloc-devel
        ;;
    umbriel/arch | portal/arch)
        printf '%s\n' meson ninja just pkgconf wlroots0.20 wayland wayland-protocols \
            libxkbcommon libinput systemd-libs pixman libdrm cairo pango tomlplusplus \
            nlohmann-json libglvnd mesa lcms2 jemalloc
        ;;
    umbriel/debian | portal/debian)
        printf '%s\n' meson ninja-build just pkg-config build-essential libwlroots-0.20-dev \
            libwayland-dev wayland-protocols libxkbcommon-dev libinput-dev libudev-dev \
            libpixman-1-dev libdrm-dev libcairo2-dev libpango1.0-dev libtomlplusplus-dev \
            nlohmann-json3-dev libegl-dev libgles-dev libgbm-dev liblcms2-dev libjemalloc-dev
        ;;
    umbriel/fedora | portal/fedora)
        printf '%s\n' meson ninja-build just pkgconf-pkg-config gcc-c++ wlroots-devel \
            wayland-devel wayland-protocols-devel libxkbcommon-devel libinput-devel \
            systemd-devel pixman-devel libdrm-devel cairo-devel pango-devel tomlplusplus-devel \
            json-devel libEGL-devel mesa-libGLES-devel mesa-libgbm-devel lcms2-devel jemalloc-devel
        ;;
    umbriel/opensuse | portal/opensuse)
        printf '%s\n' meson ninja just pkg-config gcc-c++ wlroots-devel wayland-devel \
            wayland-protocols-devel libxkbcommon-devel libinput-devel systemd-devel pixman-devel \
            libdrm-devel cairo-devel pango-devel tomlplusplus-devel nlohmann_json-devel \
            Mesa-libEGL-devel Mesa-libGLESv2-devel Mesa-libgbm-devel liblcms2-devel jemalloc-devel
        ;;
    umbriel/void | portal/void)
        printf '%s\n' meson ninja just pkg-config wlroots0.20-devel wayland-devel \
            wayland-protocols libxkbcommon-devel libinput-devel eudev-libudev-devel pixman-devel \
            libdrm-devel cairo-devel pango-devel tomlplusplus json-c++ libglvnd-devel \
            MesaLib-devel lcms2-devel jemalloc-devel
        ;;
    esac
}

prepare_build() {
    local project=$1

    local -a pkgs=()
    mapfile -t pkgs < <(build_deps "$project")

    if ((${#pkgs[@]})); then
        say "installing the $project build dependencies"
        install_known "$project build deps" "${pkgs[@]}"
    elif [[ $family != unknown ]]; then
        warn "no $project build dependency list for $family, hoping they are already installed"
    fi

    local tool
    for tool in git meson ninja just pkg-config; do
        if ! have "$tool"; then
            warn "$tool not found, cannot build $project from source"
            return 1
        fi
    done
}

check_wlroots() {
    if ! pkg-config --exists wlroots-0.20; then
        local found
        found=$(pkg-config --list-all 2>/dev/null | awk '$1 ~ /^wlroots/ { printf "%s ", $1 }')
        warn "umbriel needs the wlroots-0.20 pkg-config module; found: ${found:-none}"
        return 1
    fi

    if ! pkg-config --atleast-version=0.20.1 wlroots-0.20; then
        warn "umbriel needs wlroots 0.20.1 or newer, found $(pkg-config --modversion wlroots-0.20)"
        return 1
    fi
}

build_selector() {
    ensure_rust || {
        warn "cannot build selector without cargo"
        return 1
    }

    say "building selector from source"
    fetch_src selector https://github.com/boatette/selector || return 1

    (cd -- "$SRC/selector" && cargo build --release) || {
        warn "selector build failed"
        return 1
    }

    as_root install -Dm755 -- "$SRC/selector/target/release/selector" "$PREFIX/bin/selector" ||
        warn "could not install selector into $PREFIX/bin"
}

build_umbriel() {
    prepare_build umbriel || return 1
    check_wlroots || {
        warn "skipping the umbriel build, install wlroots 0.20.x first"
        return 1
    }

    say "building umbriel from source, this takes a while"
    fetch_src umbriel https://github.com/noctalia-dev/umbriel || return 1

    (cd -- "$SRC/umbriel" && just prefix="$PREFIX" release) || {
        warn "umbriel build failed"
        return 1
    }

    (cd -- "$SRC/umbriel" && as_root just prefix="$PREFIX" install) ||
        warn "umbriel install failed"
}

build_portal() {
    prepare_build portal || return 1

    say "building xdg-desktop-portal-umbriel from source"
    fetch_src xdg-desktop-portal-umbriel https://github.com/noctalia-dev/xdg-desktop-portal-umbriel || return 1

    (cd -- "$SRC/xdg-desktop-portal-umbriel" && just prefix="$PREFIX" release && just prefix="$PREFIX" install) ||
        warn "xdg-desktop-portal-umbriel build failed"
}

build_noctalia() {
    prepare_build noctalia || return 1

    say "building noctalia from source, this takes a while"
    fetch_src noctalia https://github.com/noctalia-dev/noctalia || return 1

    (cd -- "$SRC/noctalia" && just configure release "$PREFIX" && just build release) || {
        warn "noctalia build failed"
        return 1
    }

    (cd -- "$SRC/noctalia" && as_root just install release) || warn "noctalia install failed"
}

from_source() {
    local spec=$1

    case $spec in
    crate:*)
        local -a crates=()
        IFS=, read -r -a crates <<<"${spec#crate:}"
        cargo_install "${crates[@]}"
        ;;
    go:*) go_install "${spec#go:}" ;;
    gh:*)
        local rest=${spec#gh:}
        local pattern=${rest#*:}
        install_release "${rest%%:*}" "${pattern%:*}" "${rest##*:}"
        ;;
    src:rustup) install_rustup ;;
    src:selector) build_selector ;;
    src:umbriel) build_umbriel ;;
    src:portal) build_portal ;;
    src:noctalia) build_noctalia ;;
    *) return 1 ;;
    esac
}

repo_debian() {
    local suite
    case ${codename:-} in
    trixie) suite=trixie ;;
    sid | unstable) suite=unstable ;;
    resolute) suite=resolute ;;
    *)
        warn "no noctalia apt repository for '${codename:-unknown}', upstream ships Debian trixie, Debian sid and Ubuntu 26.04"
        return
        ;;
    esac

    local list=/etc/apt/sources.list.d/noctalia-$suite.sources
    if [[ -f $list ]]; then
        return
    fi

    if ! ask "add the noctalia apt repository (pkg.noctalia.dev) for noctalia, umbriel and the portal?"; then
        warn "skipping pkg.noctalia.dev, those will be built from source instead"
        return
    fi

    local tmp
    tmp=$(mktemp -d)

    say "adding the noctalia apt repository"
    if curl -fsSL -o "$tmp/keyring.deb" https://pkg.noctalia.dev/deb/nickh-archive-keyring.deb &&
        as_root dpkg -i -- "$tmp/keyring.deb" &&
        curl -fsSL -o "$tmp/noctalia.sources" "https://pkg.noctalia.dev/deb/noctalia-$suite.sources" &&
        as_root install -Dm644 -- "$tmp/noctalia.sources" "$list"; then
        as_root apt-get update || warn "apt-get update failed"
    else
        warn "could not add the noctalia apt repository"
    fi

    rm -rf -- "$tmp"
}

repo_fedora() {
    if ! pm_has umbriel-nightly; then
        if ask "enable the Terra repository (terra.fyralabs.com) for umbriel?"; then
            # shellcheck disable=SC2016
            as_root dnf install -y --nogpgcheck \
                --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release ||
                warn "could not enable Terra"
        else
            warn "skipping Terra, umbriel will be built from source"
        fi
    fi

    if ! pm_has noctalia; then
        if ask "enable the lionheartp/Hyprland copr for noctalia? (it is in the default repos from Fedora 44)"; then
            as_root dnf copr enable -y lionheartp/Hyprland || warn "could not enable the copr"
        fi
    fi
}

repo_opensuse() {
    if zypper --non-interactive repos noctalia-v5 >/dev/null 2>&1; then
        return
    fi

    local variant=openSUSE_Tumbleweed
    case $distro in
    *slowroll*) variant=openSUSE_Slowroll ;;
    esac

    if [[ $distro != *tumbleweed* && $distro != *slowroll* ]]; then
        warn "the noctalia OBS repository targets Tumbleweed and Slowroll, not ${distro:-this release}"
    fi

    if ! ask "add the home:neifua:Noctalia OBS repository for noctalia and umbriel?"; then
        warn "skipping the OBS repository, those will be built from source instead"
        return
    fi

    say "adding the home:neifua:Noctalia repository"
    as_root zypper --non-interactive addrepo --refresh --name noctalia-v5 \
        "https://download.opensuse.org/repositories/home:neifua:Noctalia/$variant/home:neifua:Noctalia.repo" ||
        warn "could not add the OBS repository"
}

repo_void() {
    local conf=/etc/xbps.d/10-voiders-community.conf
    if [[ -f $conf ]]; then
        return
    fi

    if ! ask "add the voiders community xbps repository (repo.voiders.dev) for noctalia?"; then
        warn "skipping repo.voiders.dev, noctalia will be built from source instead"
        return
    fi

    say "adding the voiders community repository"
    printf 'repository=https://repo.voiders.dev\n' | as_root tee -- "$conf" >/dev/null ||
        warn "could not write $conf"
}

enable_repos() {
    case $family in
    debian) repo_debian ;;
    fedora) repo_fedora ;;
    opensuse) repo_opensuse ;;
    void) repo_void ;;
    esac
}

check_noctalia() {
    if [[ $family == arch ]] && have pacman && pacman -Qq noctalia-shell >/dev/null 2>&1; then
        warn "noctalia-shell is installed, that is the legacy Quickshell v4 build"
        warn "these configs are noctalia v5; remove it with 'pacman -Rns noctalia-shell'"
    fi

    if ! have noctalia; then
        return
    fi

    local version
    version=$(noctalia --version 2>/dev/null | grep -o '[0-9][0-9.]*' | head -n1 || true)
    case $version in
    '') ;;
    [1-4].*) warn "noctalia $version is older than v5, these configs will not load" ;;
    *) say "noctalia $version" ;;
    esac
}

deps() {
    detect
    pick_helper

    if [[ $family == unknown ]]; then
        warn "unrecognised distribution${distro:+ ($distro)}, no package manager will be used"
        warn "everything with a source fallback will be built instead"
    else
        say "detected ${distro:-$family} ($family family), using $helper"
    fi

    if [[ $family != unknown && $only_source -eq 0 ]]; then
        enable_repos
        pm_sync
    fi

    local name probe f_arch f_debian f_fedora f_opensuse f_void source
    local field candidate pkg
    local -a wanted=() building=() present=() nowhere=()

    if [[ $family != unknown ]]; then
        say "resolving package names, this asks $helper about each one"
    fi

    while IFS='|' read -r name probe f_arch f_debian f_fedora f_opensuse f_void source; do
        if [[ -z $name || $name == '#'* ]]; then
            continue
        fi

        if probe_ok "$probe"; then
            present+=("$name")
            continue
        fi

        case $family in
        arch) field=$f_arch ;;
        debian) field=$f_debian ;;
        fedora) field=$f_fedora ;;
        opensuse) field=$f_opensuse ;;
        void) field=$f_void ;;
        *) field=- ;;
        esac

        pkg=
        if ((only_source == 0)) && [[ $field != - ]]; then
            for candidate in $field; do
                if [[ $candidate == . ]]; then
                    candidate=$name
                fi
                if pm_has "$candidate"; then
                    pkg=$candidate
                    break
                fi
            done
        fi

        if [[ -n $pkg ]]; then
            wanted+=("$pkg")
        elif ((with_source)) && [[ $source != - ]]; then
            building+=("$name=$source")
        else
            nowhere+=("$name")
        fi
    done < <(dep_table | sed -e 's/[[:space:]]*|[[:space:]]*/|/g' -e 's/[[:space:]]*$//')

    if ((${#present[@]})); then
        say "already installed: ${present[*]}"
    fi

    if ((${#wanted[@]})); then
        say "installing ${#wanted[@]} packages with $helper"
        if ! pm_install "${wanted[@]}"; then
            warn "the batch install failed, retrying one package at a time"
            for pkg in "${wanted[@]}"; do
                pm_install "$pkg" || warn "could not install $pkg"
            done
        fi
    fi

    local entry
    for entry in "${building[@]}"; do
        from_source "${entry#*=}" || warn "could not build ${entry%%=*} from source"
    done

    if ((${#nowhere[@]})); then
        warn "no package and no source build for: ${nowhere[*]}"
        warn "install those by hand, see the dependency list in README.md"
    fi

    if ((${#building[@]})) && [[ ${building[*]} == *crate:* || ${building[*]} == *go:* ]]; then
        say "cargo and go install into ~/.cargo/bin and ~/go/bin, which .zshenv puts on PATH"
    fi

    check_noctalia
}

link_one() {
    local file=$1
    local src=$REPO/$file
    local dst=$HOME/$file

    if [[ -L $dst && $(readlink "$dst") == "$src" ]]; then
        return
    fi

    mkdir -p -- "$(dirname -- "$dst")"

    if [[ -e $dst || -L $dst ]]; then
        mv -- "$dst" "$dst.bak"
        warn "backed up $file -> $file.bak"
    fi

    ln -s -- "$src" "$dst"
}

link() {
    say "linking dotfiles into $HOME"

    local file
    while IFS= read -r -d '' file; do
        case $file in
        README.md | install.sh | .gitignore) continue ;;
        esac
        link_one "$file"
    done < <(git -C "$REPO" ls-files -z)
}

zsh_plugins() {
    local dir=$XDG_DATA_HOME/zsh/plugins
    say "cloning zsh plugins into $dir"
    mkdir -p -- "$dir"

    local repo name
    for repo in zsh-users/zsh-autosuggestions \
        zsh-users/zsh-syntax-highlighting \
        zsh-users/zsh-history-substring-search \
        Aloxaf/fzf-tab; do
        name=${repo#*/}

        if [[ -d $dir/$name/.git ]]; then
            git -C "$dir/$name" pull --quiet --ff-only || warn "could not update $name"
        else
            git clone --quiet --depth 1 "https://github.com/$repo" "$dir/$name" ||
                warn "could not clone $name"
        fi
    done
}

lazygit_theme() {
    local theme=$XDG_CONFIG_HOME/lazygit/config.yml
    if [[ ! -f $theme ]]; then
        mkdir -p -- "$(dirname -- "$theme")"
        printf '{}\n' >"$theme"
        say "seeded $theme"
    fi
}

yazi_plugins() {
    if ! have ya; then
        warn "ya not found, skipping yazi plugins"
        return
    fi

    say "installing yazi plugins"

    local name
    for name in chmod full-border git jump-to-char mount \
        smart-enter smart-filter smart-paste toggle-pane vcs-files; do
        ya pkg add "yazi-rs/plugins:$name" >/dev/null 2>&1 ||
            warn "could not add yazi plugin $name"
    done

    ya pkg install >/dev/null || warn "ya pkg install failed"
}

zellij_plugin() {
    local wasm=$XDG_CONFIG_HOME/zellij/plugins/autolock.wasm
    if [[ -f $wasm ]]; then
        return
    fi

    if ! have curl; then
        warn "curl not found, skipping the zellij autolock plugin"
        return
    fi

    say "fetching the zellij autolock plugin"
    mkdir -p -- "$(dirname -- "$wasm")"
    curl -fsSL -o "$wasm" \
        https://github.com/fresh2dev/zellij-autolock/releases/latest/download/zellij-autolock.wasm ||
        warn "could not fetch autolock.wasm"
}

units() {
    if ! have systemctl; then
        warn "no systemctl, skipping the user units"
        return
    fi

    say "enabling user units"
    systemctl --user daemon-reload || warn "systemctl --user daemon-reload failed"

    local unit
    for unit in noctalia.service selector.service ssh-agent.service ssd-backup.timer; do
        systemctl --user enable "$unit" >/dev/null 2>&1 || warn "could not enable $unit"
    done
}

default_shell() {
    local zsh user current
    if ! zsh=$(command -v zsh); then
        warn "zsh not found, leaving the login shell alone"
        return
    fi

    user=$(id -un)
    if have getent; then
        current=$(getent passwd "$user" | cut -d: -f7)
    else
        current=${SHELL:-}
    fi

    if [[ $current == "$zsh" ]]; then
        return
    fi

    if ! grep -qxF -- "$zsh" /etc/shells 2>/dev/null; then
        say "adding $zsh to /etc/shells"
        printf '%s\n' "$zsh" | as_root tee -a /etc/shells >/dev/null || {
            warn "could not add $zsh to /etc/shells, leaving the login shell alone"
            return
        }
    fi

    if ! ask "change the login shell for $user from ${current:-unknown} to $zsh?"; then
        warn "leaving the login shell as ${current:-unknown}"
        return
    fi

    say "changing the login shell to $zsh"
    if as_root chsh -s "$zsh" "$user"; then
        say "log out and back in for the new shell to take effect"
    else
        warn "could not change the login shell, run 'chsh -s $zsh' by hand"
    fi
}

bootstrap() {
    zsh_plugins
    lazygit_theme
    yazi_plugins
    zellij_plugin
    units
    default_shell
    say "done, open nvim once to let vim.pack and mason install"
}

usage() {
    cat <<'USAGE'
usage: install.sh [deps|link|bootstrap|all] [options]

  deps       install the dependencies with the system package manager,
             building from source where the distribution has no package
  link       symlink every tracked file into $HOME
  bootstrap  fetch the zsh, yazi and zellij plugins, enable the user units
  all        all three in that order (default)

options:
  -y, --yes        do not prompt before adding third party package repositories
      --no-source  install only what is packaged, never build
      --source-only  build from source even where a package exists
  -h, --help       show this message

environment:
  PREFIX  install prefix for source builds (default /usr/local)
USAGE
}

cmd=all

while (($#)); do
    case $1 in
    deps | link | bootstrap | all) cmd=$1 ;;
    -y | --yes) assume_yes=1 ;;
    --no-source) with_source=0 ;;
    --source-only) only_source=1 ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        usage >&2
        exit 2
        ;;
    esac
    shift
done

case $cmd in
deps) deps ;;
link) link ;;
bootstrap) bootstrap ;;
all)
    deps
    link
    bootstrap
    ;;
esac
