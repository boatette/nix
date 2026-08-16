{
  themeInclude ? null,
}:

{
  main = {
    font = "JetBrainsMono Nerd Font:size=12";
    pad = "14x14";
  }
  // (if themeInclude == null then { } else { include = themeInclude; });

  colors-dark = {
    alpha = 0.8;
    blur = "yes";
  };
}
