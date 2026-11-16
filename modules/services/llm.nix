{ inputs, ... }:
{
  # local chat and coding models behind one llama-server, with the weights on the ssd
  flake.modules.nixos.llm.home-manager.sharedModules = [ inputs.self.modules.homeManager.llm ];

  flake.modules.homeManager.llm =
    { lib, pkgs, ... }:
    let
      root = "/mnt/storage/ai/llm";
      port = 8191;

      # every preset key is a llama-server long flag without the dashes. sizes and speeds were
      # measured on aspire (16 GB RAM, 4 GB RTX 2050) on 2026-11-16
      defaults = {
        # the rtx 2050; Vulkan0 is the intel gpu, which shares system ram
        device = "Vulkan1";
        # vram left free when llama.cpp picks what goes on the card: the default 1024 left a quarter
        # of it empty (3.6 t/s on the 35b against 14.5; 150 was no faster)
        fit-target = 300;
        # 6 and 8 gave the same speed, the default 4 was 10% slower
        threads = 6;
        # read in rather than mapped: mapped, pages of the last model stayed counted against the cap
        # after a switch and the new one paged from the usb disk at 1-5 t/s
        load-mode = "none";
        # with the defaults (8192 MiB, 32 checkpoints) the 35b grew past the cap mid opencode task
        cache-ram = 0;
        ctx-checkpoints = 2;
        # a looping answer otherwise holds the only slot: opencode's title request once ran past
        # 9,000 tokens while the real task waited
        predict = 8192;
        ctx-size = 32768;
        parallel = 1;
        jinja = true;
      };

      # thinking-mode sampling from the qwen model cards
      thinking = {
        temp = 1.0;
        top-p = 0.95;
        top-k = 20;
      };

      # the small ones sit wholly on the card at 16k context; at 32k the 4b pushed layers off it
      # (20.4 t/s) and so did its q6_k file (12.4 t/s)
      quick = {
        no-mmproj = true;
        ctx-size = 16384;
        reasoning = "off";
        temp = 0.7;
        top-p = 0.8;
        top-k = 20;
        presence-penalty = 1.5;
      };

      # decensored builds. the big two are the largest files that fit the 12G cap with nothing
      # swapped: unsloth's 35b UD-Q3_K_S and 27b UD-IQ4_XS took 12.5 and 12.7 GB. no image input:
      # the 27b with its vision projector is killed at the cap while loading, even at 8k context
      models = [
        {
          # 13.5 GB, 17.3 t/s, 11.6 GB ram, 3.4 GB vram, 25 s to load
          id = "qwen3.6-35b-a3b";
          name = "Qwen3.6-35B-A3B uncensored (fast)";
          url = "https://huggingface.co/TokenTinkerer/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-TTQ-GGUF/resolve/868d7affcb391a810387c5cfdc6116ee47f9eaea/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-TTQ-3.33bpw-IQ3_XXS.gguf";
          sha256 = "c1e4dc98016f7f11be7ec595cc1273f576570fcdc86876706e21f6ec44c8137a";
          file = "Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-TTQ-3.33bpw-IQ3_XXS.gguf";
          code = true;
          preset = thinking // {
            # opencode's title request once spent a whole 4096 (4.5 minutes) before the task began
            reasoning-budget = 2048;
            # the card's sampling for precise coding
            temp = 0.6;
          };
        }
        {
          # 11.9 GB, 1.5 t/s, 11.5 GB ram, 3.5 GB vram, 60 s to load. its mtp draft head gave
          # 1.77 t/s for 2.3 GB more memory
          id = "qwen3.8-27b";
          name = "Qwen3.8-27B uncensored (smartest)";
          url = "https://huggingface.co/mradermacher/Qwen3.8-27B-heretic-ara-i1-GGUF/resolve/84623b1bd7236f7a10e1d80d25bcbe36b5efbdd4/Qwen3.8-27B-heretic-ara.i1-IQ3_M.gguf";
          sha256 = "c7fb6283c47e5c7da3221e21c8cee228999d7102cc5d720ca646741fc240473c";
          file = "Qwen3.8-27B-heretic-ara.i1-IQ3_M.gguf";
          code = true;
          # at 1.5 t/s, 1024 tokens of thinking is already 11 minutes
          preset = thinking // {
            reasoning-budget = 1024;
          };
        }
        {
          # 2.5 GB, 31.7 t/s, 3.3 GB vram
          id = "qwen3.5-4b";
          name = "Qwen3.5-4B uncensored (quick)";
          url = "https://huggingface.co/HauhauCS/Qwen3.5-4B-Uncensored-HauhauCS-Aggressive/resolve/c09cdbcdb1fefad6d335809d445621b5f5ba0c6e/Qwen3.5-4B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf";
          sha256 = "79e28ecacf84e75b6056cf4059636d435aa9eb67795780f7b7dbc7d32a962741";
          file = "Qwen3.5-4B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf";
          preset = quick;
        }
        {
          # 1.9 GB, 45.1 t/s, 2.2 GB vram
          id = "qwen3.5-2b";
          name = "Qwen3.5-2B uncensored (quickest)";
          url = "https://huggingface.co/HauhauCS/Qwen3.5-2B-Uncensored-HauhauCS-Aggressive/resolve/2bcf35c1ebf62c837c12c1aa90b578ff4717e831/Qwen3.5-2B-Uncensored-HauhauCS-Aggressive-Q8_0.gguf";
          sha256 = "3d6ba5655ffb7be0108607b8764ba33920ad23335f08d683806bfa979d838793";
          file = "Qwen3.5-2B-Uncensored-HauhauCS-Aggressive-Q8_0.gguf";
          preset = quick;
        }
      ];

      presets = pkgs.writeText "llm-presets.ini" (
        lib.generators.toINI { } (
          {
            "*" = defaults;
          }
          // lib.listToAttrs (
            map (m: lib.nameValuePair m.id (m.preset // { model = "${root}/models/${m.file}"; })) models
          )
        )
      );

      llm = pkgs.local.llm.override { inherit models port root; };
    in
    {
      home.packages = [ llm ];

      # started by llm, not at login: the router is idle until asked, but nothing else here wants it
      systemd.user.services.llm = {
        Unit.Description = "llama-server with the local models";
        Service = {
          # --models-max 1: asking for one model unloads the other
          ExecStart = lib.concatStringsSep " " [
            (lib.getExe' pkgs.llama-cpp-vulkan "llama-server")
            "--models-preset ${presets}"
            "--models-max 1"
            "--host 127.0.0.1"
            "--port ${toString port}"
          ];
          # the weights can't be dropped under pressure and swap here is zram, which is ram again. a
          # 13G cap with swap froze the whole machine on 2026-11-16, so: 3 GB left for the desktop,
          # no swap, and past the cap only the model process dies while the router stays up
          MemoryMax = "12G";
          MemorySwapMax = 0;
          OOMPolicy = "continue";
        };
      };

      programs.opencode = {
        enable = true;

        settings = {
          provider.local = {
            npm = "@ai-sdk/openai-compatible";
            name = "Local (llama.cpp)";
            options.baseURL = "http://127.0.0.1:${toString port}/v1";
            models = lib.listToAttrs (
              map (
                m:
                lib.nameValuePair m.id {
                  inherit (m) name;
                  limit = {
                    context = m.preset.ctx-size or defaults.ctx-size;
                    output = defaults.predict;
                  };
                }
              ) (lib.filter (m: m.code or false) models)
            );
          };
          model = "local/qwen3.6-35b-a3b";
        };
      };
    };
}
