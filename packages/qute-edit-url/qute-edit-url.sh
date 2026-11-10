# arguments are passed on to :open, so `-t -r` gives the gO variant
target="{url:pretty}"

# startpage posts its form, so the query isn't always in the url. the startpage-title
# greasemonkey script puts it in the title either way
case "$QUTE_URL" in
  https://www.startpage.com/sp/search* | https://www.startpage.com/do/search*)
    suffix=" - Startpage Search"
    if [[ $QUTE_TITLE == *"$suffix" ]]; then
      target=${QUTE_TITLE%"$suffix"}
    fi
    ;;
esac

printf 'cmd-set-text :open %s\n' "${*:+$* }$target" >>"$QUTE_FIFO"
