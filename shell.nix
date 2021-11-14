{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  packages = with pkgs; [
    debianutils
    libnotify
    timewarrior
  ];
  shellHook = ''
    export HISTFILE="$PWD/.history"
    export TIMEWARRIORDB="$PWD/.timewarrior"
  '';
}
