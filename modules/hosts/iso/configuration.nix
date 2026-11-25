{ inputs, withSystem, ... }:
let
  inherit (inputs.self.nixosConfigurations.aspire.config.system) build;
in
{
  flake.nixosConfigurations.iso = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      (
        {
          lib,
          modulesPath,
          pkgs,
          ...
        }:
        {
          imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];

          networking.hostName = "iso";

          nixpkgs = {
            hostPlatform = "x86_64-linux";
            pkgs = withSystem "x86_64-linux" ({ pkgs, ... }: pkgs);
          };

          # aspire's whole closure reaches the squashfs through this reference
          environment.systemPackages = [
            (pkgs.local.install.override {
              prebuilt = build.toplevel;
              diskoScript = build.destroyFormatMount;
            })
          ];

          # replaces the installer profile's text; \e{...} is agetty's issue-file colour escape
          services.getty.helpLine = lib.mkForce ''

            \e{bold}Install aspire, offline\e{reset}
              install              erase aspire's disk and install the system on this stick
              install --dry-run    show the plan and disko script, change nothing
          '';

          isoImage = {
            volumeID = "nixos-aspire";
            squashfsCompression = "zstd -Xcompression-level 6";
          };
        }
      )
    ];
  };

  perSystem = _: {
    packages.iso = inputs.self.nixosConfigurations.iso.config.system.build.isoImage;
  };
}
