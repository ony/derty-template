{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  packages = with pkgs; [
    debianutils
    libnotify
  ];
  shellHook = ''
    export HISTFILE="$PWD/.history"
  '';
}
