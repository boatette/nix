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
          # the i1 repos carry no projector; the static one's sees pictures, for petal's chat
          mmproj-url = "https://huggingface.co/mradermacher/Qwen3.5-4B-heretic-GGUF/resolve/main/Qwen3.5-4B-heretic.mmproj-Q8_0.gguf";
          c = 32768;
        };
        # 26b moe with 4b active, experts stream from ram
        "gemma4-26b" = {
          hf-repo = "mradermacher/gemma-4-26B-A4B-it-heretic-i1-GGUF:IQ3_M";
          # heretic only changes the language weights, so the base model's projector fits
          mmproj-url = "https://huggingface.co/ggml-org/gemma-4-26B-A4B-it-GGUF/resolve/main/mmproj-gemma-4-26B-A4B-it-Q8_0.gguf";
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
            # the projector runs on the cpu, leaving the 4 GB card to the language layers
            no-mmproj-offload = true;
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
        # past 12G the service is killed instead of freezing the laptop; no swap to hide in
        MemoryMax = "12G";
        MemorySwapMax = 0;
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
