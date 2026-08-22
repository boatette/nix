{
  flake.modules.nixvim.nvim =
    { lib, ... }:
    let
      mkFiles =
        dir: prefix:
        if builtins.pathExists dir then
          lib.mapAttrs' (name: _: lib.nameValuePair "${prefix}/${name}" { source = dir + "/${name}"; }) (
            lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".lua" name) (builtins.readDir dir)
          )
        else
          { };
    in
    {
      extraFiles =
        lib.optionalAttrs (builtins.pathExists ./omarchy/schemes.lua) {
          "lua/colourscheme/omarchy.lua".source = ./omarchy/schemes.lua;
        }
        // mkFiles ./omarchy/colors "colors"
        // mkFiles ./omarchy/specs "lua/omarchy";
    };
}
