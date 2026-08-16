{ unwrapped, inputs }:

inputs.wrapper-modules.wrappers.foot.wrap {
  pkgs = unwrapped;
  settings = import ./_settings.nix { };
}
