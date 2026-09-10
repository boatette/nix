{
  flake.lib.nvim =
    let
      base = mode: key: desc: {
        inherit mode key desc;
        silent = false;
      };

      cmd =
        mode: key: action: desc:
        base mode key desc // { inherit action; };

      lua =
        mode: key: action: desc:
        base mode key desc
        // {
          inherit action;
          lua = true;
        };

      mod =
        mode: key: module: expr: desc:
        lua mode key /* lua */ ''
          function()
              require("${module}").${expr}
          end
        '' desc;
    in
    {
      inherit cmd lua mod;
    };
}
