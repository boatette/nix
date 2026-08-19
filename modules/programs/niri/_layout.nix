{
  gaps = 8;

  always-center-single-column = _: { };
  background-color = "transparent";

  focus-ring = {
    on = _: { };
    width = 2;
  };

  default-column-width.proportion = 0.5;

  preset-column-widths = [
    { proportion = 0.33333; }
    { proportion = 0.5; }
    { proportion = 0.66667; }
  ];

  border = {
    off = _: { };
    width = 2;
  };

  shadow = {
    off = _: { };
    offset = _: {
      props = {
        x = 0;
        y = 0;
      };
    };
  };

  struts = {
    left = 42;
    right = 42;
    top = 0;
    bottom = 0;
  };

  tab-indicator = {
    corner-radius = 4;
    gaps-between-tabs = 8;
  };
}
