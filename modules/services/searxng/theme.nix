{ inputs, ... }:
{
  # searxng has no rosé pine port, so the simple theme's dark colours come from the palette
  flake.modules.nixos.aspire =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.services.searx) package;
      inherit (inputs.self.lib.colours) alpha hex rgb;

      shadow = "0 2px 8px ${alpha "base" 0.25}";

      colours = {
        base-font = hex "text";
        base-font-rgb = rgb "text";
        base-background = hex "base";
        base-background-mobile = hex "base";
        url-font = hex "foam";
        url-visited-font = hex "iris";
        header-background = hex "surface";
        header-border = hex "overlay";
        footer-background = hex "surface";
        footer-border = hex "overlay";
        sidebar-border = hex "muted";
        sidebar-font = hex "text";
        sidebar-background = hex "surface";
        backtotop-font = hex "text";
        backtotop-border = hex "overlay";
        backtotop-background = hex "overlay";
        btn-background = hex "primary";
        btn-font = hex "base";
        show-btn-background = hex "overlay";
        show-btn-font = hex "text";
        search-border = hex "overlay";
        search-shadow = shadow;
        search-background = hex "surface";
        search-font = hex "text";
        search-background-hover = hex "primary";
        error = hex "error";
        error-background = alpha "error" 0.15;
        warning = hex "warning";
        warning-background = alpha "warning" 0.15;
        success = hex "secondary";
        success-background = alpha "secondary" 0.15;
        categories-item-selected-font = hex "primary";
        categories-item-border-selected = hex "primary";
        autocomplete-font = hex "text";
        autocomplete-border = hex "overlay";
        autocomplete-shadow = shadow;
        autocomplete-background = hex "surface";
        autocomplete-background-hover = hex "overlay";
        answer-font = hex "text";
        answer-background = hex "surface";
        result-keyvalue-col-table = hex "surface";
        result-keyvalue-odd = hex "surface";
        result-keyvalue-even = hex "overlay";
        result-background = hex "surface";
        result-border = hex "overlay";
        result-url-font = hex "subtle";
        result-vim-selected = alpha "overlay" 0.8;
        result-vim-arrow = hex "primary";
        result-description-highlight-font = hex "primary";
        result-link-font = hex "foam";
        result-link-font-highlight = hex "foam";
        result-link-visited-font = hex "iris";
        result-publishdate-font = hex "muted";
        result-engines-font = hex "muted";
        result-search-url-border = hex "overlay";
        result-search-url-font = hex "text";
        result-detail-font = hex "text";
        result-detail-label-font = hex "subtle";
        result-detail-background = hex "base";
        result-detail-hr = hex "overlay";
        result-detail-link = hex "foam";
        result-detail-loader-border = alpha "text" 0.2;
        result-image-span-font = hex "text";
        result-image-span-font-selected = hex "base";
        result-image-background = hex "surface";
        settings-tr-hover = hex "overlay";
        settings-engine-description-font = hex "subtle";
        settings-table-group-background = hex "surface";
        toolkit-badge-font = hex "text";
        toolkit-badge-background = hex "overlay";
        toolkit-kbd-font = hex "base";
        toolkit-kbd-background = hex "text";
        toolkit-dialog-border = hex "overlay";
        toolkit-dialog-background = hex "surface";
        toolkit-tabs-label-border = hex "base";
        toolkit-tabs-section-border = hex "overlay";
        toolkit-select-background = hex "overlay";
        toolkit-select-border = hex "muted";
        toolkit-select-background-hover = hex "muted";
        toolkit-input-text-font = hex "text";
        toolkit-checkbox-onoff-off-background = hex "overlay";
        toolkit-checkbox-onoff-on-background = hex "overlay";
        toolkit-checkbox-onoff-on-mark-background = hex "primary";
        toolkit-checkbox-onoff-on-mark-color = hex "base";
        toolkit-checkbox-onoff-off-mark-background = hex "muted";
        toolkit-checkbox-onoff-off-mark-color = hex "base";
        toolkit-checkbox-label-background = hex "base";
        toolkit-checkbox-label-border = hex "overlay";
        toolkit-checkbox-input-border = hex "primary";
        toolkit-engine-tooltip-border = hex "overlay";
        toolkit-engine-tooltip-background = hex "surface";
        toolkit-loader-border = alpha "text" 0.2;
        doc-code = hex "text";
        doc-code-background = hex "overlay";
      };

      # the search page's wordmark is inlined from the templates, and css outranks its colour attributes
      css = ":root.theme-dark{${
        lib.concatStrings (lib.mapAttrsToList (name: value: "--color-${name}:${value};") colours)
      }}[fill=\"#3050ff\"]{fill:${hex "primary"}}[stroke=\"#3050ff\"]{stroke:${hex "primary"}}";

      # appended to the shipped stylesheets so the later, equally specific rule wins
      static =
        pkgs.runCommand "searxng-static-rose-pine"
          {
            inherit css;
            nativeBuildInputs = [ pkgs.librsvg ];
          }
          ''
            cp -r ${package}/${package.pythonModule.sitePackages}/searx/static $out
            chmod -R u+w $out
            for sheet in $out/themes/simple/sxng-{ltr,rtl}.min.css; do
              printf '%s\n' "$css" >> "$sheet"
            done

            # the logos and icons have their blue written into the svg, and the pngs are rendered from them
            img=$out/themes/simple/img
            sed -i -e 's/#487cff/${hex "primary"}/g' -e 's/#3050ff/${hex "primary"}/g' $img/searxng.svg $img/favicon.svg
            sed -i 's/#58f/${hex "muted"}/g' $img/empty_favicon.svg
            rsvg-convert -w 640 $img/searxng.svg -o $img/searxng.png
            rsvg-convert -w 261 $img/favicon.svg -o $img/favicon.png
            for size in 192 512; do
              rsvg-convert -w $size $img/favicon.svg -o $img/$size.png
            done
          '';
    in
    {
      services.searx.settings = {
        ui = {
          static_path = "${static}";
          theme_args.simple_style = "dark";
        };

        # the palette only covers the dark style
        preferences.lock = [
          "theme"
          "simple_style"
        ];
      };
    };
}
