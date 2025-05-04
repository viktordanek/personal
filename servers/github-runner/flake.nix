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
                                                                systemd.services.github-runner =
                                                                    {
                                                                        after = [ "network.target" ];
                                                                        serviceConfig =
                                                                            {
                                                                                User = "github_runner";
                                                                                ExecStart = "/usr/bin/github-runner";
                                                                            } ;
                                                                        wantedBy = [ "multi-user.target" ] ;
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
