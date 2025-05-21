{
    inputs =
        {
	        visitor.url = "github:viktordanek/visitor/scratch/d926f8ea-1fdc-441c-9fd9-8abbc5e13fdf" ;
        } ;
    outputs =
        { self , visitor } :
            {
                lib =
                    {
                        configuration ? null ,
                        description ,
                        hash-length ? 16 ,
                        name ,
                        nixpkgs ,
                        password ,
                        seed ? null ,
                        stash ? "stash" ,
                        system
                    } :
                        let
                            primary =
                                {
                                    configuration =
                                        visitor.lib.implementation
                                            {
                                                lambda = path : value : value ;
                                                null = path : value : value ;
                                            }
                                            configuration ;
                                    description = visitor.lib.implementation { list = unimplemented ; set = unimplemented ; string = path : value : value ; } description ;
                                    hash-length = visitor.lib.implementation { list = unimplemented ; int = path : value : value ; set = unimplemented ; } hash-length ;
                                    name = visitor.lib.implementation { list = unimplemented ; set = unimplemented ; string = path : value : value ; } name ;
                                    password = visitor.lib.implementation { list = unimplemented ; set = unimplemented ; string = path : value : value ; } password ;
                                    seed =
                                        visitor.lib.implementation
                                            {
                                                bool = path : value : { type = builtins.typeOf value ; value = value ; } ;
                                                float = path : value : { type = builtins.typeOf value ; value = value ; } ;
                                                int = path : value : { type = builtins.typeOf value ; value = value ; } ;
                                                lambda = path : value : { type = builtins.typeOf value ; value = null ; } ;
                                                list = path : value : { type = builtins.typeOf value ; value = value ; } ;
                                                null = path : value : { type = builtins.typeOf value ; value = value ; } ;
                                                path = path : value : { type = builtins.typeOf value ; value = value ; } ;
                                                set = path : value : { type = builtins.typeOf value ; value = value ; } ;
                                                string = path : value : { type = builtins.typeOf value ; value = value ; } ;
                                            }
                                            seed ;
                                    stash = visitor.lib.implementation { list = unimplemented ; set = unimplemented ; string = path : value : value ; } stash ;
                                } ;
                            unimplemented = path : value : builtins.throw "The visitor for ${ builtins.typeOf value } at path ${ builtins.toJSON path } is purposefully unimplemented." ;
                            in
                                { config , lib , pkgs , ... } :
                                    let
                                        derivation =
                                            pkgs.stdenv.mkDerivation
                                                {
                                                    installPhase =
                                                        let
                                                            commands =
                                                                visitor.lib.implementation
                                                                    {
                                                                        lambda = path : value : let point = value null ; in [ "makeWrapper ${ point.command } ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$out" ] ( builtins.map builtins.toJSON path ) ] ) }" ] ;
                                                                        list = path : list : builtins.concatLists [ [ "mkdir --parents ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$out" ] ( builtins.map builtins.toJSON path ) ] ) }" ] ( builtins.concatLists list ) ] ;
                                                                        null = path : value : [ ] ;
                                                                        set = path : set : builtins.concatLists [ [ "mkdir --parents ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$out" ] ( builtins.map builtins.toJSON path ) ] ) }"  ] ( builtins.concatLists ( builtins.attrValues set ) ) ] ;
                                                                    }
                                                                    secondary ;
                                                            identity =
                                                                visitor.lib.implementation
                                                                    {
                                                                        lambda = path : value : let point = value null ; in if point.identity then "$( ${ point.command } )" else unimplemented path value ;
                                                                        null = unimplemented ;
                                                                    }
                                                                    secondary ;
                                                            known-host =
                                                                visitor.lib.implementation
                                                                    {
                                                                        lambda = path : value : let point = value null ; in if point.known-host then "$( ${ point.command } )" else unimplemented path value ;
                                                                        null = unimplemented ;
                                                                    }
                                                                    secondary ;
                                                            secondary =
                                                                visitor.lib.implementation
                                                                    {
                                                                        lambda =
                                                                            path : value : ignore :
                                                                                value
                                                                                    {
                                                                                        dot-ssh-config =
                                                                                            fun :
                                                                                                let
                                                                                                    application =
                                                                                                        pkgs.writeShellApplication
                                                                                                            {
                                                                                                                name = "dot-ssh-config" ;
                                                                                                                text =
                                                                                                                    let
                                                                                                                        point =
                                                                                                                            let
                                                                                                                                identity_ =
                                                                                                                                    {
                                                                                                                                        host ? null ,
                                                                                                                                        host-name ,
                                                                                                                                        identity ,
                                                                                                                                        known-host ,
                                                                                                                                        port ? 22 ,
                                                                                                                                        user ? "git"
                                                                                                                                    } :
                                                                                                                                        {
                                                                                                                                            host = if builtins.typeOf host == "null" then host-name else host ;
                                                                                                                                            host-name = host-name ;
                                                                                                                                            identity = identity ;
                                                                                                                                            known-host = known-host ;
                                                                                                                                            port = builtins.toString port ;
                                                                                                                                            user = user ;
                                                                                                                                        } ;
                                                                                                                                    in identity_ ( fun { identity = identity ; known-host = known-host ; } ) ;
                                                                                                                        in
                                                                                                                            ''
                                                                                                                                STASH_FILE=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" primary.name primary.stash ( builtins.substring 0 primary.hash-length ( builtins.hashString "sha512" ( builtins.toJSON ( primary.seed ) ) ) ) "stash" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                                                                FLAG_DIRECTORY=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" primary.name primary.stash ( builtins.substring 0 primary.hash-length ( builtins.hashString "sha512" ( builtins.toJSON ( primary.seed ) ) ) ) "flag" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                                                                if [ -d "$FLAG_DIRECTORY" ]
                                                                                                                                then
                                                                                                                                    exec 201> "$FLAG_DIRECTORY/lock"
                                                                                                                                    flock -s 201
                                                                                                                                    echo "$STASH_FILE"
                                                                                                                                    flock -u 201
                                                                                                                                else
                                                                                                                                    mkdir --parents "$FLAG_DIRECTORY"
                                                                                                                                    exec 201> "$FLAG_DIRECTORY/lock"
                                                                                                                                    flock -x 201
                                                                                                                                    STASH_DIRECTORY=$( dirname "$STASH_FILE" )
                                                                                                                                    mkdir --parents "$STASH_DIRECTORY"
                                                                                                                                    cat > "$STASH_FILE" <<EOF
                                                                                                                                Host ${ point.host }
                                                                                                                                HostName ${ point.host-name }
                                                                                                                                IdentityFile ${ point.identity }
                                                                                                                                Port ${ point.port }
                                                                                                                                StrictHostKeyChecking yes
                                                                                                                                User ${ point.user }
                                                                                                                                UserKnownHostsFile ${ point.known-host }
                                                                                                                                EOF
                                                                                                                                    chmod 0400 "$STASH_FILE"
                                                                                                                                    echo "$STASH_FILE"
                                                                                                                                    flock -u 201
                                                                                                                                fi
                                                                                                                    '' ;
                                                                                                            } ;
                                                                                                    in { identity = false ; command = "${ application }/bin/dot-ssh-config" ; known-host = false ; ssh-dot-config = true ; } ;
                                                                                        identity =
                                                                                            file :
                                                                                                let
                                                                                                    application =
                                                                                                        pkgs.writeShellApplication
                                                                                                            {
                                                                                                                name = "identity" ;
                                                                                                                text =
                                                                                                                    ''
                                                                                                                        STASH_FILE=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" primary.name primary.stash ( builtins.substring 0 primary.hash-length ( builtins.hashString "sha512" ( builtins.toJSON ( primary.seed ) ) ) ) "stash" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                                                        FLAG_DIRECTORY=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" primary.name primary.stash ( builtins.substring 0 primary.hash-length ( builtins.hashString "sha512" ( builtins.toJSON ( primary.seed ) ) ) ) "flag" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                                                        if [ -d "$FLAG_DIRECTORY" ]
                                                                                                                        then
                                                                                                                            exec 201> "$FLAG_DIRECTORY/lock"
                                                                                                                            flock -s 201
                                                                                                                            echo "$STASH_FILE"
                                                                                                                            flock -u 201
                                                                                                                        else
                                                                                                                            mkdir --parents "$FLAG_DIRECTORY"
                                                                                                                            exec 201> "$FLAG_DIRECTORY/lock"
                                                                                                                            flock -x 201
                                                                                                                            STASH_DIRECTORY=$( dirname "$STASH_FILE" )
                                                                                                                            mkdir --parents "$STASH_DIRECTORY"
                                                                                                                            cat ${ file } > "$STASH_FILE"
                                                                                                                            chmod 0400 "$STASH_FILE"
                                                                                                                            echo "$STASH_FILE"
                                                                                                                            flock -u 201
                                                                                                                        fi
                                                                                                                    '' ;
                                                                                                            } ;
                                                                                                    in { identity = true ; command = "${ application }/bin/identity" ; known-host = false ; ssh-dot-config = false ; } ;
                                                                                        known-host =
                                                                                            file :
                                                                                                let
                                                                                                    application =
                                                                                                        pkgs.writeShellApplication
                                                                                                            {
                                                                                                                name = "known-host" ;
                                                                                                                text =
                                                                                                                    ''
                                                                                                                        STASH_FILE=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" primary.name primary.stash ( builtins.substring 0 primary.hash-length ( builtins.hashString "sha512" ( builtins.toJSON ( primary.seed ) ) ) ) "stash" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                                                        FLAG_DIRECTORY=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" primary.name primary.stash ( builtins.substring 0 primary.hash-length ( builtins.hashString "sha512" ( builtins.toJSON ( primary.seed ) ) ) ) "flag" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                                                        if [ -d "$FLAG_DIRECTORY" ]
                                                                                                                        then
                                                                                                                            exec 201> "$FLAG_DIRECTORY/lock"
                                                                                                                            flock -s 201
                                                                                                                            echo "$STASH_FILE"
                                                                                                                            flock -u 201
                                                                                                                        else
                                                                                                                            mkdir --parents "$FLAG_DIRECTORY"
                                                                                                                            exec 201> "$FLAG_DIRECTORY/lock"
                                                                                                                            flock -x 201
                                                                                                                            STASH_DIRECTORY=$( dirname "$STASH_FILE" )
                                                                                                                            mkdir --parents "$STASH_DIRECTORY"
                                                                                                                            cat ${ file } > "$STASH_FILE"
                                                                                                                            chmod 0400 "$STASH_FILE"
                                                                                                                            echo "$STASH_FILE"
                                                                                                                            flock -u 201
                                                                                                                        fi
                                                                                                                    '' ;
                                                                                                            } ;
                                                                                                    in { identity = false ; command = "${ application }/bin/known-host" ; known-host = true ; ssh-dot-config = false ; } ;
                                                                                    } ;
                                                                        null = path : value : value ;
                                                                    }
                                                                    primary.configuration ;
                                                            in builtins.concatStringsSep "\n" commands ;
                                                    name = "derivation" ;
                                                    nativeBuildInputs = [ pkgs.makeWrapper ] ;
                                                    src = ./. ;
                                                } ;
                                        in
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
                                                                bash.interactiveShellInit = ''eval "$( ${ pkgs.direnv }/bin/direnv hook bash )"'' ;
                                                                dconf.enable = true ;
                                                                direnv =
                                                                    {
                                                                        nix-direnv.enable = true ;
                                                                        enable = true ;
                                                                    } ;
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
                                                                        pkgs.git
                                                                        ( pkgs.writeShellScriptBin "test-it" "${ pkgs.coreutils }/bin/echo ${ derivation }" )
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
