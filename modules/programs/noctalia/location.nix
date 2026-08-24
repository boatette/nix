{
  flake.modules.homeManager.noctalia.programs.noctalia.settings = {
    location.auto_locate = true;

    calendar = {
      enabled = true;

      account.personal_google = {
        name = "Personal Calendar";
        type = "google";
      };
    };
  };
}
