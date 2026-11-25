{
  flake.modules.nixos.aspire =
    { lib, ... }:
    {
      services.pipewire = {
        enable = true;
        alsa = {
          enable = true;
          # steam turns this on, but every game here reaches pipewire through pulse (sdl, winepulse, openal)
          support32Bit = lib.mkForce false;
        };
        pulse.enable = true;
      };

      security.rtkit.enable = true;
    };
}
