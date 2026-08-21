{
  flake.modules.niri.niri.settings.animations =
    let
      spring = props: {
        spring = _: {
          props = {
            damping-ratio = 1.0;
            epsilon = 0.0001;
          }
          // props;
        };
      };

      ease = duration-ms: curve: { inherit duration-ms curve; };

      offset = ''
        vec4 offset_window(vec3 coords_geo, vec3 size_geo, float shift_px) {
          vec3 coords = vec3(coords_geo.x, coords_geo.y - shift_px / size_geo.y, 1.0);

          if (coords.x < 0.0 || coords.x > 1.0 || coords.y < 0.0 || coords.y > 1.0)
            return vec4(0.0);

          return texture2D(niri_tex, (niri_geo_to_tex * coords).st);
        }
      '';
    in
    {
      window-open = ease 130 "ease-out-quad" // {
        custom-shader = ''
          ${offset}
          vec4 open_color(vec3 coords_geo, vec3 size_geo) {
            float p = niri_clamped_progress;
            return offset_window(coords_geo, size_geo, (1.0 - p) * 8.0) * p;
          }
        '';
      };

      window-close = ease 100 "ease-out-quad" // {
        custom-shader = ''
          ${offset}
          vec4 close_color(vec3 coords_geo, vec3 size_geo) {
            float p = niri_clamped_progress;
            return offset_window(coords_geo, size_geo, p * 6.0) * (1.0 - p);
          }
        '';
      };

      workspace-switch = spring {
        damping-ratio = 0.9;
        stiffness = 1100;
      };

      horizontal-view-movement = spring { stiffness = 1000; };

      window-movement = spring {
        damping-ratio = 0.85;
        stiffness = 950;
      };

      window-resize = spring { stiffness = 1200; };

      overview-open-close = spring {
        damping-ratio = 0.9;
        stiffness = 1000;
      };

      config-notification-open-close = spring {
        damping-ratio = 0.7;
        stiffness = 1000;
        epsilon = 0.001;
      };

      screenshot-ui-open = ease 150 "ease-out-quad";
    };
}
