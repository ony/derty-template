{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  packages = with pkgs; [
    debianutils
    libnotify
    timewarrior
    fzf
    python3Packages.markdownify

    (pkgs.python3.withPackages (pp: with pp; [
      isodate
    ]))
  ];
  shellHook = ''
    export HISTFILE="$PWD/.history"
    export TIMEWARRIORDB="$PWD/.timewarrior"
  '';
}
