{ config, inputs, ... }:
{
  flake-file.inputs.nixpkgs.url = "github:NixOS/nixpkgs/${config.flake.constants.nixpkgsBranch}";

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          inputs.self.overlays.default

          # fhs envs bundle all 230M of glibc's locales as a fallback for the host's LOCALE_ARCHIVE;
          # this is the same archive the system builds from i18n.supportedLocales
          (final: prev: {
            buildFHSEnvBubblewrap = prev.buildFHSEnvBubblewrap.override {
              callPackage =
                fn: args:
                final.callPackage fn (
                  args
                  // {
                    pkgs = final // {
                      glibcLocales = prev.glibcLocales.override {
                        allLocales = false;
                        locales = config.flake.constants.locales;
                      };
                    };
                  }
                );
            };
          })
        ];
      };
    };
}
