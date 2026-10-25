{
  flake.modules.homeManager.vm =
    { config, pkgs, ... }:
    let
      # usage: iso-vm [--build] [file.iso] [quickemu args...]; with no iso, boots the last one --build made
      iso-vm = pkgs.writeShellApplication {
        name = "iso-vm";
        runtimeInputs = [ pkgs.quickemu ];
        text = ''
          build=false
          iso=""

          if [[ ''${1-} == --build ]]; then
            build=true
            shift
          fi

          if [[ ''${1-} == *.iso ]]; then
            iso=$(realpath "$1")
            shift
          fi

          mkdir -p "$HOME/VMs/nixos-iso"
          cd "$HOME/VMs"

          if $build; then
            nix build "${config.constants.flakeDir}#iso" --out-link nixos-iso/result
          fi

          if [[ -z $iso ]]; then
            isos=(nixos-iso/result/iso/*.iso)
            if [[ ! -e ''${isos[0]} ]]; then
              echo "no iso built yet; run nbiv, or pass a path to one" >&2
              exit 1
            fi
            iso=''${isos[0]}
          fi

          cat > nixos-iso.conf <<EOF
          guest_os="linux"
          iso="$iso"
          disk_img="nixos-iso/disk.qcow2"
          disk_size="32G"
          secureboot="off"
          EOF

          exec quickemu --vm nixos-iso.conf "$@"
        '';
      };
    in
    {
      home = {
        packages = [
          pkgs.quickemu
          iso-vm
        ];

        shellAliases = {
          nbiv = "iso-vm --build";
          niv = "iso-vm";
        };
      };
    };
}
