local augend = require("dial.augend")

local defaults = {
    augend.integer.alias.decimal,
    augend.integer.alias.decimal_int,
    augend.integer.alias.hex,
    augend.date.alias["%Y/%m/%d"],
    augend.constant.alias.en_weekday,
    augend.constant.alias.en_weekday_full,
    augend.constant.new({
        elements = {
            "first",
            "second",
            "third",
            "fourth",
            "fifth",
            "sixth",
            "seventh",
            "eighth",
            "ninth",
            "tenth",
        },
        word = false,
        cyclic = true,
    }),
    augend.constant.new({
        elements = {
            "January",
            "February",
            "March",
            "April",
            "May",
            "June",
            "July",
            "August",
            "September",
            "October",
            "November",
            "December",
        },
        word = true,
        cyclic = true,
    }),
    augend.constant.alias.bool,
    augend.constant.alias.Bool,
    augend.constant.new({ elements = { "&&", "||" }, word = false, cyclic = true }),
}

local let_const = augend.constant.new({ elements = { "let", "const" } })
local and_or = augend.constant.new({ elements = { "and", "or" }, word = true, cyclic = true })
local hex = augend.hexcolor.new({ case = "prefer_lower" })

local function extend(extra)
    return vim.list_extend(vim.list_extend({}, defaults), extra)
end

local config = require("dial.config")

config.augends:register_group({ default = defaults })

config.augends:on_filetype({
    vue = extend({ let_const, hex }),
    typescript = extend({ let_const }),
    css = extend({ hex }),
    markdown = extend({
        augend.constant.new({ elements = { "[ ]", "[x]" }, word = false, cyclic = true }),
        augend.misc.alias.markdown_header,
    }),
    json = extend({ augend.semver.alias.semver }),
    lua = extend({ and_or }),
    python = extend({ and_or }),
})
