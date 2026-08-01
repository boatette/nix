function serve -d 'serve the current dir over http, default port 8000'
    set -l port 8000
    test (count $argv) -gt 0; and set port $argv[1]
    python3 -m http.server $port
end
