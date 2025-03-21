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
                    (
                        pkgs.writeShellScriptBin
                            "check"
                            ''LD_LIBRARY_PATH="" nix flake check'' ;
                    )
                ] ;
            shellHook =
                ''

                    ORIG=$( pwd ) &&
                    cd $(mktemp -d ) &&
                        sh ${ builtins.concatStringsSep "" [ "$" "{" "ORIG" "}" ] }/scripts/environment.sh ;
                        unset LD_LIBRARY_PATH &&
                        idea-community .
                '' ;
        }