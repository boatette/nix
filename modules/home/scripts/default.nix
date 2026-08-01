{ pkgs, lib, ... }:
let
    script =
        name: deps:
        pkgs.runCommand name { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
            install -Dm755 ${./${name}} $out/bin/${name}
            wrapProgram $out/bin/${name} --prefix PATH : ${lib.makeBinPath deps}
        '';

    scripts = with pkgs; {
        ssd-backup = script "ssd-backup" [
            rsync
            util-linux
            coreutils
        ];
        ssd-restore = script "ssd-restore" [
            rsync
            util-linux
            coreutils
        ];
    };
in
{
    home.packages = lib.attrValues scripts;

    _module.args.scripts = scripts;
}
