{
  symlinkJoin,
  makeWrapper,
  kdePackages,
}:

symlinkJoin {
  name = "dolphin-themed";
  paths = [ kdePackages.dolphin ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/dolphin --set QT_QPA_PLATFORMTHEME kde
  '';

  meta.mainProgram = "dolphin";
}
