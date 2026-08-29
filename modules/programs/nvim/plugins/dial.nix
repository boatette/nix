{
  flake.modules.nixvim.core =
    { lib, ... }:
    let
      inherit (lib.nixvim) mkRaw;

      dialMap = mode: fn: desc: {
        inherit mode;
        key = if fn == "inc" then "<C-a>" else "<C-x>";
        action = mkRaw ''
          function()
              return require("dial.map").${fn}_${if mode == "n" then "normal" else "visual"}()
          end
        '';
        options = {
          expr = true;
          inherit desc;
        };
      };
    in
    {
      plugins.dial = {
        enable = true;
        luaConfig.content = ''
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

          require("dial.config").augends:register_group({ default = defaults })

          require("dial.config").augends:on_filetype({
            vue = vim.list_extend(vim.list_extend({}, defaults), {
              augend.constant.new({ elements = { "let", "const" } }),
              augend.hexcolor.new({ case = "lower" }),
              augend.hexcolor.new({ case = "upper" }),
            }),
            typescript = vim.list_extend(vim.list_extend({}, defaults), {
              augend.constant.new({ elements = { "let", "const" } }),
            }),
            css = vim.list_extend(vim.list_extend({}, defaults), {
              augend.hexcolor.new({ case = "lower" }),
              augend.hexcolor.new({ case = "upper" }),
            }),
            markdown = vim.list_extend(vim.list_extend({}, defaults), {
              augend.constant.new({ elements = { "[ ]", "[x]" }, word = false, cyclic = true }),
              augend.misc.alias.markdown_header,
            }),
            json = vim.list_extend(vim.list_extend({}, defaults), {
              augend.semver.alias.semver,
            }),
            lua = vim.list_extend(vim.list_extend({}, defaults), {
              augend.constant.new({ elements = { "and", "or" }, word = true, cyclic = true }),
            }),
            python = vim.list_extend(vim.list_extend({}, defaults), {
              augend.constant.new({ elements = { "and", "or" }, word = true, cyclic = true }),
            }),
          })
        '';
      };

      keymaps = [
        (dialMap "n" "inc" "Increment")
        (dialMap "n" "dec" "Decrement")
        (dialMap "v" "inc" "Increment")
        (dialMap "v" "dec" "Decrement")
      ];
    };
}
