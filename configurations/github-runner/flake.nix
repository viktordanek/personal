{
    inputs =
        {
            nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11" ;
        } ;
    outputs =
        { nixpkgs , self } :
            let
                system = "x86_64-linux" ;
                pkgs = nixpkgs.legacyPackages.${system} ;
                in
                    {
                        nixosConfigurations =
                            {
                                githubRunnerVM =
                                    nixpkgs.lib.nixosSystem
                                        {
                                            modules =
                                                [
                                                    (
                                                        { config , ... } :
                                                            {
                                                                environment.systemPackages =
                                                                    [
                                                                        pkgs.git
                                                                        pkgs.curl
                                                                        pkgs.jq
                                                                        pkgs.github-runner
                                                                    ] ;
                                                                nixpkgs.hostPlatform = "x86_64-linux" ;
                                                                services.github-runners =
                                                                    {
                                                                        github-runner =
                                                                            {
                                                                                enable = true ;
                                                                                ephemeral = true ;
                                                                                extraLabels = [ "nixos" "vm" ] ;
                                                                                name = "github-runner-vm" ;
                                                                                replace = true ;
                                                                                tokenFile = ( builtins.toFile "token" config.personal.user.github-runner.token ) ;
                                                                                url = "https://github.com/viktordanek/temporary" ;
                                                                                user = "github_runner" ;
                                                                            } ;
                                                                    } ;
                                                                users =
                                                                    {
                                                                        groups.github_runner = { } ;
                                                                        users.github_runner =
                                                                            {
                                                                                group = "github_runner" ;
                                                                                isSystemUser = true ;
                                                                                shell = pkgs.zsh ;
                                                                            } ;
                                                                    } ;
                                                            }
                                                    )
                                                ] ;
                                        } ;
                            } ;
                    } ;
}
