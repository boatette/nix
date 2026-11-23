{
  flake.modules.homeManager.boatette.programs.noctalia.settings.calendar = {
    enabled = true;

    account.personal_google = {
      name = "Personal Calendar";
      type = "google";
    };
  };
}
