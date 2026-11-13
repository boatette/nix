{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    { lib, pkgs, ... }:
    let
      inherit (lib.generators) mkLuaInline;
      inherit (lib.nvim.dag) entryAfter;

      pickProcess = mkLuaInline ''require("dap.utils").pick_process'';

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

      cAttach = lib.mkAfter [
        {
          name = "Attach";
          type = "lldb";
          request = "attach";
          pid = pickProcess;
          cwd = "\${workspaceFolder}";
        }
      ];

      dapMap = key: expr: inputs.self.lib.nvim.mod "n" key "dap" expr;
    in
    {
      vim = {
        # lldb-dap for c, c++, odin and zig, debugpy for python, each by store path
        languages = lib.genAttrs [ "clang" "odin" "python" "zig" ] (_: {
          dap.enable = true;
        });

        debugger.nvim-dap = {
          enable = true;

          adapters."pwa-node" = {
            type = "server";
            host = "localhost";
            port = "\${port}";
            executable = {
              command = lib.getExe' pkgs.vscode-js-debug "js-debug";
              args = [ "\${port}" ];
            };
          };

          configurations = {
            c = cAttach;
            cpp = cAttach;

            # nvf's launch prompt starts at the project root, but zig build installs to zig-out/bin
            zig = lib.mkForce [
              {
                name = "Launch";
                type = "lldb";
                request = "launch";
                program = mkLuaInline ''
                  function()
                      return nvf_dap_cached_input(
                          "zig_lldb_launch_exe",
                          "Path to executable: ",
                          vim.fn.getcwd() .. "/zig-out/bin/",
                          "file"
                      )
                  end
                '';
                cwd = "\${workspaceFolder}";
                stopOnEntry = false;
              }
            ];

            javascript = jsLike;
            typescript = jsLike;
            javascriptreact = jsLike;
            typescriptreact = jsLike;
          };
        };

        lazy.plugins.nvim-dap-view = {
          package = pkgs.vimPlugins.nvim-dap-view;
          setupModule = "dap-view";

          keys = [ (inputs.self.lib.nvim.mod "n" "<leader>dv" "dap-view" "toggle()" "Toggle DAP view") ];
        };

        luaConfigRC.dap-view = entryAfter [ "pluginConfigs" ] ''
          do
              local dap = require("dap")

              dap.listeners.after.event_initialized["dap-view"] = function()
                  require("dap-view").open()
              end
              dap.listeners.before.event_terminated["dap-view"] = function()
                  require("dap-view").close()
              end
              dap.listeners.before.event_exited["dap-view"] = function()
                  require("dap-view").close()
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
        ];
      };
    };
}
