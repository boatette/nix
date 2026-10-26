{ inputs, ... }:
let
  # nvim talks to the socket; llama-server sits behind the proxy on the next port
  port = 8012;
  serverPort = 8013;
in
{
  flake.modules.homeManager.nvim =
    { lib, pkgs, ... }:
    let
      model = pkgs.fetchurl {
        url = "https://huggingface.co/ggml-org/Qwen2.5-Coder-1.5B-Q8_0-GGUF/resolve/main/qwen2.5-coder-1.5b-q8_0.gguf";
        hash = "sha256-KYcclNFXJ6biQ/eaNxE9SuYlpiFbXoAL9Bojry2jKDI=";
      };

      # holds the proxy back until the model is loaded, so the first request isn't refused
      waitForServer = pkgs.writeShellScript "llama-fim-wait" ''
        until ${lib.getExe pkgs.curl} -sf http://127.0.0.1:${toString serverPort}/health >/dev/null; do
          sleep 0.2
        done
      '';
    in
    {
      systemd.user = {
        sockets.llama-fim = {
          Unit.Description = "Code completion model for nvim";
          Socket.ListenStream = "127.0.0.1:${toString port}";
          Install.WantedBy = [ "sockets.target" ];
        };

        # exits after five quiet minutes, which stops the server and lets the dGPU sleep again
        services.llama-fim = {
          Unit = {
            Description = "Proxy to the nvim code completion model";
            Requires = [ "llama-fim-server.service" ];
            After = [ "llama-fim-server.service" ];
          };
          Service.ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=5min 127.0.0.1:${toString serverPort}";
        };

        services.llama-fim-server = {
          Unit = {
            Description = "llama.cpp serving the nvim code completion model";
            StopWhenUnneeded = true;
            # off on battery; nvim stops asking too
            ConditionACPower = true;
          };

          Service = {
            # only the nvidia icd, so the RTX 2050 is the one device and the iGPU is left alone
            Environment = [ "VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json" ];
            # llama-server's --fim-qwen-1.5b-default, with a smaller context to leave VRAM for ComfyUI
            ExecStart = lib.concatStringsSep " " [
              (lib.getExe' pkgs.llama-cpp-vulkan "llama-server")
              "-m ${model}"
              "--host 127.0.0.1"
              "--port ${toString serverPort}"
              "--no-ui"
              # curl sends no Origin, so this only turns away web pages in the browser
              "--cors-origins localhost"
              "-ngl 99"
              "-fa on"
              "-ub 1024"
              "-b 1024"
              "-c 8192"
              "--cache-reuse 256"
            ];
            ExecStartPost = waitForServer;
            TimeoutStartSec = 60;
          };
        };
      };
    };

  flake.modules.nvf.nvim =
    { lib, pkgs, ... }:
    let
      inherit (lib.generators) mkLuaInline;
    in
    {
      vim = {
        # not lazy: auto-trigger is switched on per buffer from a FileType autocmd
        lazy.plugins."minuet-ai.nvim" = {
          package = pkgs.vimPlugins.minuet-ai-nvim;
          setupModule = "minuet";

          setupOpts = {
            provider = "openai_fim_compatible";
            n_completions = 1;
            context_window = 8000;
            debounce = 300;
            # long enough for a cold start of the server
            request_timeout = 5;
            notify = "error";
            curl_cmd = lib.getExe pkgs.curl;

            # the server won't start on battery either
            enable_predicates = [
              (mkLuaInline /* lua */ ''
                function()
                    for _, status in ipairs(vim.fn.glob("/sys/class/power_supply/BAT*/status", false, true)) do
                        if vim.fn.readfile(status)[1] == "Discharging" then
                            return false
                        end
                    end
                    return true
                end
              '')
            ];

            # accepting the whole suggestion is on <Tab>, through blink below
            virtualtext = {
              auto_trigger_ft = [ "*" ];
              keymap = {
                accept_line = "<A-a>";
                dismiss = "<A-e>";
              };
            };

            provider_options.openai_fim_compatible = {
              name = "llama.cpp";
              end_point = "http://127.0.0.1:${toString port}/v1/completions";
              model = "qwen2.5-coder-1.5b";
              api_key = mkLuaInline ''function() return "local" end'';
              stream = true;

              optional = {
                max_tokens = 64;
                top_p = 0.9;
              };

              # llama.cpp ignores suffix, so the prompt carries Qwen's FIM tokens itself
              template = {
                prompt = mkLuaInline /* lua */ ''
                  function(before, after)
                      return "<|fim_prefix|>" .. before .. "<|fim_suffix|>" .. after .. "<|fim_middle|>"
                  end
                '';
                suffix = false;
              };
            };
          };
        };

        # super-tab's <Tab> with the AI suggestion slotted in before the snippet jump
        autocomplete.blink-cmp.setupOpts.keymap."<Tab>" = [
          (mkLuaInline /* lua */ ''
            function(cmp)
                if cmp.snippet_active() then
                    return cmp.accept()
                else
                    return cmp.select_and_accept()
                end
            end
          '')
          (mkLuaInline /* lua */ ''
            function()
                local ok, virtualtext = pcall(require, "minuet.virtualtext")
                if ok and virtualtext.action.is_visible() then
                    virtualtext.action.accept()
                    return true
                end
            end
          '')
          "snippet_forward"
          "fallback"
        ];

        keymaps = [
          (inputs.self.lib.nvim.cmd "n" "<leader>ua" "<cmd>Minuet virtualtext toggle<cr>"
            "Toggle AI completion"
          )
        ];
      };
    };
}
