{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.calendar = {
    enabled = true;

    account.personal_google = {
      name = "Personal Calendar";
      type = "google";
    };
  };
}
