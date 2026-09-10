local M = {}

function M.on_init(client)
    if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if
            path ~= vim.fn.stdpath("config")
            and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
        then
            return
        end
    end

    local settings = client.config.settings or {}

    settings.Lua = vim.tbl_deep_extend("force", settings.Lua or {}, {
        runtime = {
            version = "LuaJIT",
            path = { "lua/?.lua", "lua/?/init.lua" },
        },
        workspace = {
            checkThirdParty = false,
            library = { vim.env.VIMRUNTIME },
        },
    })

    client.config.settings = settings
    client:notify("workspace/didChangeConfiguration", { settings = settings })
end

return M
