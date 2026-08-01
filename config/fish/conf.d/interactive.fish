status is-interactive; or exit

set -g fish_greeting ""

set -g fish_key_bindings fish_vi_key_bindings

set -g fish_escape_delay_ms 10

if test -f $HOME/.fish_profile
    source $HOME/.fish_profile
end
