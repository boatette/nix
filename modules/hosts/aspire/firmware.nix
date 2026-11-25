{
  flake.modules.nixos.aspire =
    { pkgs, ... }:
    {
      hardware = {
        enableRedistributableFirmware = false;
        wirelessRegulatoryDatabase = true;

        # linux-firmware is 825M for every device ever made; this is what aspire's drivers load
        firmware = [
          pkgs.sof-firmware
          (pkgs.runCommand "linux-firmware-aspire" { } ''
            cd ${pkgs.linux-firmware}/lib/firmware
            mkdir -p $out/lib/firmware
            cp -R --parents --no-preserve=mode i915 xe rtl_nic mediatek/*MT7961* $out/lib/firmware
          '')
        ];
      };
    };
}
