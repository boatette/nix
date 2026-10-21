{
  inputs,
  lib,
  withSystem,
  ...
}:
{
  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    description = "Helper functions shared across the flake";
  };

  config.flake.lib = {
    qtFont = font: "${font.name},${toString font.size},-1,5,50,0,0,0,0,0";

    # runs a program on the nvidia gpu under prime offload, like nvidia-offload
    nvidiaOffloadEnv = {
      __NV_PRIME_RENDER_OFFLOAD = "1";
      __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      __VK_LAYER_NV_optimus = "NVIDIA_only";
    };

    fromINI =
      text:
      let
        lines = lib.filter (line: line != "" && !lib.hasPrefix "#" line) (
          map lib.trim (lib.splitString "\n" text)
        );

        step =
          acc: line:
          let
            section = builtins.match "\\[(.*)]" line;
            pair = builtins.match "([^=]+)=(.*)" line;
          in
          if section != null then
            acc // { current = lib.head section; }
          else if pair != null then
            lib.recursiveUpdate acc {
              sections.${acc.current}.${lib.trim (lib.elemAt pair 0)} = lib.trim (lib.elemAt pair 1);
            }
          else
            acc;
      in
      (lib.foldl' step {
        current = "";
        sections = { };
      } lines).sections;

    mkNixos = system: name: {
      ${name} = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.self.modules.nixos.${name}
          {
            nixpkgs = {
              hostPlatform = lib.mkDefault system;
              pkgs = withSystem system ({ pkgs, ... }: pkgs);
            };
          }
        ];
      };
    };
  };
}
