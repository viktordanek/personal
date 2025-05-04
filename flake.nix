{
    inputs =
        {
            environment-variable-lib.url = "github:viktordanek/environment-variable" ;
	        flake-utils.url = "github:numtide/flake-utils" ;
	        nixpkgs.url = "github:Nixos/nixpkgs/nixos-22.11" ;
        } ;
    outputs =
        { environment-variable-lib , flake-utils , nixpkgs , self } :
            let
                environment-variable = environment-variable-lib.lib ;
                fun =
                    system :
                        let
                            lib =
                                { config , lib , pkgs , ... } :
                                    {
                                        config =
                                            {
                                                boot.loader =
                                                    {
                                                        efi.canTouchEfiVariables = true ;
                                                        systemd-boot.enable = true ;
                                                    } ;
                                                environment.sessionVariables =
                                                    {
                                                    } ;
                                                hardware.pulseaudio =
                                                    {
                                                        enable = false ;
                                                        support32Bit = true ;
                                                    } ;
                                                i18n =
                                                    {
                                                        defaultLocale = "en_US.UTF-8" ;
                                                        extraLocaleSettings =
                                                            {
                                                                LC_ADDRESS = "en_US.UTF-8" ;
                                                                LC_IDENTIFICATION = "en_US.UTF-8" ;
                                                                LC_MEASUREMENT = "en_US.UTF-8" ;
                                                                LC_MONETARY = "en_US.UTF-8" ;
                                                                LC_NAME = "en_US.UTF-8" ;
                                                                LC_NUMERIC = "en_US.UTF-8" ;
                                                                LC_PAPER = "en_US.UTF-8" ;
                                                                LC_TELEPHONE = "en_US.UTF-8" ;
                                                                LC_TIME = "en_US.UTF-8" ;
                                                            } ;
                                                    } ;
                                                networking.wireless =
                                                    {
                                                        enable = true ;
                                                        networks = config.personal.wifi ;
                                                    } ;
                                                nix =
                                                    {
                                                        nixPath =
                                                            [
                                                                "nixpkgs=https://github.com/NixOS/nixpkgs/archive/b6bbc53029a31f788ffed9ea2d459f0bb0f0fbfc.tar.gz"
                                                                "nixos-config=/etc/nixos/configuration.nix"
                                                                "/nix/var/nix/profiles/per-user/root/channels"
                                                            ] ;
                                                        settings.experimental-features = [ "nix-command" "flakes" ] ;
                                                    } ;
                                                programs =
                                                    {
                                                        bash.interactiveShellInit = "" ;
                                                        dconf.enable = true;
                                                        gnupg.agent.enable = true ;
                                                    } ;
                                                security =
                                                    {
                                                        rtkit.enable = true;
                                                        sudo.extraConfig =
                                                            ''
                                                                %wheel ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/shutdown
                                                                %wheel ALL=(ALL) NOPASSWD: ${ pkgs.umount }/bin/umount
                                                                %wheel ALL=(ALL) NOPASSWD: ${ pkgs.mount }/bin/mount
                                                                %wheel ALL=(ALL) NOPASSWD: ${ pkgs.nixos-rebuild }/bin/nixos-rebuild
                                                                %wheel ALL=(ALL) NOPASSWD: ${ pkgs.unixtools.fsck }/bin/fsck
                                                                %wheel ALL=(ALL) NOPASSWD: ${ pkgs.e2fsprogs }/bin/mkfs.ext4
                                                                %wheel ALL=(ALL) NOPASSWD: ${ pkgs.coreutils }/bin/chown
                                                            '' ;
                                                    } ;
                                                services =
                                                    {
                                                        blueman.enable = true ;
                                                        dbus.packages = [ pkgs.gcr ] ;
                                                        github-runners = { } ;
                                                        openssh =
                                                            {
                                                                enable = true ;
                                                            } ;
                                                        pcscd.enable = true ;
                                                        pipewire =
                                                            {
                                                                alsa =
                                                                    {
                                                                        enable = true ;
                                                                        support32Bit = true ;
                                                                    } ;
                                                                enable = true ;
                                                                pulse.enable = true ;
                                                            };
                                                        printing.enable = true ;
                                                        xserver =
                                                            {
                                                                desktopManager =
                                                                    {
                                                                        xfce.enable = true;
                                                                        xterm.enable = false;
                                                                    }   ;
                                                                displayManager =
                                                                    {
                                                                        defaultSession = "none+i3" ;
                                                                        lightdm.enable = true ;
                                                                    } ;
                                                                enable = true ;
                                                                layout = "us" ;
                                                                libinput =
                                                                    {
                                                                        enable = true ;
                                                                        touchpad =
                                                                            {
                                                                                horizontalScrolling = true ;
                                                                                scrollMethod = "twofinger" ;
                                                                            } ;
                                                                    } ;
                                                                windowManager =
                                                                    {
                                                                        fvwm2.gestures = true ;
                                                                        i3 =
                                                                            {
                                                                                enable = true ;
                                                                                extraPackages =
                                                                                    [
                                                                                        pkgs.dmenu
                                                                                        pkgs.i3status
                                                                                        pkgs.i3lock
                                                                                        pkgs.i3blocks
                                                                                    ] ;
                                                                            } ;
                                                                    } ;
                                                                xkbVariant = "" ;
                                                            } ;
                                                    } ;
                                                system.stateVersion = "23.05" ;
                                                systemd =
                                                    {
                                                        services =
                                                            {
                                                                github-runner =
                                                                    {
                                                                        description = "Github Runner Virtual Machine Service" ;
                                                                        after = [ "network.target" ] ;
                                                                        wantedBy = [ "multi-user.target" ] ;
                                                                        serviceConfig =
                                                                            {
                                                                                ExecStart = "${ pkgs.findutils }/bin/find ${ nixosConfigurations.github-runner.config.system.build.vm }";
                                                                            } ;
                                                                    } ;
                                                            } ;
                                                    } ;
                                                time.timeZone = "America/New_York" ;
                                                users.users.user =
                                                    {
                                                        description = config.personal.user.description ;
                                                        extraGroups = [ "wheel" ] ;
                                                        isNormalUser = true ;
                                                        name = config.personal.user.name ;
                                                        packages =
                                                            [
                                                            ] ;
                                                        password = config.personal.user.password ;
                                                    } ;
                                            } ;
                                        options =
                                            {
                                                personal =
                                                    {
                                                        user =
                                                            {
                                                                description = lib.mkOption { type = lib.types.str ; } ;
                                                                name = lib.mkOption { type = lib.types.str ; } ;
                                                                password = lib.mkOption { type =  lib.types.str ; } ;
                                                                token = lib.mkOption { type = lib.types.str ; } ;
                                                            } ;
                                                        wifi =
                                                            lib.mkOption
                                                                {
                                                                    type =
                                                                        let
                                                                            config =
                                                                                lib.types.submodule
                                                                                {
                                                                                    options =
                                                                                        {
                                                                                            psk = lib.mkOption { type = lib.types.str ; } ;
                                                                                        } ;
                                                                                } ;
                                                                            in lib.types.attrsOf config ;
                                                                } ;
                                                     } ;
                                            } ;
                                } ;
                            nixosConfigurations =
                                {
                                    github-runner =
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
                                                                                    tokenFile = ( builtins.toFile "token" config.personal.user.token ) ;
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
                    pkgs = import nixpkgs { inherit system; } ;
                    in
                        {
                            lib = lib ;
                        } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
