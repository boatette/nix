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

local function extend(extra)
    return vim.list_extend(vim.list_extend({}, defaults), extra)
end

local function letConst()
    return augend.constant.new({ elements = { "let", "const" } })
end

local function andOr()
    return augend.constant.new({ elements = { "and", "or" }, word = true, cyclic = true })
end

local function hexcolors()
    return {
        augend.hexcolor.new({ case = "lower" }),
        augend.hexcolor.new({ case = "upper" }),
    }
end

require("dial.config").augends:register_group({ default = defaults })

require("dial.config").augends:on_filetype({
    vue = extend(vim.list_extend({ letConst() }, hexcolors())),
    typescript = extend({ letConst() }),
    css = extend(hexcolors()),
    markdown = extend({
        augend.constant.new({ elements = { "[ ]", "[x]" }, word = false, cyclic = true }),
        augend.misc.alias.markdown_header,
    }),
    json = extend({ augend.semver.alias.semver }),
    lua = extend({ andOr() }),
    python = extend({ andOr() }),
})
