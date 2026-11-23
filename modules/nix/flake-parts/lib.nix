{ inputs, lib, ... }:
{
  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    description = "Helper functions shared across the flake";
  };

  config.flake.lib = rec {
    # an input on an older glibc than the system's can't load the system's mesa
    glibcAssertion = pkgs: name: {
      assertion =
        lib.versionAtLeast
          inputs.${name}.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.glibc.version
          pkgs.glibc.version;
      message = "${name}'s nixpkgs has an older glibc than the system's; wait for its cachix branch to catch up";
    };

    qtFont = font: "${font.name},${toString font.size},-1,5,50,0,0,0,0,0";

    # what nvidia-offload sets to run a program on the nvidia gpu
    nvidiaOffloadEnv = {
      __NV_PRIME_RENDER_OFFLOAD = "1";
      __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      __VK_LAYER_NV_optimus = "NVIDIA_only";
    };

    nvidiaOffloadWrap =
      pkgs: pkg: bin:
      pkgs.symlinkJoin {
        inherit (pkg)
          name
          pname
          version
          meta
          ;
        paths = [ pkg ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/${bin} ${
            lib.concatStringsSep " " (
              lib.mapAttrsToList (name: value: "--set ${name} ${value}") nvidiaOffloadEnv
            )
          }
        '';
      };
  };
}
