{
  flake.modules.nixvim.nvim =
    { lib, ... }:
    let
      inherit (lib.nixvim) mkRaw;

      promptProgram =
        start:
        mkRaw ''
          function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "${start}", "file")
          end
        '';

      pickProcess = mkRaw ''require("dap.utils").pick_process'';

      lldbLaunch = start: {
        name = "Launch";
        type = "lldb";
        request = "launch";
        program = promptProgram start;
        cwd = "\${workspaceFolder}";
        stopOnEntry = false;
      };

      cLike = [
        (lldbLaunch "/")
        {
          name = "Attach";
          type = "lldb";
          request = "attach";
          pid = pickProcess;
          cwd = "\${workspaceFolder}";
        }
      ];

      jsLike = [
        {
          name = "Launch file";
          type = "pwa-node";
          request = "launch";
          program = "\${file}";
          cwd = "\${workspaceFolder}";
          sourceMaps = true;
        }
        {
          name = "Attach to process";
          type = "pwa-node";
          request = "attach";
          processId = pickProcess;
          cwd = "\${workspaceFolder}";
          sourceMaps = true;
        }
        {
          name = "React Native: attach to Metro (Android)";
          type = "pwa-node";
          request = "attach";
          port = 8081;
          cwd = "\${workspaceFolder}";
          sourceMaps = true;
          sourceMapPathOverrides."metro://localhost/*" = "\${workspaceFolder}/*";
        }
        {
          name = "React Native: attach to Metro (iOS)";
          type = "pwa-node";
          request = "attach";
          port = 8081;
          cwd = "\${workspaceFolder}";
          sourceMaps = true;
          platform = "ios";
        }
      ];

      dapMap = key: expr: desc: {
        mode = "n";
        inherit key;
        action = mkRaw ''
          function()
              require("dap").${expr}
          end
        '';
        options.desc = desc;
      };
    in
    {
      plugins.dap = {
        enable = true;

        adapters.executables = {
          lldb = {
            command = "lldb-dap";
            id = "lldb";
          };

          dart = {
            command = "dart";
            args = [ "debug_adapter" ];
          };
          flutter = {
            command = "flutter";
            args = [ "debug-adapter" ];
          };

          kotlin.command = "kotlin-debug-adapter";

          python = {
            command = "python3";
            args = [
              "-m"
              "debugpy.adapter"
            ];
          };
        };

        adapters.servers."pwa-node" = {
          host = "localhost";
          port = "\${port}";
          executable = {
            command = "js-debug";
            args = [ "\${port}" ];
          };
        };

        configurations = {
          c = cLike;
          cpp = cLike;
          odin = [ (lldbLaunch "/") ];
          zig = [ (lldbLaunch "/zig-out/bin/") ];

          javascript = jsLike;
          typescript = jsLike;
          javascriptreact = jsLike;
          typescriptreact = jsLike;

          dart = [
            {
              name = "Launch Dart";
              type = "dart";
              request = "launch";
              program = "\${workspaceFolder}/lib/main.dart";
              cwd = "\${workspaceFolder}";
            }
            {
              name = "Launch Flutter";
              type = "flutter";
              request = "launch";
              program = "\${workspaceFolder}/lib/main.dart";
              cwd = "\${workspaceFolder}";
              flutterMode = "debug";
            }
          ];

          kotlin = [
            {
              name = "Launch Kotlin Program";
              type = "kotlin";
              request = "launch";
              projectRoot = "\${workspaceFolder}";
              mainClass = "MainKt";
            }
          ];

          python = [
            {
              name = "Launch file";
              type = "python";
              request = "launch";
              program = "\${file}";
              pythonPath = mkRaw ''
                function()
                    return vim.fn.exepath("python3") or "python"
                end
              '';
            }
          ];
        };
      };

      extraConfigLua = ''
        do
            local dap = require("dap")
            local dapview = require("dap-view")

            dapview.setup()

            dap.listeners.after.event_initialized["dap-view"] = function()
                dapview.open()
            end
            dap.listeners.before.event_terminated["dap-view"] = function()
                dapview.close()
            end
            dap.listeners.before.event_exited["dap-view"] = function()
                dapview.close()
            end
        end
      '';

      keymaps = [
        (dapMap "<leader>db" "toggle_breakpoint()" "Toggle breakpoint")
        (dapMap "<leader>dB" ''set_breakpoint(vim.fn.input("Condition: "))'' "Conditional breakpoint")
        (dapMap "<leader>dc" "continue()" "Continue")
        (dapMap "<leader>dn" "step_over()" "Step over")
        (dapMap "<leader>di" "step_into()" "Step into")
        (dapMap "<leader>do" "step_out()" "Step out")
        (dapMap "<leader>dl" "run_last()" "Run last")
        (dapMap "<leader>dx" "terminate()" "Terminate")
        {
          mode = "n";
          key = "<leader>dv";
          action = mkRaw ''function() require("dap-view").toggle() end'';
          options.desc = "Toggle DAP view";
        }
      ];
    };
}
