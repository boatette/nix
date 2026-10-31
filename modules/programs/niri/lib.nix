{
  flake.lib.niriWindowRule = match: props: {
    window-rule = props // {
      match._props = match;
    };
  };
}
