{
  flake.modules.homeManager.git.programs.delta = {
    enable = true;
    enableGitIntegration = true;

    options = {
      navigate = true;
      line-numbers = true;
      hyperlinks = true;
    };
  };
}
