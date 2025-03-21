{ pkgs ? import <nixpkgs> { } } :
    pkgs.mkShell
        {
            buildInputs =
                [
                    pkgs.coreutils
                    pkgs.git
                    pkgs.jetbrains.idea-community
                    pkgs.jq
                    pkgs.yq
                ] ;
            shellHook =
                ''
                    cd $(mktemp -d ) &&
                        ../scripts/environment.sh ;
                '' ;
        }