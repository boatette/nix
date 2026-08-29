local M = {}

local ACCENTS = { "base08", "base09", "base0A", "base0B", "base0C", "base0D", "base0E", "base0F" }
local ACCENT_CONTRAST = 4.5
local COMMENT_CONTRAST = 3.0

local function decode(hex)
    local r, g, b = tostring(hex):match("^#(%x%x)(%x%x)(%x%x)$")
    if not r then
        return nil
    end
    return { tonumber(r, 16) / 255, tonumber(g, 16) / 255, tonumber(b, 16) / 255 }
end

local function encode(rgb)
    local parts = {}
    for i = 1, 3 do
        parts[i] = math.floor(math.min(math.max(rgb[i], 0), 1) * 255 + 0.5)
    end
    return string.format("#%02x%02x%02x", parts[1], parts[2], parts[3])
end

local function luminance(rgb)
    local weights = { 0.2126, 0.7152, 0.0722 }
    local total = 0
    for i = 1, 3 do
        local c = rgb[i]
        c = c <= 0.03928 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
        total = total + weights[i] * c
    end
    return total
end

local function contrast(a, b)
    local high, low = luminance(a), luminance(b)
    if high < low then
        high, low = low, high
    end
    return (high + 0.05) / (low + 0.05)
end

local function to_hsl(rgb)
    local max, min = math.max(unpack(rgb)), math.min(unpack(rgb))
    local l = (max + min) / 2
    if max == min then
        return 0, 0, l
    end

    local delta = max - min
    local s = l > 0.5 and delta / (2 - max - min) or delta / (max + min)
    local h
    if max == rgb[1] then
        h = (rgb[2] - rgb[3]) / delta + (rgb[2] < rgb[3] and 6 or 0)
    elseif max == rgb[2] then
        h = (rgb[3] - rgb[1]) / delta + 2
    else
        h = (rgb[1] - rgb[2]) / delta + 4
    end
    return h / 6, s, l
end

local function from_hsl(h, s, l)
    if s == 0 then
        return { l, l, l }
    end

    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q

    local function component(t)
        t = (t % 1 + 1) % 1
        if t < 1 / 6 then
            return p + (q - p) * 6 * t
        elseif t < 1 / 2 then
            return q
        elseif t < 2 / 3 then
            return p + (q - p) * (2 / 3 - t) * 6
        end
        return p
    end

    return { component(h + 1 / 3), component(h), component(h - 1 / 3) }
end

local function lift(hex, background, target, is_light)
    local rgb, bg = decode(hex), decode(background)
    if not rgb or not bg or contrast(rgb, bg) >= target then
        return hex
    end

    local h, s, l = to_hsl(rgb)

    local function at(lightness)
        return encode(from_hsl(h, s, lightness))
    end

    local function clears(lightness)
        return contrast(decode(at(lightness)), bg) >= target
    end

    local low, high = l, is_light and 0 or 1

    if not clears(high) then
        return at(high)
    end

    for _ = 1, 24 do
        local mid = (low + high) / 2
        if clears(mid) then
            high = mid
        else
            low = mid
        end
    end

    return at(high)
end

local function order_surfaces(palette)
    local base00, base01, base02 = decode(palette.base00), decode(palette.base01), decode(palette.base02)
    if base00 and base01 and base02 and contrast(base02, base00) < contrast(base01, base00) then
        palette.base01, palette.base02 = palette.base02, palette.base01
    end
end

function M.normalise(palette, is_light)
    if type(palette) ~= "table" or not decode(palette.base00) then
        return palette
    end

    local out = vim.deepcopy(palette)
    for _, slot in ipairs(ACCENTS) do
        out[slot] = lift(out[slot], out.base00, ACCENT_CONTRAST, is_light)
    end
    out.base03 = lift(out.base03, out.base00, COMMENT_CONTRAST, is_light)
    order_surfaces(out)
    return out
end

return M
