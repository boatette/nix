{
  flake.modules.nixos.console =
    { pkgs, ... }:
    {
      console = {
        earlySetup = true;

        packages = [ pkgs.terminus_font ];
        font = "ter-v24b";

        # Rosé Pine main
        colors = [
          "191724"
          "eb6f92"
          "31748f"
          "f6c177"
          "9ccfd8"
          "c4a7e7"
          "ebbcba"
          "e0def4"
          "6e6a86"
          "eb6f92"
          "31748f"
          "f6c177"
          "9ccfd8"
          "c4a7e7"
          "ebbcba"
          "e0def4"
        ];
      };
    };
}
