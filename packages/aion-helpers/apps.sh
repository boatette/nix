# usage: aion-apps [launch PATH]; lists desktop entries as "Name<TAB>path" or launches one
if [[ ${1:-} == launch ]]; then
  exec gio launch "$2"
fi

IFS=: read -ra dirs <<<"${XDG_DATA_HOME:-$HOME/.local/share}:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
# shellcheck disable=SC2016 # the single-quoted $s belong to awk
for dir in "${dirs[@]}"; do
  if [[ -d $dir/applications ]]; then
    find -L "$dir/applications" -name '*.desktop' -printf '%P\t%p\n'
  fi
done |
  # the desktop file ID is the path under applications/ with / as -, and the earlier data dir wins
  awk -F '\t' '{ id = $1; gsub("/", "-", id) } !seen[id]++ { print $2 }' |
  xargs -r -d '\n' awk '
		BEGINFILE { name = ""; skip = 0; entry = 0 }
		/^\[/ { entry = $0 == "[Desktop Entry]"; next }
		!entry { next }
		/^Name=/ && name == "" { name = substr($0, 6) }
		/^(NoDisplay|Hidden)=true/ || (/^Type=/ && $0 != "Type=Application") { skip = 1 }
		ENDFILE { if (name != "" && !skip) print name "\t" FILENAME }
	' |
  sort -f -u -t "$(printf '\t')" -k1,1
