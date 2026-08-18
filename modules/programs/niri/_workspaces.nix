{ lib, primary }:

let
  mkWorkspace =
    name:
    if primary == null then
      ''workspace "${name}"''
    else
      ''
        workspace "${name}" {
            open-on-output "${primary}"
        }'';
in
lib.concatMapStringsSep "\n\n" mkWorkspace [
  "misc"
  "browser"
  "term"
]
