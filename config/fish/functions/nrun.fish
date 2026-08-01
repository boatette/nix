function nrun -d 'run a package from nixpkgs without installing'
    nix run nixpkgs#$argv[1] -- $argv[2..]
end
