{
  inputs,
  stdenv,
}:

inputs.zen-browser.packages.${stdenv.hostPlatform.system}.default.overrideAttrs (prev: {
  makeWrapperArgs = prev.makeWrapperArgs ++ [
    "--set"
    "MOZ_MARIONETTE"
    "1"
    "--add-flags"
    "-remote-allow-system-access"
  ];
})
