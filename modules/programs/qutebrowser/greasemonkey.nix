{
  flake.modules.homeManager.qutebrowser =
    { pkgs, ... }:
    {
      programs.qutebrowser.greasemonkey = [
        (pkgs.writeText "startpage-title.js" ''
          // ==UserScript==
          // @name        startpage-title
          // @namespace   qutebrowser
          // @match       https://www.startpage.com/sp/search*
          // @match       https://www.startpage.com/do/search*
          // @run-at      document-end
          // ==/UserScript==

          // title startpage tabs by their query, like google does
          (function () {
              "use strict";

              const input = document.querySelector("input[name='query']");
              const query =
                  new URLSearchParams(location.search).get("query") ||
                  (input && input.value);

              if (query) {
                  document.title = query + " - Startpage Search";
              }
          })();
        '')
      ];
    };
}
