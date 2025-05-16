{
    inputs =
        {
            cat.url = "github:viktordanek/cat/240f951b90cb669c399c0a82ea9537a4ee8e9559" ;
	        stash-factory.url = "github:viktordanek/stash-factory/868a78d66a003790bdbdfab36b3ac4bd32149067" ;
	        visitor.url = "github:viktordanek/visitor" ;
        } ;
    outputs =
        { cat , self , stash-factory , visitor } :
            {
                lib =
                    {
                        description ,
                        dot-ssh ? null ,
                        hash-length ? 16 ,
                        identity ? null ,
                        known-hosts ? null ,
                        name ,
                        nixpkgs ,
                        password ,
                        stash ? "stash" ,
                        system
                    } :
                        let
                            primary =
                                let
                                    cat-lambda =
                                        target : path : value :
                                            stash-factory.lib.${ system }.generator
                                                {
                                                    factory-name = target ;
                                                    hash-length = primary.hash-length ;
                                                    generator = cat.lib.generator ;
                                                    generator-name = target ;
                                                    generation-parameters =
                                                        builtins.trace "generation-parameters"
                                                        {
                                                            mapping = { "${ target }" = builtins.toString value ; } ;
                                                            nixpkgs = nixpkgs ;
                                                            system = system ;
                                                        } ;
                                                    path = builtins.trace "path" [ "cat" target path value ] ;
                                                    stash-directory = stash-directory ;
                                                    targets = builtins.trace "target" [ target ] ;
                                                    time-mask = primary.config.personal.time-mask ;
                                                } ;
                                    in
                                        {
                                            description =
                                                visitor.lib.${ system }
                                                    {
                                                        string = path : value : value ;
                                                    }
                                                    description ;
                                            hash-length =
                                                visitor.lib.${ system }
                                                    {
                                                        int = path : value : value ;
                                                    }
                                                    hash-length ;
                                            identity =
                                                visitor.lib.${ system }
                                                    ( builtins.trace "identity ARG 1"
                                                    {
                                                        path = builtins.trace "ARG 1.1" ( path : value : builtins.trace "cat-lambda 1" ( cat-lambda "identity" path value ) ) ;
                                                        string = builtins.trace "ARG 1.2" ( path : value : builtins.trace "cat-lambda 2" ( cat-lambda "identity" path value ) ) ;
                                                    } )
                                                    ( builtins.trace "identity ARG 2"
                                                    identity ) ;
                                            known-hosts =
                                                visitor.lib.${ system }
                                                    {
                                                        path = path : value : cat-lambda "known-hosts" path value ;
                                                        string = path : value : cat-lambda "known-hosts" path value ;
                                                    } ;
                                            name =
                                                visitor.lib.${ system }
                                                    {
                                                        string = path : value : value ;
                                                    }
                                                    name ;
                                            password =
                                                visitor.lib.${ system }
                                                    {
                                                        string = path : value : value ;
                                                    }
                                                    password ;
                                            stash =
                                                visitor.lib.${ system }
                                                    {
                                                        string = path : value : value ;
                                                    }
                                                    stash ;
                                        } ;
                                    stash-directory = "/home/${ primary.name }/${ primary.stash }" ;
                            in
                                { config , lib , pkgs , ... } :
                                    {
                                        config =
                                            {
                                                boot.loader =
                                                    {
                                                        efi.canTouchEfiVariables = true ;
                                                        systemd-boot.enable = true ;
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
                                                                %wheel ALL=(ALL) NOPASSWD: ${ pkgs.nixos-rebuild }/bin/nixos-rebuild
                                                            '' ;
                                                    } ;
                                                services =
                                                    {
                                                        blueman.enable = true ;
                                                        dbus.packages = [ pkgs.gcr ] ;
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
                                                systemd =
                                                    {
                                                        services =
                                                            {
                                                                clean-stash =
                                                                    {
                                                                        after = [ "network-online.target" ] ;
                                                                        serviceConfig =
                                                                            {
                                                                                ExecStart =
                                                                                    let
                                                                                        application =
                                                                                            pkgs.writeShellApplication
                                                                                                {
                                                                                                    name = "ExecStart" ;
                                                                                                    runtimeInputs = [ pkgs.coreutils pkgs.findutils ] ;
                                                                                                    text =
                                                                                                        ''
                                                                                                            set -euo pipefail
                                                                                                            find ${ stash-directory } -mindepth 1 -maxdepth 1 -type d | while read -r DIRECTORY
                                                                                                            do
                                                                                                                if ( ! find "$DIRECTORY" -atype -31 -quit ) && ( ! find "$DIRECTORY" -ctype -31 -quit ) && ( ! find "$DIRECTORY" -mtype -31 -quit )
                                                                                                                then
                                                                                                                    rm --recursive --force "$DIRECTORY"
                                                                                                                fi
                                                                                                            done
                                                                                                        '' ;
                                                                                                } ;
                                                                                        in "${ application }/bin/ExecStart" ;
                                                                                Type = "oneshot" ;
                                                                                User = primary.name ;
                                                                            } ;
                                                                        wants = [ "network-online.target" ] ;
                                                                    } ;
                                                                trashy =
                                                                    {
                                                                        after = [ "network.target" ] ;
                                                                        serviceConfig =
                                                                            {
                                                                                ExecStart =
                                                                                    let
                                                                                        application =
                                                                                            pkgs.writeShellApplication
                                                                                                {
                                                                                                    name = "ExecStart" ;
                                                                                                    runtimeInputs = [ pkgs.trashy ] ;
                                                                                                    text =
                                                                                                        ''
                                                                                                            trashy remove
                                                                                                        '' ;
                                                                                                } ;
                                                                                                in "${ application }/bin/ExecStart" ;
                                                                                User = primary.name ;
                                                                            } ;
                                                                        wantedBy = [ "multi-user.target" ] ;
                                                                    } ;
                                                            } ;
                                                        timers =
                                                            {
                                                                clean-stash =
                                                                    {
                                                                        timerConfig =
                                                                            {
                                                                                OnBootSec = "5min" ;
                                                                                OnCalendar = "daily" ;
                                                                                Persistent = true ;
                                                                            } ;
                                                                        wantedBy = [ "timers.target" ] ;
                                                                    } ;
                                                                trashy =
                                                                    {
                                                                        timerConfig =
                                                                            {
                                                                                OnBootSec = "5min" ;
                                                                                OnCalendar = "weekly" ;
                                                                                Persistent = true ;
                                                                            } ;
                                                                    } ;
                                                            } ;
                                                    } ;
                                                system.stateVersion = "23.05" ;
                                                time.timeZone = "America/New_York" ;
                                                users.users.user =
                                                    {
                                                        description = primary.description ;
                                                        extraGroups = [ "wheel" ] ;
                                                        isNormalUser = true ;
                                                        name = primary.name ;
                                                        packages =
                                                            [
                                                                (
                                                                    pkgs.writeShellScriptBin
                                                                        "test-it"
                                                                        ''
                                                                            echo ${ let x = builtins.toJSON ( builtins.attrNames primary.identity ) ; in builtins.trace "BEFORE" x }
                                                                            echo ${ let x = builtins.typeOf primary.identity.boot ; in builtins.trace x x }
                                                                            echo ${ let x = builtins.toJSON ( builtins.attrNames primary.identity ) ; in builtins.trace "AFTER" x }

                                                                        ''
                                                                )
                                                                pkgs.trashy
                                                            ] ;
                                                        password = primary.password ;
                                                    } ;
                                            } ;
                                        options =
                                            {
                                                personal =
                                                    {
                                                        wifi =
                                                            lib.mkOption
                                                                {
                                                                    default = { } ;
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
            } ;
}
