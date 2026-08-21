set -g fish_greeting ""
set -g fish_key_bindings fish_vi_key_bindings
set -g fish_escape_delay_ms 10

if test -f $HOME/.fish_profile
    source $HOME/.fish_profile
end

function history --description "history with timestamps"
    builtin history --show-time='%F %T ' $argv
end

function fish_user_key_bindings --description "emacs-style rescues on top of vi mode"
    for mode in insert default
        bind -M $mode ctrl-a beginning-of-line
        bind -M $mode ctrl-e end-of-line
        bind -M $mode ctrl-r history-pager
    end

    bind -M insert ctrl-w backward-kill-word
    bind -M insert ctrl-u backward-kill-line
    bind -M insert ctrl-f accept-autosuggestion

    bind -M insert ! __history_previous_command
    bind -M insert '$' __history_previous_command_arguments
end

function __history_previous_command --description "expand ! to the previous command"
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function __history_previous_command_arguments --description "expand !\$ to the last argument"
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end
