function history -d 'history with timestamps'
    builtin history --show-time='%F %T ' $argv
end
