{ inputs, ... }:
{
  flake.modules.nixos.libvirt.home-manager.sharedModules = [
    inputs.self.modules.homeManager.libvirt
  ];

  flake.modules.homeManager.libvirt =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.constants) flakeDir username;

      socat = lib.getExe pkgs.socat;
    in
    {
      programs.zsh.initContent = ''
        _vm_dir() { print -r -- "''${XDG_DATA_HOME:-$HOME/.local/share}/nixos-vm"; }

        _vm_sock() { print -r -- "''${XDG_RUNTIME_DIR:-/tmp}/nixos-vm.sock"; }

        _vm_monitor() { print -r -- "$1" | ${socat} - "UNIX-CONNECT:$(_vm_sock)" >/dev/null 2>&1; }

        _vm_running() { ${socat} -u OPEN:/dev/null "UNIX-CONNECT:$(_vm_sock)" 2>/dev/null; }

        vm-build() {
          local dir=$(_vm_dir)
          mkdir -p -- "$dir" && nh os build-vm --diff never -H vm -o "$dir/result" ${flakeDir} "$@"
        }

        vm() {
          local dir=$(_vm_dir) extra=()
          [[ $1 == --headless ]] && { extra=(-display egl-headless); shift; }
          _vm_running && { print -u2 "vm: already running"; return 1; }
          vm-build || return

          NIX_DISK_IMAGE="$dir/vm.qcow2" "$dir/result/bin/run-vm-vm" \
            -monitor "unix:$(_vm_sock),server=on,wait=off" "''${extra[@]}" "$@" \
            >"$dir/qemu.log" 2>&1 &!
          local pid=$!

          while kill -0 $pid 2>/dev/null; do
            _vm_running && { print "vm: running, log at $dir/qemu.log"; return; }
            sleep 0.2
          done

          print -u2 "vm: qemu exited"
          tail -n 20 -- "$dir/qemu.log" >&2
          return 1
        }

        vm-ssh() {
          ssh -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR \
            ${username}@localhost "$@"
        }

        vm-stop() {
          _vm_running || { print -u2 "vm: not running"; return 1; }
          if [[ $1 == --force ]]; then _vm_monitor quit; else _vm_monitor system_powerdown; fi
        }

        vm-reset() {
          local disk="$(_vm_dir)/vm.qcow2"
          _vm_running && { print -u2 "vm: running, run vm-stop first"; return 1; }
          [[ -e $disk ]] || { print "vm: no disk image"; return; }
          read -q "?vm: delete $disk? [y/N] " && rm -- "$disk"
          print
        }

        vm-status() {
          local dir=$(_vm_dir)
          if _vm_running; then print "state:  running"; else print "state:  stopped"; fi
          [[ -e $dir/vm.qcow2 ]] && print "disk:   $(command du -h -- "$dir/vm.qcow2" | cut -f1)"
          [[ -e $dir/result ]] && print "system: $(readlink -- "$dir/result/system")"
          return 0
        }
      '';
    };
}
