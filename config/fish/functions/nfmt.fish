function nfmt -d 'nixfmt every nix file in the flake'
    # --indent 4 matches the repo style; conform.nvim passes the same.
    # nix.bak is a separate checkout and is not ours to reformat.
    nixfmt --indent 4 (fd -e nix . ~/nix --exclude nix.bak)
end
