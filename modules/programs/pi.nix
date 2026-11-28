{
  flake.modules.homeManager.boatette = {
    programs.pi-coding-agent = {
      enable = true;

      settings = {
        defaultModel = "qwen3.5-4b";
        defaultProvider = "llama.cpp";
      };
    };

    # pi's llama.cpp provider stays hidden until this or /login names the router
    home.sessionVariables.LLAMA_BASE_URL = "http://127.0.0.1:9931";
  };
}
