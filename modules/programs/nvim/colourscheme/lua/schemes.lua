local M = {}

local DIACRITICS = {}
for base, variants in pairs({
    a = "áàâäãåÁÀÂÄÃÅ",
    c = "çÇ",
    e = "éèêëÉÈÊË",
    i = "íìîïÍÌÎÏ",
    n = "ñÑ",
    o = "óòôöõÓÒÔÖÕ",
    u = "úùûüÚÙÛÜ",
}) do
    for char in variants:gmatch("[\194-\244][\128-\191]*") do
        DIACRITICS[char] = base
    end
end

local function norm(value)
    if not value or value == "" then
        return ""
    end
    for from, to in pairs(DIACRITICS) do
        value = value:gsub(from, to)
    end
    return (value:lower():gsub("[^a-z0-9]", ""))
end

local SCHEMES = {
    catppuccin = { provider = "catppuccin", dark = "catppuccin-macchiato", light = "catppuccin-latte" },
    catppuccinmocha = { provider = "catppuccin", scheme = "catppuccin-mocha" },
    catppuccinmacchiato = { provider = "catppuccin", scheme = "catppuccin-macchiato" },
    catppuccinfrappe = { provider = "catppuccin", scheme = "catppuccin-frappe" },
    catppuccinlatte = { provider = "catppuccin", scheme = "catppuccin-latte" },

    rosepine = { provider = "rose-pine", dark = "rose-pine-main", light = "rose-pine-dawn" },
    rosepinemain = { provider = "rose-pine", scheme = "rose-pine-main" },
    rosepinemoon = { provider = "rose-pine", scheme = "rose-pine-moon" },
    rosepinedawn = { provider = "rose-pine", scheme = "rose-pine-dawn" },

    tokyonight = { provider = "tokyonight", dark = "tokyonight-moon", light = "tokyonight-day" },
    tokyonightnight = { provider = "tokyonight", scheme = "tokyonight-night" },
    tokyonightstorm = { provider = "tokyonight", scheme = "tokyonight-storm" },
    tokyonightmoon = { provider = "tokyonight", scheme = "tokyonight-moon" },
    tokyonightday = { provider = "tokyonight", scheme = "tokyonight-day" },

    everforest = { provider = "everforest", scheme = "everforest" },
    everforestalt = { provider = "everforest", scheme = "everforest" },

    kanagawa = { provider = "kanagawa", dark = "kanagawa-wave", light = "kanagawa-lotus" },
    kanagawawave = { provider = "kanagawa", scheme = "kanagawa-wave" },
    kanagawadragon = { provider = "kanagawa", scheme = "kanagawa-dragon" },
    kanagawalotus = { provider = "kanagawa", scheme = "kanagawa-lotus" },

    nord = { provider = "nord", scheme = "nord" },

    monochrome = {
        provider = "github-monochrome",
        dark = "github-monochrome-zenbones",
        light = "github-monochrome-light",
    },
}

function M.resolve(name, is_light)
    local entry = SCHEMES[norm(name)]
    if not entry then
        return nil
    end
    return {
        provider = entry.provider,
        scheme = entry.scheme or (is_light and entry.light or entry.dark),
        opts = entry.opts,
    }
end

return M
