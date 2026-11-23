{
  # no rose pine port exists, so the simple theme's dark colours are overridden from the palette
  flake.modules.nixos.aspire =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.constants) palette;
      inherit (config.services.searx) package;

      c = name: "#${palette.${name}}";
      rgb =
        name:
        lib.concatMapStringsSep ", "
          (i: toString (lib.fromHexString (builtins.substring i 2 palette.${name})))
          [
            0
            2
            4
          ];
      shadow = "0 2px 8px ${c "base"}40";

      colours = {
        base-font = c "text";
        base-font-rgb = rgb "text";
        base-background = c "base";
        base-background-mobile = c "base";
        url-font = c "foam";
        url-visited-font = c "iris";
        header-background = c "surface";
        header-border = c "overlay";
        footer-background = c "surface";
        footer-border = c "overlay";
        sidebar-border = c "muted";
        sidebar-font = c "text";
        sidebar-background = c "surface";
        backtotop-font = c "text";
        backtotop-border = c "overlay";
        backtotop-background = c "overlay";
        btn-background = c "rose";
        btn-font = c "base";
        show-btn-background = c "overlay";
        show-btn-font = c "text";
        search-border = c "overlay";
        search-shadow = shadow;
        search-background = c "surface";
        search-font = c "text";
        search-background-hover = c "rose";
        error = c "love";
        error-background = "${c "love"}25";
        warning = c "gold";
        warning-background = "${c "gold"}25";
        success = c "foam";
        success-background = "${c "foam"}25";
        categories-item-selected-font = c "rose";
        categories-item-border-selected = c "rose";
        autocomplete-font = c "text";
        autocomplete-border = c "overlay";
        autocomplete-shadow = shadow;
        autocomplete-background = c "surface";
        autocomplete-background-hover = c "overlay";
        answer-font = c "text";
        answer-background = c "surface";
        result-keyvalue-col-table = c "surface";
        result-keyvalue-odd = c "surface";
        result-keyvalue-even = c "overlay";
        result-background = c "surface";
        result-border = c "overlay";
        result-url-font = c "subtle";
        result-vim-selected = "${c "overlay"}cc";
        result-vim-arrow = c "rose";
        result-description-highlight-font = c "rose";
        result-link-font = c "foam";
        result-link-font-highlight = c "foam";
        result-link-visited-font = c "iris";
        result-publishdate-font = c "muted";
        result-engines-font = c "muted";
        result-search-url-border = c "overlay";
        result-search-url-font = c "text";
        result-detail-font = c "text";
        result-detail-label-font = c "subtle";
        result-detail-background = c "base";
        result-detail-hr = c "overlay";
        result-detail-link = c "foam";
        result-detail-loader-border = "${c "text"}33";
        result-image-span-font = c "text";
        result-image-span-font-selected = c "base";
        result-image-background = c "surface";
        settings-tr-hover = c "overlay";
        settings-engine-description-font = c "subtle";
        settings-table-group-background = c "surface";
        toolkit-badge-font = c "text";
        toolkit-badge-background = c "overlay";
        toolkit-kbd-font = c "base";
        toolkit-kbd-background = c "text";
        toolkit-dialog-border = c "overlay";
        toolkit-dialog-background = c "surface";
        toolkit-tabs-label-border = c "base";
        toolkit-tabs-section-border = c "overlay";
        toolkit-select-background = c "overlay";
        toolkit-select-border = c "muted";
        toolkit-select-background-hover = c "muted";
        toolkit-input-text-font = c "text";
        toolkit-checkbox-onoff-off-background = c "overlay";
        toolkit-checkbox-onoff-on-background = c "overlay";
        toolkit-checkbox-onoff-on-mark-background = c "rose";
        toolkit-checkbox-onoff-on-mark-color = c "base";
        toolkit-checkbox-onoff-off-mark-background = c "muted";
        toolkit-checkbox-onoff-off-mark-color = c "base";
        toolkit-checkbox-label-background = c "base";
        toolkit-checkbox-label-border = c "overlay";
        toolkit-checkbox-input-border = c "rose";
        toolkit-engine-tooltip-border = c "overlay";
        toolkit-engine-tooltip-background = c "surface";
        toolkit-loader-border = "${c "text"}33";
        doc-code = c "text";
        doc-code-background = c "overlay";
      };

      # the search page's wordmark is inlined from the templates, and css outranks its colour attributes
      css = ":root.theme-dark{${
        lib.concatStrings (lib.mapAttrsToList (name: value: "--color-${name}:${value};") colours)
      }}[fill=\"#3050ff\"]{fill:${c "rose"}}[stroke=\"#3050ff\"]{stroke:${c "rose"}}";

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
            sed -i -e 's/#487cff/${c "rose"}/g' -e 's/#3050ff/${c "rose"}/g' $img/searxng.svg $img/favicon.svg
            sed -i 's/#58f/${c "muted"}/g' $img/empty_favicon.svg
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
