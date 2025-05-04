{ config, pkgs, lib, ... } :
    {
        networking.hostName = "github-runner-vm" ;
        services.github-runners.my-runner =
            {
                enable = true;
                ephemeral = true;
                tokenFile = "/etc/github-runner-token"; # inject this securely
                url = "https://github.com/YOUR_USER_OR_ORG/YOUR_REPO";
            } ;
        users.users.runner =
            {
                isNormalUser = true ;
                extraGroups = [ "wheel" ] ;
                password = "runner"; # for testing; don't use plaintext in production
            } ;
    }
