{
  flake.modules.nixos.base.services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };
}
