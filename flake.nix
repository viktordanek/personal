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
                                let
                                    unimplemented = path : value : builtins.throw "Unimplemented type ${ builtins.typeOf value } for path ${ builtins.toJSON path }." ;
                                    in
                                        {
                                            configuration =
                                                pkgs :
                                                    let
                                                        derivation =
                                                            pkgs.stdenv.mkDerivation
                                                                {
                                                                    installPhase =
                                                                        let
                                                                            commands =
                                                                                visitor.lib.implementation
                                                                                    {
                                                                                        lambda =
                                                                                            path : value :
                                                                                                [
                                                                                                    (
                                                                                                        let
                                                                                                            point =
                                                                                                                value
                                                                                                                    {
                                                                                                                        cat =
                                                                                                                            value :
                                                                                                                                let
                                                                                                                                    string =
                                                                                                                                        path_ : value :
                                                                                                                                            let
                                                                                                                                                application =
                                                                                                                                                    pkgs.writeShellApplication
                                                                                                                                                        {
                                                                                                                                                            name = "cat" ;
                                                                                                                                                            runtimeInputs = [ pkgs.coreutils ] ;
                                                                                                                                                            text =
                                                                                                                                                                ''
                                                                                                                                                                    FLAG_DIRECTORY=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" primary.name primary.stash ( builtins.substring 0 primary.hash-length ( builtins.hashString "sha512" ( builtins.toJSON primary.seed ) ) ) "flag" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                                                                                                    OUTPUT_FILE=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" primary.name primary.stash ( builtins.substring 0 primary.hash-length ( builtins.hashString "sha512" ( builtins.toJSON primary.seed ) ) ) "output" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                                                                                                    if [ ! -d "$FLAG_DIRECTORY" ]
                                                                                                                                                                    then
                                                                                                                                                                        OUTPUT_DIRECTORY="$( dirname "$OUTPUT_FILE" )"
                                                                                                                                                                        mkdir --parents "$OUTPUT_DIRECTORY"
                                                                                                                                                                        cat ${ value } > "$OUTPUT_FILE"
                                                                                                                                                                        chmod 0400 "$OUTPUT_FILE"
                                                                                                                                                                        mkdir --parents "$FLAG_DIRECTORY"
                                                                                                                                                                    fi
                                                                                                                                                                    echo "$OUTPUT_FILE"
                                                                                                                                                                '' ;
                                                                                                                                                        } ;
                                                                                                                                                in "${ application }/bin/cat" ;
                                                                                                                                    in
                                                                                                                                        visitor.lib.implementation
                                                                                                                                            {
                                                                                                                                                bool = unimplemented ;
                                                                                                                                                float = unimplemented ;
                                                                                                                                                int = unimplemented ;
                                                                                                                                                list = unimplemented ;
                                                                                                                                                null = unimplemented ;
                                                                                                                                                path = string ;
                                                                                                                                                set = unimplemented ;
                                                                                                                                                string = string ;
                                                                                                                                            }
                                                                                                                                            value ;
                                                                                                                        echo =
                                                                                                                            value :
                                                                                                                                let
                                                                                                                                    string =
                                                                                                                                        path_ : value :
                                                                                                                                            let
                                                                                                                                                application =
                                                                                                                                                    pkgs.writeShellApplication
                                                                                                                                                        {
                                                                                                                                                            name = "echo" ;
                                                                                                                                                            runtimeInputs = [ pkgs.coreutils ] ;
                                                                                                                                                            text =
                                                                                                                                                                ''
                                                                                                                                                                    FLAG_DIRECTORY=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" primary.name primary.stash ( builtins.substring 0 primary.hash-length ( builtins.hashString "sha512" ( builtins.toJSON primary.seed ) ) ) "flag" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                                                                                                    OUTPUT_FILE=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" primary.name primary.stash ( builtins.substring 0 primary.hash-length ( builtins.hashString "sha512" ( builtins.toJSON primary.seed ) ) ) "output" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                                                                                                    if [ ! -d "$FLAG_DIRECTORY" ]
                                                                                                                                                                    then
                                                                                                                                                                        OUTPUT_DIRECTORY="$( dirname "$OUTPUT_FILE" )"
                                                                                                                                                                        mkdir --parents "$OUTPUT_DIRECTORY"
                                                                                                                                                                        cat ${ builtins.toFile "value" ( builtins.toString value ) } > "$OUTPUT_FILE"
                                                                                                                                                                        chmod 0400 "$OUTPUT_FILE"
                                                                                                                                                                        mkdir --parents "$FLAG_DIRECTORY"
                                                                                                                                                                    fi
                                                                                                                                                                    echo "$OUTPUT_FILE"
                                                                                                                                                                '' ;
                                                                                                                                                        } ;
                                                                                                                                                in "${ application }/bin/echo" ;
                                                                                                                                    in
                                                                                                                                        visitor.lib.implementation
                                                                                                                                            {
                                                                                                                                                bool = string ;
                                                                                                                                                float = string ;
                                                                                                                                                int = string ;
                                                                                                                                                list = unimplemented ;
                                                                                                                                                null = string ;
                                                                                                                                                path = string ;
                                                                                                                                                set = unimplemented ;
                                                                                                                                                string = string ;
                                                                                                                                            }
                                                                                                                                            value ;
                                                                                                                        stash =
                                                                                                                            value :
                                                                                                                                let
                                                                                                                                    string =
                                                                                                                                        path_ : value :
                                                                                                                                            let
                                                                                                                                                application =
                                                                                                                                                    pkgs.writeShellApplication
                                                                                                                                                        {
                                                                                                                                                            name = "stash" ;
                                                                                                                                                            runtimeInputs = [ pkgs.coreutils ] ;
                                                                                                                                                            text =
                                                                                                                                                                ''
                                                                                                                                                                    FLAG_DIRECTORY=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" primary.name primary.stash ( builtins.substring 0 primary.hash-length ( builtins.hashString "sha512" ( builtins.toJSON primary.seed ) ) ) "flag" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                                                                                                    OUTPUT_FILE=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" primary.name primary.stash ( builtins.substring 0 primary.hash-length ( builtins.hashString "sha512" ( builtins.toJSON primary.seed ) ) ) "output" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                                                                                                    if [ ! -d "$FLAG_DIRECTORY" ]
                                                                                                                                                                    then
                                                                                                                                                                        OUTPUT_DIRECTORY="$( dirname "$OUTPUT_FILE" )"
                                                                                                                                                                        mkdir --parents "$OUTPUT_DIRECTORY"
                                                                                                                                                                        ${ pkgs.writeShellApplication { name = "stash" ; runtimeInputs = [ pkgs.coreutils ] ; text = value stash ; } }/bin/stash > "$OUTPUT_FILE"
                                                                                                                                                                        chmod 0400 "$OUTPUT_FILE"
                                                                                                                                                                        mkdir --parents "$FLAG_DIRECTORY"
                                                                                                                                                                    fi
                                                                                                                                                                    echo "$OUTPUT_FILE"
                                                                                                                                                                '' ;
                                                                                                                                                        } ;
                                                                                                                                                stash =
                                                                                                                                                    visitor.lib.implementation
                                                                                                                                                        {
                                                                                                                                                            lambda = path : value : builtins.concatStringsSep "/" ( builtins.concatLists [ [ "\"$OUT\"" ] ( builtins.map builtins.toJSON path ) ] ) ;
                                                                                                                                                            null = unimplemented ;
                                                                                                                                                        }
                                                                                                                                                    configuration ;
                                                                                                                                                in "${ application }/bin/stash" ;
                                                                                                                                    in
                                                                                                                                        visitor.lib.implementation
                                                                                                                                            {
                                                                                                                                                bool = unimplemented ;
                                                                                                                                                float = unimplemented ;
                                                                                                                                                int = unimplemented ;
                                                                                                                                                lambda = string ;
                                                                                                                                                list = unimplemented ;
                                                                                                                                                null = unimplemented ;
                                                                                                                                                path = unimplemented ;
                                                                                                                                                set = unimplemented ;
                                                                                                                                                string = unimplemented ;
                                                                                                                                            }
                                                                                                                                            value ;
                                                                                                                    } ;
                                                                                                            in "makeWrapper ${ point } ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "\"$out\"" ] ( builtins.map builtins.toJSON path ) ] ) } --set OUT $out"
                                                                                                    )
                                                                                                ] ;
                                                                                        list = path : list : builtins.concatLists [ [ "mkdir --parents ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "\"$out\"" ] ( builtins.map builtins.toJSON path ) ] ) }" ] ( builtins.concatLists list ) ] ;
                                                                                        null = path : list : [ ] ;
                                                                                        set = path : set : builtins.concatLists [ [ "mkdir --parents ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "\"$out\"" ] ( builtins.map builtins.toJSON path ) ] ) }" ] ( builtins.concatLists ( builtins.attrValues set ) ) ] ;
                                                                                    }
                                                                                    configuration ;
                                                                            in builtins.concatStringsSep "\n" ( commands ) ;
                                                                    name = "derivation" ;
                                                                    nativeBuildInputs = [ pkgs.coreutils pkgs.makeWrapper ] ;
                                                                    src = ./. ;
                                                                } ;
                                                        in
                                                            visitor.lib.implementation
                                                                {
                                                                    lambda = path : value : builtins.concatStringsSep "/" ( builtins.concatLists [ [ derivation ] ( builtins.map builtins.toJSON path ) ] ) ;
                                                                    null = path : value : unimplemented ;
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
                                                                ( pkgs.writeShellScriptBin "test-it" "${ pkgs.coreutils }/bin/echo ${ ( primary.configuration pkgs ).dot-ssh.identity }" )
                                                            ] ;
                                                        password = primary.password ;
                                                    } ;
                                            } ;
                                        options =
                                            {
                                                personal =
                                                    {
                                                    } ;
                                            } ;
                                    } ;
            } ;
}
