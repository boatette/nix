function zellij-clear-all-sessions -d 'kill and delete every zellij session'
    zellij kill-all-sessions
    zellij delete-all-sessions
end
