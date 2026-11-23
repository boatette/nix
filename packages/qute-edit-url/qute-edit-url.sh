# arguments are passed on to :open, so `-t -r` gives the gO variant
target="{url:pretty}"

# a search edits its query, which searxng's query_in_title puts in the title
suffix=" - SearXNG"
if [[ $QUTE_URL == "$SEARXNG"/search* && $QUTE_TITLE == *"$suffix" ]]; then
  target=${QUTE_TITLE%"$suffix"}
fi

printf 'cmd-set-text :open %s\n' "${*:+$* }$target" >>"$QUTE_FIFO"
