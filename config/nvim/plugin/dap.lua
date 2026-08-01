vim.api.nvim_create_autocmd("LspAttach", {
    callback = function()
        local dap = require("dap")
        local dapview = require("dap-view")
        local bin = vim.fn.stdpath("data") .. "/mason/bin"

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

        dap.adapters.codelldb = {
            type = "server",
            port = "${port}",
            executable = { command = bin .. "/codelldb", args = { "--port", "${port}" } },
        }
        dap.adapters.dart = {
            type = "executable",
            command = bin .. "/dart-debug-adapter",
            args = { "dart" },
        }
        dap.adapters.flutter = {
            type = "executable",
            command = bin .. "/dart-debug-adapter",
            args = { "flutter" },
        }
        dap.adapters.kotlin = {
            type = "executable",
            command = bin .. "/kotlin-debug-adapter",
        }
        dap.adapters["pwa-node"] = {
            type = "server",
            host = "localhost",
            port = "${port}",
            executable = {
                command = "node",
                args = {
                    vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
                    "${port}",
                },
            },
        }
        dap.adapters.python = {
            type = "executable",
            command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
            args = { "-m", "debugpy.adapter" },
        }

        local pick = require("dap.utils").pick_process

        for _, ft in ipairs({ "c", "cpp" }) do
            dap.configurations[ft] = {
                {
                    name = "Launch",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                },
                {
                    name = "Attach",
                    type = "codelldb",
                    request = "attach",
                    pid = pick,
                    cwd = "${workspaceFolder}",
                },
            }
        end

        dap.configurations.dart = {
            {
                name = "Launch Dart",
                type = "dart",
                request = "launch",
                program = "${workspaceFolder}/lib/main.dart",
                cwd = "${workspaceFolder}",
            },
            {
                name = "Launch Flutter",
                type = "flutter",
                request = "launch",
                program = "${workspaceFolder}/lib/main.dart",
                cwd = "${workspaceFolder}",
                flutterMode = "debug",
            },
        }

        for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
            dap.configurations[ft] = {
                {
                    name = "Launch file",
                    type = "pwa-node",
                    request = "launch",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                    sourceMaps = true,
                },
                {
                    name = "Attach to process",
                    type = "pwa-node",
                    request = "attach",
                    processId = pick,
                    cwd = "${workspaceFolder}",
                    sourceMaps = true,
                },
                {
                    name = "React Native: attach to Metro (Android)",
                    type = "pwa-node",
                    request = "attach",
                    port = 8081,
                    cwd = "${workspaceFolder}",
                    sourceMaps = true,
                    sourceMapPathOverrides = { ["metro://localhost/*"] = "${workspaceFolder}/*" },
                },
                {
                    name = "React Native: attach to Metro (iOS)",
                    type = "pwa-node",
                    request = "attach",
                    port = 8081,
                    cwd = "${workspaceFolder}",
                    sourceMaps = true,
                    platform = "ios",
                },
            }
        end

        dap.configurations.kotlin = {
            {
                type = "kotlin",
                request = "launch",
                name = "Launch Kotlin Program",
                projectRoot = "${workspaceFolder}",
                mainClass = "MainKt",
            },
        }

        dap.configurations.odin = {
            {
                name = "Launch",
                type = "codelldb",
                request = "launch",
                program = function()
                    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                end,
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
            },
        }

        dap.configurations.python = {
            {
                name = "Launch file",
                type = "python",
                request = "launch",
                program = "${file}",
                pythonPath = function()
                    return vim.fn.exepath("python3") or "python"
                end,
            },
        }

        dap.configurations.zig = {
            {
                name = "Launch",
                type = "codelldb",
                request = "launch",
                program = function()
                    return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/zig-out/bin/", "file")
                end,
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
            },
        }

        local map = vim.keymap.set
        map("n", "<leader>db", function()
            dap.toggle_breakpoint()
        end, { desc = "Toggle breakpoint" })
        map("n", "<leader>dB", function()
            dap.set_breakpoint(vim.fn.input("Condition: "))
        end, { desc = "Conditional breakpoint" })
        map("n", "<leader>dc", function()
            dap.continue()
        end, { desc = "Continue" })
        map("n", "<leader>dn", function()
            dap.step_over()
        end, { desc = "Step over" })
        map("n", "<leader>di", function()
            dap.step_into()
        end, { desc = "Step into" })
        map("n", "<leader>do", function()
            dap.step_out()
        end, { desc = "Step out" })
        map("n", "<leader>dl", function()
            dap.run_last()
        end, { desc = "Run last" })
        map("n", "<leader>dx", function()
            dap.terminate()
        end, { desc = "Terminate" })
        map("n", "<leader>dv", function()
            dapview.toggle()
        end, { desc = "Toggle DAP view" })
    end,
    once = true,
})
