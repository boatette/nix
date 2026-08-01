function backup -d 'copy <file> to <file>.bak'
    cp -- $argv[1] $argv[1].bak
end
