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

      qemu = lib.getExe' pkgs.qemu_kvm "qemu-system-x86_64";
      qemu-img = lib.getExe' pkgs.qemu_kvm "qemu-img";
      ovmf = "${pkgs.OVMF.fd}/FV";
      socat = lib.getExe pkgs.socat;
    in
    {
      programs.zsh.initContent = ''
        _vm_dir() { print -r -- "''${XDG_DATA_HOME:-$HOME/.local/share}/nixos-vm"; }

        _vm_sock() { print -r -- "''${XDG_RUNTIME_DIR:-/tmp}/nixos-$1.sock"; }

        _vm_monitor() { print -r -- "$2" | ${socat} - "UNIX-CONNECT:$(_vm_sock $1)" >/dev/null 2>&1; }

        _vm_running() { ${socat} -u OPEN:/dev/null "UNIX-CONNECT:$(_vm_sock $1)" 2>/dev/null; }

        _vm_launch() {
          local name=$1 log=$2
          shift 2

          "$@" -monitor "unix:$(_vm_sock $name),server=on,wait=off" >"$log" 2>&1 &!
          local pid=$!

          while kill -0 $pid 2>/dev/null; do
            _vm_running $name && { print "$name: running, log at $log"; return; }
            sleep 0.2
          done

          print -u2 "$name: qemu exited"
          tail -n 20 -- "$log" >&2
          return 1
        }

        _vm_stop() {
          _vm_running $1 || { print -u2 "$1: not running"; return 1; }
          if [[ $2 == --force ]]; then _vm_monitor $1 quit; else _vm_monitor $1 system_powerdown; fi
        }

        _vm_ssh() {
          local port=$1 user=$2
          shift 2
          ssh -p $port -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR \
            "$user@localhost" "$@"
        }

        vm-build() {
          local dir=$(_vm_dir)
          mkdir -p -- "$dir" && nh os build-vm --diff never -H vm -o "$dir/result" ${flakeDir} "$@"
        }

        vm() {
          local dir=$(_vm_dir) extra=()
          [[ $1 == --headless ]] && { extra=(-display egl-headless); shift; }
          _vm_running vm && { print -u2 "vm: already running"; return 1; }
          vm-build || return

          _vm_launch vm "$dir/qemu.log" \
            env NIX_DISK_IMAGE="$dir/vm.qcow2" "$dir/result/bin/run-vm-vm" "''${extra[@]}" "$@"
        }

        vm-ssh() { _vm_ssh 2222 ${username} "$@"; }

        vm-stop() { _vm_stop vm "$@"; }

        vm-reset() {
          local disk="$(_vm_dir)/vm.qcow2"
          _vm_running vm && { print -u2 "vm: running, run vm-stop first"; return 1; }
          [[ -e $disk ]] || { print "vm: no disk image"; return; }
          read -q "?vm: delete $disk? [y/N] " && rm -- "$disk"
          print
        }

        _vm_iso_run() {
          local dir=$(_vm_dir) key="$HOME/.ssh/id_ed25519.pub" cred=()
          _vm_running vm-iso && { print -u2 "vm-iso: already running"; return 1; }
          mkdir -p -- "$dir"
          [[ -e $dir/install.qcow2 ]] || ${qemu-img} create -q -f qcow2 "$dir/install.qcow2" 64G || return
          [[ -e $dir/install-vars.fd ]] || install -m 644 -- ${ovmf}/OVMF_VARS.fd "$dir/install-vars.fd" || return
          [[ -r $key ]] && cred=(-fw_cfg "name=opt/io.systemd.credentials/ssh.authorized_keys.root,file=$key")

          _vm_launch vm-iso "$dir/install.log" ${qemu} \
            -name vm-iso -machine q35,accel=kvm -cpu host -smp 4 -m 8192 \
            -drive if=pflash,format=raw,readonly=on,file=${ovmf}/OVMF_CODE.fd \
            -drive "if=pflash,format=raw,file=$dir/install-vars.fd" \
            -drive "if=none,id=disk,format=qcow2,file=$dir/install.qcow2" \
            -device virtio-blk-pci,drive=disk,serial=install-test,bootindex=1 \
            -nic user,model=virtio-net-pci,hostfwd=tcp:127.0.0.1:2223-:22 \
            -vga none -device virtio-vga -display gtk,show-menubar=off \
            "''${cred[@]}" "$@"
        }

        vm-iso() {
          local dir=$(_vm_dir)
          mkdir -p -- "$dir" && nix build -o "$dir/iso" ${flakeDir}#iso || return

          local iso=("$dir"/iso/iso/*.iso(N))
          (( $#iso )) || { print -u2 "vm-iso: no .iso in $dir/iso/iso"; return 1; }

          _vm_iso_run \
            -drive "if=none,id=cd,media=cdrom,readonly=on,file=$iso[1]" \
            -device ide-cd,drive=cd,bootindex=0 "$@"
        }

        vm-iso-boot() { _vm_iso_run "$@"; }

        vm-iso-ssh() { _vm_ssh 2223 root "$@"; }

        vm-iso-stop() { _vm_stop vm-iso "$@"; }

        vm-iso-reset() {
          local dir=$(_vm_dir)
          _vm_running vm-iso && { print -u2 "vm-iso: running, run vm-iso-stop first"; return 1; }
          [[ -e $dir/install.qcow2 || -e $dir/install-vars.fd ]] || { print "vm-iso: no install disk"; return; }
          read -q "?vm-iso: delete the install disk and its UEFI vars? [y/N] " &&
            rm -f -- "$dir/install.qcow2" "$dir/install-vars.fd"
          print
        }

        vm-status() {
          local dir=$(_vm_dir)
          if _vm_running vm; then print "vm:      running"; else print "vm:      stopped"; fi
          [[ -e $dir/vm.qcow2 ]] && print "  disk:   $(command du -h -- "$dir/vm.qcow2" | cut -f1)"
          [[ -e $dir/result ]] && print "  system: $(readlink -- "$dir/result/system")"
          if _vm_running vm-iso; then print "vm-iso:  running"; else print "vm-iso:  stopped"; fi
          [[ -e $dir/install.qcow2 ]] && print "  disk:   $(command du -h -- "$dir/install.qcow2" | cut -f1)"
          return 0
        }
      '';
    };
}
