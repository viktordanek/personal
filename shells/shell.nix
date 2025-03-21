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
                    ORIG=$( pwd ) &&
                    cd $(mktemp -d ) &&
                        sh ${ builtins.concatStringsSep "" [ "$" "{" "ORIG" "}" ] }/scripts/environment.sh ;
                '' ;
        }