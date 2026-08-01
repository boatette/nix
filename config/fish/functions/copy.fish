function copy -d 'cp, recursing automatically when the source is a directory'
    if test (count $argv) -eq 2; and test -d $argv[1]
        command cp -r (string trim -r -c '/' $argv[1]) $argv[2]
    else
        command cp $argv
    end
end
