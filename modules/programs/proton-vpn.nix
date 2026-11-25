{
  flake.modules.homeManager.boatette =
    { pkgs, ... }:
    {
      # the noctaproton-vpn bar widget drives this cli
      home.packages = [
        # without its daemon, which is only for split tunnelling and pulls in 260M of bcc and llvm;
        # nixpkgs never starts it, so the cli already finds no split tunnelling backend
        (pkgs.proton-vpn-cli.overridePythonAttrs (old: {
          dependencies = builtins.filter (dep: dep.pname or "" != "proton-vpn-daemon") old.dependencies;
        }))
      ];
    };
}
