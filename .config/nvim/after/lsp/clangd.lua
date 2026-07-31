return {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=never",
        "--all-scopes-completion",
        "--completion-style=detailed",
        "--function-arg-placeholders=false",
        "--fallback-style=llvm",
    },
    root_markers = {
        ".clangd",
        ".clang-tidy",
        ".clang-format",
        "compile_commands.json",
        "compile_flags.txt",
        "configure.ac",
        ".git",
        "CMakeLists.txt",
        "Makefile",
    },
    on_init = function(client)
        client.server_capabilities.offsetEncoding = "utf-8"
    end,
    settings = {
        clangd = {
            InlayHints = {
                Designators = true,
                Enabled = true,
                ParameterNames = true,
                DeducedTypes = true,
            },
        },
    },
}
