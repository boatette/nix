function psg -d 'grep the process list without matching the grep itself'
    ps aux | grep -v grep | grep -i -- $argv
end
