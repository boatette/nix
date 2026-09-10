{
  flake.modules.nvf.nvim =
    { lib, pkgs, ... }:
    let
      inherit (lib.generators) mkLuaInline;
      inherit (lib.nvim.dag) entryAfter;

      promptProgram =
        start:
        mkLuaInline ''
          function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "${start}", "file")
          end
        '';

      pickProcess = mkLuaInline ''require("dap.utils").pick_process'';

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
        inherit key desc;
        action = ''
          function()
              require("dap").${expr}
          end
        '';
        lua = true;
        silent = false;
      };
    in
    {
      vim = {
        extraPackages = with pkgs; [
          lldb
          vscode-js-debug
          (python3.withPackages (ps: [ ps.debugpy ]))
        ];

        extraPlugins.nvim-dap-view = {
          package = pkgs.vimPlugins.nvim-dap-view;
          setup = "";
        };

        debugger.nvim-dap = {
          enable = true;

          adapters = {
            lldb = {
              type = "executable";
              command = "lldb-dap";
              id = "lldb";
            };

            dart = {
              type = "executable";
              command = "dart";
              args = [ "debug_adapter" ];
            };

            flutter = {
              type = "executable";
              command = "flutter";
              args = [ "debug-adapter" ];
            };

            kotlin = {
              type = "executable";
              command = "kotlin-debug-adapter";
            };

            python = {
              type = "executable";
              command = "python3";
              args = [
                "-m"
                "debugpy.adapter"
              ];
            };

            "pwa-node" = {
              type = "server";
              host = "localhost";
              port = "\${port}";
              executable = {
                command = "js-debug";
                args = [ "\${port}" ];
              };
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
                pythonPath = mkLuaInline ''
                  function()
                      return vim.fn.exepath("python3") or "python"
                  end
                '';
              }
            ];
          };
        };

        luaConfigRC.dap-view = entryAfter [ "extraPluginConfigs" ] ''
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
            action = ''function() require("dap-view").toggle() end'';
            lua = true;
            desc = "Toggle DAP view";
            silent = false;
          }
        ];
      };
    };
}
