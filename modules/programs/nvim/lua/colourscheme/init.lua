local palettes = require("colourscheme.palette")
local schemes = require("colourscheme.schemes")

local M = {}

local PALETTE = vim.fn.stdpath("config") .. "/noctalia.lua"

local PROVIDERS = {}

local function noctalia_dir(override, xdg_var, xdg_fallback)
    local dir = vim.env[override]
    if dir and dir ~= "" then
        return dir
    end

    local base = vim.env[xdg_var]
    if not base or base == "" then
        base = vim.env.HOME .. xdg_fallback
    end
    return base .. "/noctalia"
end

local function settings_files()
    local config = noctalia_dir("NOCTALIA_CONFIG_HOME", "XDG_CONFIG_HOME", "/.config")
    local state = noctalia_dir("NOCTALIA_STATE_HOME", "XDG_STATE_HOME", "/.local/state")

    local files = vim.fn.glob(config .. "/*.toml", true, true)
    table.insert(files, state .. "/settings.toml")
    return files
end

local function read_theme()
    local theme = {}

    for _, path in ipairs(settings_files()) do
        local file = io.open(path, "r")
        if file then
            local in_section = false
            for line in file:lines() do
                local text = line:match("^%s*(.-)%s*$")
                if text:sub(1, 1) == "[" then
                    in_section = text == "[theme]"
                elseif in_section and text ~= "" and text:sub(1, 1) ~= "#" then
                    local key, value = text:match("^([%w_]+)%s*=%s*(.+)$")
                    if key then
                        theme[key] = value:match('^"(.*)"$') or value
                    end
                end
            end
            file:close()
        end
    end

    return theme
end

local function palette_name(theme)
    if not theme.source or theme.source == "" or theme.source == "builtin" then
        return theme.builtin
    elseif theme.source == "community" then
        return theme.community_palette
    elseif theme.source == "custom" then
        return theme.custom_palette
    end
    return nil
end

local function generated_palette()
    local chunk = loadfile(PALETTE)
    if not chunk then
        return nil
    end

    local ok, palette = pcall(chunk)
    if ok and type(palette) == "table" then
        return palette
    end
    return nil
end

local TRANSPARENT_GROUPS = {
    "Normal",
    "NormalNC",
    "StatusLine",
    "StatusLineNC",
    "SignColumn",
    "LineNr",
    "LineNrAbove",
    "LineNrBelow",
    "NormalFloat",
    "FloatBorder",
    "FloatShadow",
    "WinSeparator",
}

local MUTED_GROUPS = {
    "Delimiter",
    "@punctuation.bracket",
    "@punctuation.delimiter",
}

local function apply_generated(palette, is_light)
    if not palette then
        return false
    end

    palette = palettes.normalise(palette, is_light)

    local ok = pcall(function()
        require("mini.base16").setup({ palette = palette })
    end)

    if ok then
        for _, group in ipairs(TRANSPARENT_GROUPS) do
            vim.api.nvim_set_hl(0, group, { bg = "none" })
        end
        for _, group in ipairs(MUTED_GROUPS) do
            vim.api.nvim_set_hl(0, group, { fg = palette.base04 })
        end
    end

    return ok
end

local function clear_backgrounds()
    for _, group in ipairs(TRANSPARENT_GROUPS) do
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        hl.bg, hl.ctermbg = nil, nil
        pcall(vim.api.nvim_set_hl, 0, group, hl)
    end
end

local function apply_scheme(entry)
    if not (entry and entry.scheme) then
        return false
    end

    local configured = entry.provider and PROVIDERS[entry.provider]

    if entry.provider then
        if not (configured and pcall(configured, entry.opts)) then
            return false
        end
    elseif entry.module then
        pcall(function()
            require(entry.module).setup(entry.opts or {})
        end)
    end

    if not pcall(vim.cmd.colorscheme, entry.scheme) then
        return false
    end

    if not configured then
        clear_backgrounds()
    end

    return true
end

local function is_light_mode(theme, palette)
    if theme.mode == "light" then
        return true
    elseif theme.mode == "dark" then
        return false
    end

    local r, g, b = tostring(palette and palette.base00 or ""):match("^#(%x%x)(%x%x)(%x%x)$")
    if not r then
        return false
    end

    local luma = (0.299 * tonumber(r, 16) + 0.587 * tonumber(g, 16) + 0.114 * tonumber(b, 16)) / 255
    return luma > 0.5
end

function M.apply()
    local theme = read_theme()
    local palette = generated_palette()
    local is_light = is_light_mode(theme, palette)

    vim.o.background = is_light and "light" or "dark"

    if not apply_scheme(schemes.resolve(palette_name(theme), is_light)) then
        apply_generated(palette, is_light)
    end

    vim.api.nvim_exec_autocmds("User", { pattern = "ColourschemeApplied", modeline = false })
end

function M.setup(providers)
    PROVIDERS = providers or {}

    local signal = vim.uv.new_signal()
    if signal then
        signal:start("sigusr1", vim.schedule_wrap(M.apply))
    end

    M.apply()
end

return M
