{
    inputs =
        {
	        visitor.url = "github:viktordanek/visitor" ;
        } ;
    outputs =
        { self , visitor } :
            {
                lib =
                    {
                        agenix ,
                        nixpkgs ,
                        secrets ,
                        system
                    } :
                        let
                            unimplemented = path : value : builtins.throw "The ${ builtins.typeOf value } visitor for ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is purposefully unimplemented." ;
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
                                                                        lambda =
                                                                            path : value :
                                                                                let
                                                                                    setup =
                                                                                        pkgs.writeShellApplication
                                                                                            {
                                                                                                name = "setup" ;
                                                                                                runtimeInputs = [ pkgs.coreutils pkgs.flock pkgs.jq pkgs.yq ] ;
                                                                                                text =
                                                                                                    let
                                                                                                        init =
                                                                                                            pkgs.buildFHSUserEnv
                                                                                                                {
                                                                                                                    extraBwrapArgs = [ "--mount $STASH/mount /mount" "--ro-mount /home/${ config.personal.name }/${ config.personal.stash } /home/${ config.personal.name }/${ config.personal.stash }" ] ;
                                                                                                                    name = "init" ;
                                                                                                                    runScript = point.init-script ;
                                                                                                                    targetPkgs = point.init-packages ;
                                                                                                                } ;
                                                                                                        point =
                                                                                                            let
                                                                                                                identity =
                                                                                                                    {
                                                                                                                        dependencies ? { } ,
                                                                                                                        init-packages ? pkgs : [ pkgs.coreutils ] ,
                                                                                                                        init-script ? "" ,
                                                                                                                        outputs ? [ ] ,
                                                                                                                        release-packages ? pkgs : [ pkgs.coreutils ] ,
                                                                                                                        release-script ? ""
                                                                                                                    } :
                                                                                                                        {
                                                                                                                            dependencies = dependencies ;
                                                                                                                            init-packages = init-packages ;
                                                                                                                            init-script = init-script ;
                                                                                                                            outputs = outputs ;
                                                                                                                            release-packages = release-packages ;
                                                                                                                            release-script = release-script ;
                                                                                                                        } ;
                                                                                                                in identity ( value null ) ;
                                                                                                        teardown =
                                                                                                            pkgs.writeShellApplication
                                                                                                                {
                                                                                                                    name = "teardown" ;
                                                                                                                    runtimeInputs = [ pkgs.coreutils ] ;
                                                                                                                    text =
                                                                                                                        let
                                                                                                                            release =
                                                                                                                                pkgs.buildFHSUserEnv
                                                                                                                                    {
                                                                                                                                        extraBwrapArgs = [ "--mount $STASH/mount /mount" "--ro-mount /home/${ config.personal.name }/${ config.personal.stash } /home/${ config.personal.name }/${ config.personal.stash }" ] ;
                                                                                                                                        name = "release" ;
                                                                                                                                        runScript = point.release-script ;
                                                                                                                                        targetPkgs = point.release-packages ;
                                                                                                                                    } ;
                                                                                                                            in
                                                                                                                                ''
                                                                                                                                    export STASH=${ builtins.concatStringsSep "/" [ [ "" "home" config.personal.name config.personal.stash ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString config.personal.current-time ) ) ) "output" ] ( builtins.map builtins.toJSON path ) ] }
                                                                                                                                    # FIXME recursively teardown
                                                                                                                                    ${ release }/bin/release
                                                                                                                                    rm --recursive --force "$STASH"
                                                                                                                                '' ;
                                                                                                                } ;
                                                                                                        in
                                                                                                            ''
                                                                                                                export STASH=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" config.personal.name config.personal.stash ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString config.personal.current-time ) ) ) "output" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                                                mkdir --parents "$STASH"
                                                                                                                exec 201> ${ builtins.concatStringsSep "/" [ "" "home" config.personal.name config.personal.stash ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString config.personal.current-time ) ) ) "lock" ] }
                                                                                                                flock -s 201
                                                                                                                exec 202> "$STASH/lock"
                                                                                                                flock -x 202
                                                                                                                if [ -f "$STASH/success.yaml" ]
                                                                                                                then
                                                                                                                    echo "$STASH/mount"
                                                                                                                    flock -u 202
                                                                                                                    flock -u 201
                                                                                                                    exit 0
                                                                                                                elif [ -f "$STASH/failure.yaml" ]
                                                                                                                then
                                                                                                                    yq --yaml-output "$STASH/failure.yaml" "." >&2
                                                                                                                    flock -u 202
                                                                                                                    flock -u 201
                                                                                                                    exit 65
                                                                                                                else
                                                                                                                    # FIXME dependencies
                                                                                                                    mkdir --parents "$STASH/mount"
                                                                                                                    if ${ init }/bin/init > "$STASH/standard-output" 2> "$STASH/standard-error"
                                                                                                                    then
                                                                                                                        if [ -s "$STASH/standard-error" ]
                                                                                                                        then
                                                                                                                            jq --null-input '{ "failure" :  8052 }' | yq --yaml-output > "$STASH/failure.yaml"
                                                                                                                            flock -u 202
                                                                                                                            flock -u 201
                                                                                                                            exit 66
                                                                                                                        elif [ "$( find "$STASH/mount -mindepth 1 -maxdepth 1 ${ builtins.concatStringsSep " " ( builtins.map ( name : "! -name ${ name }" ) point.outputs ) }" | wc --lines )" != 0 ]
                                                                                                                        then
                                                                                                                            jq --null-input '{ "failure" :  5451 }' | yq --yaml-output > "$STASH/failure.yaml"
                                                                                                                            flock -u 202
                                                                                                                            flock -u 201
                                                                                                                            exit 67
                                                                                                                        elif [ "$( find "$STASH/mount -mindepth 1 -maxdepth 1 ${ builtins.concatStringsSep " " ( builtins.map ( name : "-name ${ name }" ) point.outputs ) }" | wc --lines )" != ${ builtins.toString ( builtins.length point.outputs ) } ]
                                                                                                                        then
                                                                                                                            jq --null-input '{ "failure" :  7830 }' | yq --yaml-output > "$STASH/failure.yaml"
                                                                                                                            flock -u 202
                                                                                                                            flock -u 201
                                                                                                                            exit 68
                                                                                                                        else
                                                                                                                            # FIXME link the teardown script
                                                                                                                            echo "$?" > "$STASH/success.yaml"
                                                                                                                            echo "$STASH/mount"
                                                                                                                            flock -u 202
                                                                                                                            flock -u 201
                                                                                                                            exit 0
                                                                                                                        fi
                                                                                                                    else
                                                                                                                        jq --null-input '{ "failure" :  7830 }' | yq --yaml-output > "$STASH/failure.yaml"
                                                                                                                        yq --yaml-output "$STASH/failure.yaml" >&2
                                                                                                                        flock -u 202
                                                                                                                        flock -u 201
                                                                                                                        exit 69
                                                                                                                    fi
                                                                                                                fi
                                                                                                            '' ;
                                                                                            } ;
                                                                                    in [ "makeWrapper ${ setup }/bin/setup ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$out" ] ( builtins.map builtins.toJSON path ) ] ) } --set OUT $out" ] ;
                                                                        list = path : list : builtins.concatLists [ [ "mkdir --parents ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$out" ] ( builtins.map builtins.toJSON path ) ] ) }" ] ( builtins.concatLists list ) ] ;
                                                                        null = path : value : [ "mkdir --parents ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$out" ] ( builtins.map builtins.toJSON path ) ] ) }" ] ;
                                                                        set = path : set : builtins.concatLists [ [ "mkdir --parents ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$out" ] ( builtins.map builtins.toJSON path ) ] ) }" ] ( builtins.concatLists ( builtins.attrValues set ) ) ] ;
                                                                    }
                                                                    (
                                                                        let
                                                                            in
                                                                                {
                                                                                    couple = { } ;
                                                                                    family = { } ;
                                                                                    personal = { } ;
                                                                                    scratch =
                                                                                        {
                                                                                            one =
                                                                                                ignore :
                                                                                                    {
                                                                                                    } ;
                                                                                            two =
                                                                                                ignore :
                                                                                                    {
                                                                                                    } ;
                                                                                        } ;
                                                                                }
                                                                    ) ;
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
                                                        environment =
                                                            {
                                                                etc =
                                                                    {
                                                                        "agenix/age.key" =
                                                                            {
                                                                                source = config.personal.agenix ;
                                                                                mode = "0400" ;
                                                                                group = "root" ;
                                                                            } ;
                                                                    } ;
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
                                                        users.users.backup =
                                                            {
                                                                description = "delete me" ;
                                                                name = "backup" ;
                                                                isNormalUser = true ;
                                                                password = "password" ;
                                                                extraGroups = [ "wheel" ] ;
                                                            } ;
                                                        users.users.user =
                                                            {
                                                                description = config.personal.description ;
                                                                extraGroups = [ "wheel" ] ;
                                                                isNormalUser = true ;
                                                                name = config.personal.name ;
                                                                packages =
                                                                    [
                                                                        pkgs.git
                                                                        pkgs.git-crypt
                                                                        pkgs.pass
                                                                        (
                                                                            pkgs.writeShellApplication
                                                                                {
                                                                                    name = "portfolio" ;
                                                                                    runtimeInputs = [ pkgs.findutils ] ;
                                                                                    text =
                                                                                        ''
                                                                                            find ${ derivation } -mindepth 1 -type f -exec {} \;
                                                                                        '' ;
                                                                                }
                                                                        )
                                                                        (
                                                                            pkgs.writeShellApplication
                                                                                {
                                                                                    name = "studio" ;
                                                                                    runtimeInputs = [ pkgs.findutils pkgs.git pkgs.jetbrains.idea-community pkgs.git-crypt] ;
                                                                                    text =
                                                                                        ''
                                                                                            find ${ derivation } -mindepth 1 -type f -exec {} \;
                                                                                            ROOT_DIR=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" config.personal.name config.personal.stash ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toJSON ( builtins.readFile config.personal.current-time ) ) ) ) ] ] ) }
                                                                                            idea-community "$ROOT_DIR"
                                                                                        '' ;
                                                                                }
                                                                        )
                                                                    ] ;
                                                                password = config.personal.password ;
                                                            } ;
                                                    } ;
                                                options =
                                                    {
                                                        personal =
                                                            {
                                                                agenix = lib.mkOption { type = lib.types.path ; } ;
                                                                current-time = lib.mkOption { type = lib.types.path ; } ;
                                                                description = lib.mkOption { type = lib.types.str ; } ;
                                                                email = lib.mkOption { type = lib.types.str ; } ;
                                                                hash-length = lib.mkOption { default = 16 ; type = lib.types.int ; } ;
                                                                name = lib.mkOption { type = lib.types.str ; } ;
                                                                password = lib.mkOption { type = lib.types.str ; } ;
                                                                repository =
                                                                    {
                                                                        age-secrets =
                                                                            {
                                                                                branch = lib.mkOption { default = "main" ; type = lib.types.str ; } ;
                                                                                remote = lib.mkOption { default = "git@github.com:AFnRFCb7/12e5389b-8894-4de5-9cd2-7dab0678d22b" ; type = lib.types.str ; } ;
                                                                           } ;
                                                                        pass-secrets =
                                                                            {
                                                                                branch = lib.mkOption { default = "scratch/8060776f-fa8d-443e-9902-118cf4634d9e" ; type = lib.types.str ; } ;
                                                                                remote = lib.mkOption { default = "git@github.com:nextmoose/secrets.git" ; type = lib.types.str ; } ;
                                                                            } ;
                                                                        personal =
                                                                            {
                                                                                branch = lib.mkOption { default = "main" ; type = lib.types.str ; } ;
                                                                                remote = lib.mkOption { default = "git@github.com:viktordanek/personal.git" ; type = lib.types.str ; } ;
                                                                            } ;
                                                                        private =
                                                                            {
                                                                                branch = lib.mkOption { default = "main" ; type = lib.types.str ; } ;
                                                                                remote = lib.mkOption { default = "mobile:private" ; type = lib.types.str ; } ;
                                                                            } ;
                                                                    } ;
                                                                stash = lib.mkOption { default = "stash" ; type = lib.types.str ; } ;
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
