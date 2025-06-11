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
                                        dependencies =
                                            let
                                                list =
                                                    let
                                                        mapper = resource : { name = resource.name ; value = builtins.concatLists [ [ resource.dependencies ] ( builtins.map ( dependency : builtins.getAttr dependency dependencies ) ( builtins.trace "33a61db7-4b2d-4f93-9a7c-652bb77f4fa0 XX" resource.dependencies ) ) ] ; } ;
                                                        in builtins.map mapper points ;
                                                in builtins.listToAttrs list ;
                                        outputs =
                                            let
                                                list =
                                                    let
                                                        mapper = resource : { name = resource.name ; value = resource.outputs ; } ;
                                                        in builtins.map mapper points ;
                                                in builtins.listToAttrs list ;
                                        points =
                                            visitor.lib.implementation
                                                {
                                                    lambda =
                                                        path : value :
                                                            let
                                                                identity =
                                                                    {
                                                                        dependencies ? x : [ ] ,
                                                                        init-packages ? pkgs : [ ] ,
                                                                        init-script ? "" ,
                                                                        outputs ? [ ] ,
                                                                        release-packages ? pkgs : [ ] ,
                                                                        release-script ? ""
                                                                    } :
                                                                        {
                                                                            dependencies =
                                                                                let
                                                                                    list =
                                                                                        visitor.lib.implementation
                                                                                            {
                                                                                                lambda = path : value : [ ( value tree ) ] ;
                                                                                                list = path : list : builtins.concatLists list ;
                                                                                                set = path : set : builtins.concatLists ( builtins.attrValues set ) ;
                                                                                            }
                                                                                            resources ;
                                                                                    tree =
                                                                                        visitor.lib.implementation
                                                                                            {
                                                                                                lambda = path : value : builtins.concatStringsSep "/" ( builtins.map builtins.toJSON path ) ;
                                                                                            }
                                                                                            resources ;
                                                                                    in builtins.trace "528e19fc-c058-41e6-844e-48366510a16d ${ builtins.toJSON tree } -- ${ builtins.toJSON list }" ( builtins.map ( dependency : if builtins.elem dependency list then dependency else builtins.throw "dependency ${ builtins.toString dependency } is not correct." ) ( dependencies tree ) ) ;
                                                                            init-packages = init-packages ;
                                                                            init-script = init-script ;
                                                                            name = builtins.concatStringsSep "/" ( builtins.map builtins.toJSON path ) ;
                                                                            outputs = outputs ;
                                                                            path = path ;
                                                                            release-packages = release-packages ;
                                                                            release-script = release-script ;
                                                                        } ;
                                                                in [ ( identity ( value null ) ) ] ;
                                                    list = path : list : builtins.concatLists list ;
                                                    null = path : value : [ ] ;
                                                    set = path : set : builtins.concatLists ( builtins.attrValues set ) ;
                                                }
                                                resources ;
                                        resources =
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
                                                                            init-script = "echo one > /mount/one" ;
                                                                            outputs = [ "one" ] ;
                                                                        } ;
                                                            } ;
                                                    } ;
                                        scripts =
                                            let
                                                mapper =
                                                    resource :
                                                        let
                                                            dependencies-transitive-closure = builtins.getAttr resource.name dependencies ;
                                                            in
                                                                {
                                                                    index =
                                                                        let
                                                                            filtered = builtins.trace "9912a0bf-9d1c-4d54-b314-967cf9986ef0" ( builtins.filter ( indexed : indexed.value.name == resource.name ) indexed ) ;
                                                                            find = builtins.trace "4ff3e2b5-faf7-4667-845f-afb69e7c301a" ( builtins.elemAt 0 filtered ) ;
                                                                            indexed = builtins.trace "8534acfd-672e-4d64-bd6c-ba4f10bbd1cd" ( builtins.genList ( index : { index = index ; value = builtins.elemAt sorted index ; } ) ( builtins.length sorted ) ) ;
                                                                            list = builtins.trace "a132782b-365a-4999-a7f3-ced24634a5d6 ${ builtins.typeOf dependencies } ${ builtins.concatStringsSep " , " ( builtins.attrNames dependencies ) } } " ( builtins.attrValues ( builtins.mapAttrs ( name : value : { name = name ; value = value ; } ) dependencies ) ) ;
                                                                            sorted = builtins.trace "48a1d55c-3b17-427b-8ecc-3b79ef7b3911" ( builtins.sort ( a : b : if ( builtins.length a.value ) < ( builtins.length b.value ) then true else if ( builtins.length a.valu48a1d55c-3b17-427b-8ecc-3b79ef7b3911e ) > ( builtins.length b.value ) then false else if a.name < b.name then true else if a.name > b.name then false else builtins.throw "identical elements" ) list ) ;
                                                                            in builtins.trace "c1f3ebcd-d159-481e-adf5-69cffcc0f981" find.index ;
                                                                    setup =
                                                                        pkgs.writeShellApplication
                                                                            {
                                                                                name = "setup" ;
                                                                                runtimeInputs = [ pkgs.coreutils pkgs.findutils pkgs.flock pkgs.jq pkgs.yq ] ;
                                                                                text =
                                                                                    let
                                                                                        init =
                                                                                            pkgs.buildFHSUserEnv
                                                                                                {
                                                                                                    name = "init" ;
                                                                                                    runScript =
                                                                                                        let
                                                                                                            init = pkgs.writeShellApplication { name = "init" ; text = resource.init-script ; } ;
                                                                                                            in "${ init }/bin/init" ;
                                                                                                    targetPkgs = resource.init-packages ;
                                                                                                } ;
                                                                                        yaml =
                                                                                            code :
                                                                                                ''
                                                                                                    jq --null-input --arg CODE "${ builtins.toString code }" --arg EXPECTED "${ builtins.concatStringsSep "\n" resource.outputs }" --arg OBSERVED "$( find "$STASH/mount -mindepth 1 -maxdepth 1 | sort" )" --arg STANDARD_ERROR "$( cat "$STASH/standard-error" )" --arg STANDARD_OUTPUT "$( cat "$STASH/standard-output" )" --arg STATUS "$( cat "$?" )" '{ "code" : $CODE , "observed" : $OBSERVED , ""standard-error" : $STANDARD_ERROR , "standard-output" : $STANDARD_OUTPUT , "status" : $STATUS }' | yq --yaml-output "." > "$STASH/${ if code == 0 then "success" else "failure" }.yaml
                                                                                                '' ;
                                                                                        in
                                                                                            ''
                                                                                                ROOT=${ builtins.concatStringsSep "/" [ "" "home" config.personal.name config.personal.stash ] } ;
                                                                                                mkdir --parents "$ROOT"
                                                                                                exec 201> "$ROOT/lock"
                                                                                                flock -x 201
                                                                                                STASH=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$ROOT" "direct" ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString config.personal.current-time ) ) ) ] ( builtins.map builtins.toJSON resource.path ) ] ) } ;
                                                                                                LINKED=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$ROOT" "linked" ] ( builtins.map builtins.toJSON resource.path ) ] ) }
                                                                                                mkdir --parents "$STASH/mount"
                                                                                                if [ -f "$STASH/failure.yaml" ]
                                                                                                then
                                                                                                    yq --yaml-output "." "$STASH/failure.yaml" >&2
                                                                                                    rm "$ROOT/lock"
                                                                                                    flock -u 201
                                                                                                    exit 64
                                                                                                elif [ -f "$STASH/success.yaml" ]
                                                                                                then
                                                                                                    mkdir --parents "$LINKED"
                                                                                                    ${ builtins.concatStringsSep "\n" ( builtins.map ( output : ''if ! ln --symbolic "$STASH/mount/${ output }" "$LINKED/${ output }" ; then ${ yaml 6079 } && rm "$ROOT/lock" && flock -u 201 && exit 64 ; fi'' ) resource.outputs ) }
                                                                                                    rm "$ROOT/lock"
                                                                                                    flock -u 201
                                                                                                    exit 0
                                                                                                else
                                                                                                    ${ builtins.concatStringsSep "" ( builtins.map ( dependency : builtins.concatStringsSep "\n" ( output : ''if [ ! -e "${ builtins.concatStringsSep "/" [ "$LINKED" dependency output ] }" ] ; then ${ yaml 13579 } && rm "$ROOT/lock" && flock -u 201 && exit 64'' ) ( builtins.getAttr dependency outputs ) ) resource.dependencies ) }
                                                                                                    if ${ init }/bin/init > "$STASH/standard-output" 2> "$STASH/standard-error"
                                                                                                    then
                                                                                                        if [ -s "$STASH/standard-error" ]
                                                                                                        then
                                                                                                            ${ yaml 20189 }
                                                                                                            rm "$ROOT/lock"
                                                                                                            flock -u 201
                                                                                                            exit 64
                                                                                                        elif [ "${ builtins.concatStringsSep "/n" resource.outputs }" != "$( find "$STASH/mount" -mindepth 1 -maxdepth 1 | sort )" ]
                                                                                                        then
                                                                                                            ${ yaml 850 }
                                                                                                            rm "$ROOT/lock"
                                                                                                            flock -u 201
                                                                                                            exit 64
                                                                                                        else
                                                                                                            mkdir --parents "$LINKED"
                                                                                                            ${ builtins.concatStringsSep "\n" ( builtins.map ( output : ''if ! ln --symbolic "$STASH/mount/${ output }" "$LINKED/${ output } ; then ${ yaml 25247 } && rm "$ROOT/lock" && flock -u 201 && exit 64 ; fi'' ) resource.outputs ) }
                                                                                                            ${ yaml 0 }
                                                                                                            rm "$ROOT/lock"
                                                                                                            flock -u 201
                                                                                                            exit 0
                                                                                                        fi
                                                                                                    else
                                                                                                        ${ yaml 3095 }
                                                                                                        yq --yaml-output "." "$STASH/failure.yaml"
                                                                                                        rm "$ROOT/lock"
                                                                                                        flock -u 201
                                                                                                        exit 64
                                                                                                    fi
                                                                                                fi
                                                                                            '' ;
                                                                            } ;
                                                                    teardown =
                                                                        pkgs.writeShellApplication
                                                                            {
                                                                                name = "setup" ;
                                                                                runtimeInputs = [ ] ;
                                                                                text =
                                                                                    ''
                                                                                    '' ;
                                                                            } ;
                                                                } ;
                                                in builtins.map mapper points ;
                                        setup =
                                            pkgs.writeShellApplication
                                                {
                                                    name = "setup" ;
                                                    runtimeInputs = [ ] ;
                                                    text = builtins.concatStringsSep "\n" ( builtins.map ( script : ''${ script.setup }/bin/setup'' ) ( builtins.sort ( a : b : a.index < b.index ) scripts ) ) ;
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
                                                        systemd =
                                                            {
                                                                services =
                                                                    {
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
                                                                        setup
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
