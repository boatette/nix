function paths -d 'print PATH one entry per line'
    # named "paths", not "path" -- fish 3.2+ ships a `path` builtin
    printf '%s\n' $PATH
end
