{ inputs, ... }:
{
  flake.modules.nixos.aspire =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (inputs.self.constants) username;
      inherit (config.users.users.${username}) home;
      cache = "${home}/ai-models/llm";

      # pi's default llama.cpp url
      port = 9931;

      package = pkgs.llama-cpp.override { cudaSupport = true; };

      # heretic builds; --fit places layers and moe experts to suit the 4 GB card
      models = {
        "qwen3.5-4b" = {
          hf-repo = "mradermacher/Qwen3.5-4B-heretic-i1-GGUF:Q4_K_M";
          c = 32768;
        };
        # 26b moe with 4b active, experts stream from ram
        "gemma4-26b" = {
          hf-repo = "mradermacher/gemma-4-26B-A4B-it-heretic-i1-GGUF:IQ3_M";
          c = 16384;
        };
      };

      preset = lib.generators.toINIWithGlobalSection { } {
        globalSection.version = 1;
        sections = models // {
          # with fit's 1 GB margin and 4 slots, 13 of the 4b's 33 layers spilled to the cpu
          "*" = {
            cache-type-k = "q8_0";
            cache-type-v = "q8_0";
            fit-target = 256;
            parallel = 1;
            ubatch-size = 256;
          };
        };
      };
    in
    {
      services.llama-cpp = {
        enable = true;
        inherit package;

        settings = {
          # the firewall only opens it on tailscale0, for the web ui on the phone
          host = "0.0.0.0";
          # one model at a time on 4 GB of vram
          models-max = 1;
          models-preset = pkgs.writeText "llama-cpp-models.ini" preset;
          inherit port;
          # unloads the model so the dgpu can sleep again
          sleep-idle-seconds = 300;
        };
      };

      # the models live in ~/ai-models with comfy's, so ssd backs them up and can restore them
      systemd.services.llama-cpp.serviceConfig = {
        BindPaths = [ cache ];
        DynamicUser = lib.mkForce false;
        Environment = lib.mkForce [ "LLAMA_CACHE=${cache}" ];
        Group = "users";
        ProtectHome = lib.mkForce "tmpfs";
        User = username;
      };
      systemd.tmpfiles.rules = [
        "d ${home}/ai-models 0755 ${username} users -"
        "d ${cache} 0755 ${username} users -"
      ];

      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ port ];

      environment.systemPackages = [ package ];

      nix.settings = {
        extra-substituters = [ "https://cache.nixos-cuda.org" ];
        extra-trusted-public-keys = [
          "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        ];
      };
    };
}
