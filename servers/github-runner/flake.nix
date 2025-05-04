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
                                                    {
                                                        imports = [ <nixos/modules/virtualisation/virtualbox.nix> ] ;
                                                        users.users.github_runner =
                                                            {
                                                                isSystemUser = true ;
                                                                shell = pkgs.zsh ;
                                                            } ;
                                                        environment.systemPackages =
                                                            [
                                                                pkgs.git
                                                                pkgs.curl
                                                                pkgs.jq
                                                                pkgs.github-runner
                                                            ] ;
                                                        systemd.services.github-runner =
                                                            {
                                                                after = [ "network.target" ];
                                                                serviceConfig =
                                                                    {
                                                                        User = "github_runner";
                                                                        ExecStart = "/usr/bin/github-runner";
                                                                        ExecStartPre = "sleep 10"; # Allow some time to initialize if necessary
                                                                    } ;
                                                                wantedBy = [ "multi-user.target" ] ;
                                                            } ;
                                                    }
                                                ] ;
                                            networking =
                                                {
                                                    hostName = "github-runner-vm" ;
                                                    networking.useDHCP = true ;
                                                } ;
                                            logging.enable = true ;
                                            system = system ;
                                        } ;
                            } ;
                    } ;
}
