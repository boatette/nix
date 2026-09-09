{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.lockscreen = {
    enabled = true;

    fingerprint = true;
    allow_empty_password = false;
    lock_before_suspend = true;

    blur_intensity = 0.7;
    tint_intensity = 0.3;
  };
}
