function fish_user_key_bindings -d 'emacs-style rescues on top of vi mode'
    for mode in insert default
        bind -M $mode ctrl-a beginning-of-line
        bind -M $mode ctrl-e end-of-line
        bind -M $mode ctrl-r history-pager
    end

    bind -M insert ctrl-w backward-kill-word
    bind -M insert ctrl-u backward-kill-line
    bind -M insert ctrl-f accept-autosuggestion

    # !! and !$ history expansion
    bind -M insert ! __history_previous_command
    bind -M insert '$' __history_previous_command_arguments
end
