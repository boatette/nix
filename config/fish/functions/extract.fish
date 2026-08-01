function extract -d 'unpack an archive by extension'
    set -l file $argv[1]

    if not test -f "$file"
        echo "'$file' is not a valid file" >&2
        return 1
    end

    switch $file
        case '*.tar.bz2' '*.tbz2'
            tar xjf $file
        case '*.tar.gz' '*.tgz'
            tar xzf $file
        case '*.tar.xz'
            tar xJf $file
        case '*.tar.zst'
            tar --zstd -xf $file
        case '*.tar'
            tar xvf $file
        case '*.bz2'
            bunzip2 $file
        case '*.gz'
            gunzip $file
        case '*.rar'
            unrar x $file
        case '*.zip'
            unzip $file
        case '*.Z'
            uncompress $file
        case '*.7z'
            7z x $file
        case '*'
            echo "'$file' cannot be extracted via extract" >&2
            return 1
    end
end
