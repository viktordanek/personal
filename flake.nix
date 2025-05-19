{
    inputs =
        {
            cat.url = "github:viktordanek/cat/scratch/a1b4e29f-d775-48f9-a8c8-2642edd842aa" ;
            config.url = "github:viktordanek/config/scratch/3c7895f3-309b-452f-a0fd-bbe3c94d05d7" ;
            git.url = "github:viktordanek/git/88d65d4fa09b6c630b008f67be80c4aa135100da" ;
	        stash-factory.url = "github:viktordanek/stash-factory/scratch/fe259910-5e0e-404c-a032-5b5b0d91538f" ;
	        visitor.url = "github:viktordanek/visitor/scratch/d926f8ea-1fdc-441c-9fd9-8abbc5e13fdf" ;
        } ;
    outputs =
        { cat , config , git , self , stash-factory , visitor } :
            {
                lib =
                    {
                        commit-hash ? null ,
                        current-time ? null ,
                        description ,
                        dot-ssh ? null ,
                        hash-length ? 16 ,
                        identity ? null ,
                        known-host ? null ,
                        name ,
                        nixpkgs ,
                        password ,
                        repository ? null ,
                        stash ? "stash" ,
                        system
                    } :
                        let
                            primary =
                                let
                                    cat-lambda =
                                        target : path : value :
                                            shell-application
                                                target
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
                                                    path = [ primary.commit-hash primary.current-time "cat" target path ] ;
                                                    stash-directory = stash-directory ;
                                                    system = primary.system ;
                                                    targets = [ target ] ;
                                                } ;
                                    in
                                        {
                                            commit-hash =
                                                visitor.lib.implementation
                                                    {
                                                        null = path : value : "" ;
                                                        string = path : value : value ;
                                                    }
                                                    commit-hash ;
                                            current-time =
                                                visitor.lib.implementation
                                                    {
                                                        bool = path : value : value ;
                                                        float = path : value : value ;
                                                        int = path : value : value ;
                                                        null = path : value : value ;
                                                        path = path : value : value ;
                                                        string = path : value : value ;
                                                    }
                                                    current-time ;
                                            description =
                                                visitor.lib.implementation
                                                    {
                                                        string = path : value : value ;
                                                    }
                                                    description ;
                                            dot-ssh =
                                                visitor.lib.implementation
                                                    {
                                                        lambda =
                                                            path : value :
                                                                let
                                                                    point =
                                                                        let
                                                                            identity =
                                                                                {
                                                                                    host ,
                                                                                    host-name ,
                                                                                    identity ,
                                                                                    known-host ,
                                                                                    port ,
                                                                                    user
                                                                                } :
                                                                                    {
                                                                                        host = host ;
                                                                                        host-name = host-name ;
                                                                                        identity =
                                                                                            visitor.lib.implementation
                                                                                                {
                                                                                                    lambda = path : value : "$( ${ value true } )/identity" ;
                                                                                                }
                                                                                                identity ;
                                                                                        known-host =
                                                                                            visitor.lib.implementation
                                                                                                {
                                                                                                    lambda = path : value : "$( ${ value true } )/known-host" ;
                                                                                                }
                                                                                                known-host ;
                                                                                        port = port ;
                                                                                        user = user ;
                                                                                    } ;
                                                                            in identity ( value { identity = primary.identity ; known-host = primary.known-host ; } ) ;
                                                                    in
                                                                        shell-application
                                                                            "dot-ssh"
                                                                            {
                                                                                factory-name = "dot-ssh" ;
                                                                                hash-length = primary.hash-length ;
                                                                                generator = config.lib.generator ;
                                                                                generator-name = "dot-ssh" ;
                                                                                generation-parameters =
                                                                                    {
                                                                                        host = point.host ;
                                                                                        host-name = point.host-name ;
                                                                                        identity = point.identity ;
                                                                                        known-host = point.known-host ;
                                                                                        nixpkgs = nixpkgs ;
                                                                                        port = point.port ;
                                                                                        system = system ;
                                                                                        user = point.user ;
                                                                                    } ;
                                                                                nixpkgs = nixpkgs ;
                                                                                path = [ primary.commit-hash primary.current-time "config" path ] ;
                                                                                stash-directory = stash-directory ;
                                                                                system = primary.system ;
                                                                                targets = [ "target" ] ;
                                                                            } ;
                                                    }
                                                    dot-ssh ;
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
                                            known-host =
                                                visitor.lib.implementation
                                                    {
                                                        path = path : value : cat-lambda "known-host" path value ;
                                                        string = path : value : cat-lambda "known-host" path value ;
                                                    }
                                                    known-host ;
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
                                            repository =
                                                visitor.lib.implementation
                                                    {
                                                        lambda =
                                                            path : value :
                                                                let
                                                                    point =
                                                                        let
                                                                            identity =
                                                                                {
                                                                                    config ,
                                                                                    hooks ,
                                                                                    init ,
                                                                                    remote
                                                                                } :
                                                                                    {
                                                                                        config = config ;
                                                                                        hooks = hooks ;
                                                                                        init = init ;
                                                                                        remote = remote ;
                                                                                    } ;
                                                                            in
                                                                                identity
                                                                                    (
                                                                                        value
                                                                                            (
                                                                                                let
                                                                                                    pkgs = nixpkgs.legacyPackages.${ primary.system } ;
                                                                                                    in
                                                                                                        {
                                                                                                            dot-ssh =
                                                                                                                visitor.lib.implementation
                                                                                                                    {
                                                                                                                        lambda = path : value : "${ pkgs.openssh }/bin/ssh -F $( ${ value true } )/target" ;
                                                                                                                    }
                                                                                                                    primary.dot-ssh ;
                                                                                                            fetch =
                                                                                                                remote : branch :
                                                                                                                    ''
                                                                                                                        if git fetch ${ remote } ${ branch } 2>&1
                                                                                                                        then
                                                                                                                            git checkout ${ remote }/${ branch } 2>&1
                                                                                                                        else
                                                                                                                            git checkout -b ${ branch }
                                                                                                                        fi
                                                                                                                        git fetch ${ remote } 2>&1
                                                                                                                    '' ;
                                                                                                            post-commit =
                                                                                                                remote :
                                                                                                                    let
                                                                                                                        application =
                                                                                                                            pkgs.writeShellApplication
                                                                                                                                {
                                                                                                                                    name = "post-commit" ;
                                                                                                                                    runtimeInputs = [ pkgs.coreutils pkgs.git ] ;
                                                                                                                                    text =
                                                                                                                                        ''
                                                                                                                                            while ! git push ${ remote } HEAD
                                                                                                                                            do
                                                                                                                                                sleep
                                                                                                                                            done
                                                                                                                                        '' ;
                                                                                                                                } ;
                                                                                                                        in "${ application }/bin/post-commit" ;
                                                                                                            pre-commit =
                                                                                                                let
                                                                                                                    application =
                                                                                                                        pkgs.writeShellApplication
                                                                                                                            {
                                                                                                                                name = "pre-commit" ;
                                                                                                                                runtimeInputs = [ pkgs.git pkgs.libuuid ] ;
                                                                                                                                text =
                                                                                                                                    ''
                                                                                                                                        BRANCH="$( git rev-parse --abbrev-ref HEAD )"
                                                                                                                                        if [ -z "$BRANCH" ]
                                                                                                                                        then
                                                                                                                                            BRANCH="scratch/$( uuidgen )"
                                                                                                                                            git checkout -b "$BRANCH" 2> /dev/null
                                                                                                                                        fi
                                                                                                                                    '' ;
                                                                                                                            } ;
                                                                                                                    in "${ application }/bin/pre-commit" ;
                                                                                                        }
                                                                                            )
                                                                                    ) ;
                                                                    in
                                                                        shell-application
                                                                            "repository"
                                                                            {
                                                                                factory-name = "repository" ;
                                                                                hash-length = primary.hash-length ;
                                                                                generator = git.lib.generator ;
                                                                                generator-name = "repository" ;
                                                                                generation-parameters =
                                                                                    {
                                                                                        config = point.config ;
                                                                                        hooks = point.hooks ;
                                                                                        init = point.init ;
                                                                                        nixpkgs = nixpkgs ;
                                                                                        remote = point.remote ;
                                                                                        system = system ;
                                                                                    } ;
                                                                                nixpkgs = nixpkgs ;
                                                                                path = [ primary.commit-hash primary.current-time "repository" path ] ;
                                                                                stash-directory = stash-directory ;
                                                                                system = primary.system ;
                                                                                targets = [ "git" "work-tree" ] ;
                                                                            } ;
                                                    }
                                                    repository ;
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
                                        } ;
                            shell-application =
                                name : set : direct :
                                let
                                    derivation = stash-factory.lib.generator set ;
                                    in if direct then "${ derivation }/bin/${ name }" else builtins.toString derivation ;
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
                                                                                                            ARCHIVE=$( mktemp --dry-run )
                                                                                                            find ${ stash-directory } -mindepth 1 -maxdepth 1 -type d | while read -r DIRECTORY
                                                                                                            do
                                                                                                                mkdir --parents "$ARCHIVE"
                                                                                                                if ( ! find "$DIRECTORY" -atype -7 -quit ) && ( ! find "$DIRECTORY" -ctype -7 -quit ) && ( ! find "$DIRECTORY" -mtype -7 -quit )
                                                                                                                then
                                                                                                                    mv "$DIRECTORY" "$ARCHIVE"
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
                                                            builtins.concatLists
                                                                [
                                                                    (
                                                                        visitor.lib.implementation
                                                                            {
                                                                                lambda =
                                                                                    path : value :
                                                                                        let
                                                                                            reducer = previous : current : if builtins.typeOf current == "int" then builtins.elemAt previous current else if builtins.typeOf current == "string" then builtins.getAttr current previous else builtins.throw "This should not happen." ;
                                                                                            root = builtins.foldl' reducer config.personal.studio path ;
                                                                                            in
                                                                                                if root.enable then
                                                                                                    [
                                                                                                        (
                                                                                                            pkgs.writeShellApplication
                                                                                                                {
                                                                                                                    name =
                                                                                                                        if builtins.typeOf root.name == "string" then root.name
                                                                                                                        else if builtins.length path > 0 then
                                                                                                                            let name = builtins.elemAt path ( ( builtins.length path ) - 1 ) ;
                                                                                                                            in if builtins.typeOf name == "string" then name else builtins.throw "The repository is numbered ${ builtins.toString name } not named."
                                                                                                                        else builtins.throw "The repository is not named because it is root." ;
                                                                                                                    runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.jetbrains.idea-community ] ;
                                                                                                                    text =
                                                                                                                        ''
                                                                                                                            ROOT=$( ${ value true } )
                                                                                                                            GIT_DIR="$ROOT/git"
                                                                                                                            export GIT_DIR
                                                                                                                            GIT_WORK_TREE="$ROOT/work-tree"
                                                                                                                            export GIT_WORK_TREE
                                                                                                                            idea-community "$GIT_WORK_TREE"
                                                                                                                        '' ;
                                                                                                                }
                                                                                                        )
                                                                                                    ]
                                                                                                else [ ] ;
                                                                                list = path : list : builtins.concatLists list ;
                                                                                set = path : set : builtins.concatLists ( builtins.attrValues set ) ;
                                                                            }
                                                                            primary.repository
                                                                    )
                                                                ] ;
                                                        password = primary.password ;
                                                    } ;
                                            } ;
                                        options =
                                            {
                                                personal =
                                                    {
                                                        studio =
                                                            visitor.lib.implementation
                                                                {
                                                                    lambda =
                                                                        path : value :
                                                                            {
                                                                                enable = lib.mkOption { default = false ; type = lib.types.bool ; } ;
                                                                                name = lib.mkOption { default = null ; type = lib.types.nullOr lib.types.str ; } ;
                                                                            } ;
                                                                }
                                                                primary.repository ;
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
