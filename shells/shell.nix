{ pkgs ? import <nixpkgs> { } } :
    pkgs.mkShell
        {
            buildInputs =
                [
                    pkgs.coreutils
                    pkgs.firefox
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
                        unset LD_LIBRARY_PATH &&
                        idea-communit .
                '' ;
        }