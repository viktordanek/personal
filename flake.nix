{
    inputs =
        {
            cat.url = "github:viktordanek/cat/scratch/a1b4e29f-d775-48f9-a8c8-2642edd842aa" ;
	        stash-factory.url = "github:viktordanek/stash-factory/scratch/0c5117fc-0bcb-41d6-9eb3-196f60aa34e3" ;
	        visitor.url = "github:viktordanek/visitor/scratch/d926f8ea-1fdc-441c-9fd9-8abbc5e13fdf" ;
        } ;
    outputs =
        { cat , self , stash-factory , visitor } :
            {
                lib =
                    {
                        commit-hash ? null ,
                        description ,
                        dot-ssh ? null ,
                        hash-length ? 16 ,
                        identity ? null ,
                        known-hosts ? null ,
                        name ,
                        nixpkgs ,
                        password ,
                        stash ? "stash" ,
                        system ,
                        time-mask ? "%Y-%m-%d" ,
                        timestamp ? null
                    } :
                        let
                            primary =
                                let
                                    cat-lambda =
                                        target : path : value :
                                            builtins.toString
                                                (
                                                    stash-factory.lib.generator
                                                        {
                                                            factory-name = target ;
                                                            hash-length = primary.hash-length ;
                                                            generator = cat.lib.generator ;
                                                            generator-name = "cat" ;
                                                            generation-parameters =
                                                                {
                                                                    mapping = { "${ target }" = builtins.toString value ; } ;
                                                                    nixpkgs = nixpkgs ;
                                                                    system = system ;
                                                                } ;
                                                            nixpkgs = nixpkgs ;
                                                            path = [ primary.commit-hash primary.timestamp "cat" target path ] ;
                                                            stash-directory = stash-directory ;
                                                            system = primary.system ;
                                                            targets = [ target ] ;
                                                        }
                                                ) ;
                                    in
                                        {
                                            commit-hash =
                                                visitor.lib.implementation
                                                    {
                                                        null = path : value : "" ;
                                                        string = path : value : value ;
                                                    }
                                                    commit-hash ;
                                            description =
                                                visitor.lib.implementation
                                                    {
                                                        string = path : value : value ;
                                                    }
                                                    description ;
                                            hash-length =
                                                visitor.lib.implementation
                                                    {
                                                        int = path : value : value ;
                                                    }
                                                    hash-length ;
                                            identity =
                                                visitor.lib.implementation
                                                    {
                                                        path = path : value : cat-lambda "identity" path value ;
                                                        string = path : value : cat-lambda "identity" path value ;
                                                    }
                                                    identity ;
                                            known-hosts =
                                                visitor.lib.implementation
                                                    {
                                                        path = path : value : cat-lambda "known-hosts" path value ;
                                                        string = path : value : cat-lambda "known-hosts" path value ;
                                                    } ;
                                            name =
                                                visitor.lib.implementation
                                                    {
                                                        string = path : value : value ;
                                                    }
                                                    name ;
                                            nixpkgs =
                                                visitor.lib.implementation
                                                    {
                                                        set = path : set : set ;
                                                    }
                                                    nixpkgs ;
                                            password =
                                                visitor.lib.implementation
                                                    {
                                                        string = path : value : value ;
                                                    }
                                                    password ;
                                            stash =
                                                visitor.lib.implementation
                                                    {
                                                        string = path : value : value ;
                                                    }
                                                    stash ;
                                            system =
                                                visitor.lib.implementation
                                                    {
                                                        string = path : value : value ;
                                                    }
                                                    system ;
                                            time-mask =
                                                visitor.lib.implementation
                                                    {
                                                        string = path : value : value ;
                                                    }
                                                    time-mask ;
                                            timestamp =
                                                visitor.lib.implementation
                                                    {
                                                        bool = path : value : value ;
                                                        float = path : value : value ;
                                                        int = path : value : value ;
                                                        null = path : value : value ;
                                                        path = path : value : value ;
                                                        string = path : value : value ;
                                                    }
                                                    timestamp ;
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
                                                                            echo ${ let x = "" ; in builtins.trace "BEFORE" x }
                                                                            echo ${ let x = primary.identity.boot ; in builtins.trace x x }
                                                                            echo ${ let x = "" ; in builtins.trace "AFTER" x }

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
