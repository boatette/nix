function nsh -d 'open a shell with packages from nixpkgs'
    nix shell nixpkgs#$argv
end
