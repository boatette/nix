{ lib, ... }:
{
  # a niri window-rule node for settings._children: a match on these properties, then the rule's own
  flake.lib.niriWindowRule = match: props: {
    window-rule._children = [
      { match._props = match; }
    ]
    ++ lib.mapAttrsToList (name: value: { ${name} = value; }) props;
  };
}
