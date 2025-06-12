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
                                                        mapper = resource : { name = resource.name ; value = builtins.concatLists [ [ ( builtins.trace "5664e376-4785-464f-a6bc-7f9a8b5b405f" resource.dependencies ) ] ( builtins.map ( dependency : builtins.getAttr dependency ( builtins.trace "bb8425d8-6929-45e5-979e-802a6f30d743" dependencies ) ) ( builtins.trace "b5c0b819-6169-45fd-a938-7f8fd142f63e" resource.dependencies ) ) ] ; } ;
                                                        in builtins.map mapper points ;
                                                in builtins.listToAttrs list ;
                                        outputs =
                                            let
                                                list =
                                                    let
                                                        mapper = resource : builtins.trace "28134a56-4acd-4c66-9a0a-fcc5dc9a645c" { name = resource.name ; value = resource.outputs ; } ;
                                                        in builtins.map mapper points ;
                                                in builtins.trace "b9cc6cbd-a6c2-40f2-bef5-32288f13c3cd ${ builtins.typeOf points }" ( builtins.listToAttrs list ) ;
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
                                                                                                lambda = path : value : [ ( builtins.concatStringsSep "/" ( builtins.map builtins.toJSON path ) ) ] ;
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
                                                                                    in builtins.map ( dependency : if builtins.elem dependency list then dependency else builtins.throw "dependency ${ builtins.toString dependency } is not correct." ) ( ( builtins.trace "f5f8958b-9efc-4d38-9ff7-9d8d0b939e11" dependencies ) tree ) ;
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
                                                        personal =
                                                            {
                                                                dot-gnupg =
                                                                    ignore :
                                                                        {
                                                                            init-packages = pkgs : [ pkgs.age pkgs.gnupg ] ;
                                                                            init-script =
                                                                                ''
                                                                                    export GNUPGHOME=/mount/.gpg
                                                                                    mkdir "$GNUPGHOME"
                                                                                    age --decrypt --identity ${ config.personal.agenix } --output /work/secret-keys.asc ${ secrets }/secret-keys.asc.age
                                                                                    gpg --batch --yes --homedir "$GNUPGHOME" --import /work/secret-keys.asc
                                                                                    age --decrypt --identity ${ config.personal.agenix } --output /work/ownertrust.asc ${ secrets }/ownertrust.asc.age
                                                                                    gpg --batch --yes --homedir "$GNUPGHOME" --import-ownertrust /work/ownertrust.asc
                                                                                    gpg --batch --yes --homedir "$GNUPGHOME"" --update-trust-db
                                                                                '' ;
                                                                            outputs = [ ".gpg" ] ;
                                                                        } ;
                                                            } ;
                                                        scratch =
                                                            {
                                                                one =
                                                                    ignore :
                                                                        {
                                                                            init-packages = pkgs : [ pkgs.coreutils ] ;
                                                                            init-script = "echo one > /mount/one" ;
                                                                            outputs = [ "one" ] ;
                                                                        } ;
                                                                two =
                                                                    ignore :
                                                                        {
                                                                            dependencies = tree : [ tree.scratch.one ] ;
                                                                            init-packages = pkgs : [ pkgs.coreutils ] ;
                                                                            init-script = "ln --symbolic /home/emory/stash/linked/scratch/one/one /mount/two" ;
                                                                            outputs = [ "two" ] ;
                                                                        } ;
                                                            } ;
                                                    } ;
                                        scripts =
                                            let
                                                mapper =
                                                    resource :
                                                        let
                                                            dependencies-transitive-closure = builtins.getAttr resource.name ( builtins.trace "c6103a43-4f4e-43b1-b020-4c00ea15db17" dependencies ) ;
                                                            index =
                                                                let
                                                                    find = builtins.elemAt filtered 0 ;
                                                                    filtered = builtins.filter ( dependency : dependency.value.name == resource.name ) indexed ;
                                                                    indexed = builtins.genList ( index : { index = index ; value = builtins.elemAt sorted index ; } ) ( builtins.length sorted ) ;
                                                                    listed = builtins.attrValues ( builtins.mapAttrs ( name : value : { name = name ; value = value ; } ) ( builtins.trace "f5a4b8a4-1007-42b6-9143-6d8e96f524c7" dependencies ) ) ;
                                                                    sorted = builtins.sort ( a : b : if ( builtins.length a.value ) < ( builtins.length b.value ) then true else if ( builtins.length a.value ) > ( builtins.length b.value ) then false else if a.name < b.name then true else if a.name > b.name then false else builtins.throw "not meets" ) listed ;
                                                                    in find.index ;
                                                            in
                                                                {
                                                                    index = index ;
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
                                                                                                    extraBwrapArgs =
                                                                                                        [
                                                                                                            "--bind $MOUNT /mount"
                                                                                                            "--ro-bind $LINK /home/${ config.personal.name }/${ config.personal.stash }/linked"
                                                                                                            "--tmpfs /work"
                                                                                                        ] ;
                                                                                                    name = "init" ;
                                                                                                    runScript =
                                                                                                        let
                                                                                                            init = pkgs.writeShellApplication { name = "init" ; text = resource.init-script ; } ;
                                                                                                            in "${ init }/bin/init" ;
                                                                                                    targetPkgs = resource.init-packages ;
                                                                                                } ;
                                                                                        yaml =
                                                                                            code :
                                                                                                if code == 32126 then
                                                                                                    ''jq --null-input --arg CODE "${ builtins.toString code }" --arg DEPENDENCIES '${ builtins.concatStringsSep "," resource.dependencies }' --arg EXPECTED "${ builtins.concatStringsSep "\n" resource.outputs }" --arg INDEX ${ builtins.toString index } --arg INIT_SCRIPT "${ resource.init-script }" --arg OBSERVED "$( find "$STASH/mount" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort )" --arg OUTPUT "${ builtins.concatStringsSep "," resource.outputs }" --arg RELEASE_SCRIPT "${ resource.release-script }" '{ "code" : $CODE , "dependencies" : $DEPENDENCIES , "expected" : $EXPECTED , "index" : $INDEX , "observed" : $OBSERVED , "init-script" : $INIT_SCRIPT , "release-script" : $RELEASE_SCRIPT }' | yq --yaml-output "." > "$STASH/init.${ if code == 0 then "success" else "failure" }.yaml"''
                                                                                                else
                                                                                                    ''jq --null-input --arg CODE "${ builtins.toString code }" --arg DEPENDENCIES '${ builtins.concatStringsSep "," resource.dependencies }' --arg EXPECTED "${ builtins.concatStringsSep "\n" resource.outputs }" --arg INDEX ${ builtins.toString index } --arg INIT_SCRIPT "${ resource.init-script }" --arg OBSERVED "$( find "$STASH/mount" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort )" --arg OUTPUT "${ builtins.concatStringsSep "," resource.outputs }" --arg RELEASE_SCRIPT "${ resource.release-script }" --arg STANDARD_ERROR "$( cat "$STASH/init.standard-error" )" --arg STANDARD_OUTPUT "$( cat "$STASH/init.standard-output" )" --arg STATUS "$?" '{ "code" : $CODE , "dependencies" : $DEPENDENCIES , "expected" : $EXPECTED , "index" : $INDEX , "observed" : $OBSERVED , "init-script" : $INIT_SCRIPT , "release-script" : $RELEASE_SCRIPT ,"standard-error" : $STANDARD_ERROR , "standard-output" : $STANDARD_OUTPUT , "status" : $STATUS }' | yq --yaml-output "." > "$STASH/init.${ if code == 0 then "success" else "failure" }.yaml"'' ;
                                                                                        in
                                                                                            ''
                                                                                                ROOT=${ builtins.concatStringsSep "/" [ "" "home" config.personal.name config.personal.stash ] } ;
                                                                                                mkdir --parents "$ROOT"
                                                                                                exec 201> "$ROOT/lock"
                                                                                                flock -x 201
                                                                                                STASH=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$ROOT" "direct" ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString config.personal.current-time ) ) ) ] ( builtins.map builtins.toJSON resource.path ) ] ) } ;
                                                                                                LINKED=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$ROOT" "linked" ] ( builtins.map builtins.toJSON resource.path ) ] ) }
                                                                                                export MOUNT="$STASH/mount"
                                                                                                mkdir --parents "$MOUNT"
                                                                                                if [ -f "$STASH/init.failure.yaml" ]
                                                                                                then
                                                                                                    yq --yaml-output "." "$STASH/init.failure.yaml" >&2
                                                                                                    rm "$ROOT/lock"
                                                                                                    flock -u 201
                                                                                                    exit 64
                                                                                                elif [ -f "$STASH/init.success.yaml" ]
                                                                                                then
                                                                                                    mkdir --parents "$LINKED"
                                                                                                    # FIXME
                                                                                                    rm "$ROOT/lock"
                                                                                                    flock -u 201
                                                                                                    exit 0
                                                                                                else
                                                                                                    export LINK="$ROOT/linked"
                                                                                                    mkdir --parents "$LINKED"
                                                                                                    # FIXME
                                                                                                    if ${ init }/bin/init > "$STASH/init.standard-output" 2> "$STASH/init.standard-error"
                                                                                                    then
                                                                                                        if [ -s "$STASH/init.standard-error" ]
                                                                                                        then
                                                                                                            ${ yaml 20189 }
                                                                                                            yq --yaml-output "$STASH/init.failure.yaml" >&2
                                                                                                            rm "$ROOT/lock"
                                                                                                            flock -u 201
                                                                                                            exit 64
                                                                                                        elif [ "${ builtins.concatStringsSep "/n" resource.outputs }" != "$( find "$STASH/mount" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort )" ]
                                                                                                        then
                                                                                                            ${ yaml 850 }
                                                                                                            yq --yaml-output "$STASH/init.failure.yaml" >&2
                                                                                                            rm "$ROOT/lock"
                                                                                                            flock -u 201
                                                                                                            exit 64
                                                                                                        else
                                                                                                            mkdir --parents "$LINKED"
                                                                                                            ${ builtins.concatStringsSep "\n" ( builtins.map ( output : ''if ! ln --symbolic "$STASH/mount/${ output }" "$LINKED/${ output }" ; then ${ yaml 25247 } && yq --yaml-output "$STASH/failure.yaml" && rm "$ROOT/lock" && flock -u 201 && exit 64 ; fi'' ) resource.outputs ) }
                                                                                                            if ! rm --force release.standard-error release.standard-output release-failure.yaml release-success.yaml
                                                                                                            then
                                                                                                                ${ yaml 19035 }
                                                                                                                rm "$ROOT/lock"
                                                                                                                flock -u 201
                                                                                                                exit 64
                                                                                                            fi
                                                                                                            ${ yaml 0 }
                                                                                                            rm "$ROOT/lock"
                                                                                                            flock -u 201
                                                                                                            exit 0
                                                                                                        fi
                                                                                                    else
                                                                                                        ${ yaml 3095 }
                                                                                                        yq --yaml-output "." "$STASH/init.failure.yaml"
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
                                                                                name = "teardown" ;
                                                                                runtimeInputs = [ pkgs.coreutils pkgs.findutils pkgs.flock pkgs.jq pkgs.yq ] ;
                                                                                text =
                                                                                    let
                                                                                        release =
                                                                                            pkgs.buildFHSUserEnv
                                                                                                {
                                                                                                    extraBwrapArgs =
                                                                                                        [
                                                                                                            "--ro-bind $LINK /home/${ config.personal.name }/${ config.personal.stash }/linked"
                                                                                                            "--tmpfs /work"
                                                                                                        ] ;
                                                                                                    name = "release" ;
                                                                                                    runScript = resource.release-script ;
                                                                                                    targetPkgs = resource.release-packages;
                                                                                                } ;
                                                                                        yaml =
                                                                                            code :
                                                                                                if code == 31314 then
                                                                                                    ''jq --null-input --arg CODE "${ builtins.toString code }" --arg DEPENDENCIES '${ builtins.concatStringsSep "," resource.dependencies }' --arg EXPECTED "${ builtins.concatStringsSep "\n" resource.outputs }" --arg INDEX ${ builtins.toString index } --arg INIT_SCRIPT "${ resource.init-script }" --arg OBSERVED "$( find "$STASH/mount" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort )" --arg OUTPUT "${ builtins.concatStringsSep "," resource.outputs }" --arg RELEASE_SCRIPT "${ resource.release-script }" '{ "code" : $CODE , "dependencies" : $DEPENDENCIES , "expected" : $EXPECTED , "index" : $INDEX , "observed" : $OBSERVED , "init-script" : $INIT_SCRIPT , "release-script" : $RELEASE_SCRIPT }' | yq --yaml-output "." > "$STASH/release.${ if code == 0 then "success" else "failure" }.yaml"''
                                                                                                else
                                                                                                    ''jq --null-input --arg CODE "${ builtins.toString code }" --arg DEPENDENCIES '${ builtins.concatStringsSep "," resource.dependencies }' --arg EXPECTED "${ builtins.concatStringsSep "\n" resource.outputs }" --arg INDEX ${ builtins.toString index } --arg INIT_SCRIPT "${ resource.init-script }" --arg OBSERVED "$( find "$STASH/mount" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort )" --arg OUTPUT "${ builtins.concatStringsSep "," resource.outputs }" --arg RELEASE_SCRIPT "${ resource.release-script }" --arg STANDARD_ERROR "$( cat "$STASH/release.standard-error" )" --arg STANDARD_OUTPUT "$( cat "$STASH/release.standard-output" )" --arg STATUS "$?" '{ "code" : $CODE , "dependencies" : $DEPENDENCIES , "expected" : $EXPECTED , "index" : $INDEX , "observed" : $OBSERVED , "init-script" : $INIT_SCRIPT , "release-script" : $RELEASE_SCRIPT ,"standard-error" : $STANDARD_ERROR , "standard-output" : $STANDARD_OUTPUT , "status" : $STATUS }' | yq --yaml-output "." > "$STASH/release.${ if code == 0 then "success" else "failure" }.yaml"'' ;
                                                                                        in
                                                                                    ''
                                                                                        ROOT=${ builtins.concatStringsSep "/" [ "" "home" config.personal.name config.personal.stash ] } ;
                                                                                        if [ -d "$ROOT" ]
                                                                                        then
                                                                                            exec 201> "$ROOT/lock"
                                                                                            flock -x 201
                                                                                            STASH=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$ROOT" "direct" ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString config.personal.current-time ) ) ) ] ( builtins.map builtins.toJSON resource.path ) ] ) } ;
                                                                                            if [ -d "$STASH" ]
                                                                                            then
                                                                                                if [ -f "$STASH/release.failure.yaml" ]
                                                                                                then
                                                                                                    yq --yaml-output "." "$STASH/release.failure.yaml"
                                                                                                    rm "$ROOT/lock"
                                                                                                    flock -u 201
                                                                                                    exit 64
                                                                                                elif [ -f "$STASH/release.success.yaml" ]
                                                                                                then
                                                                                                    rm "$ROOT/lock"
                                                                                                    flock -u 201
                                                                                                    exit 0
                                                                                                else
                                                                                                    # FIXME
                                                                                                    export LINK="$ROOT/linked"
                                                                                                    if ${ release }/bin/release > "$STASH/release.standard-output" 2> "$STASH/release.standard-error"
                                                                                                    then
                                                                                                        if ! rm --force "$STASH/init.standard-error" "$STASH/init.standard-output" "$STASH/init.failure.yaml" "$STASH/init.success.yaml"
                                                                                                        then
                                                                                                            ${ yaml 30292 }
                                                                                                            yq --yaml-output "." "$STASH/release.failure.yaml" >&2
                                                                                                            rm "$ROOT/lock"
                                                                                                            flock -u 201
                                                                                                            exit 64
                                                                                                        fi
                                                                                                        LINKED=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$ROOT" "linked" ] ( builtins.map builtins.toJSON resource.path ) ] ) }
                                                                                                        ${ builtins.concatStringsSep "\n" ( builtins.map ( output : ''if [ "$STASH/mount/${ output }" == "$( readlink "$LINKED/${ output }" )" ] ; then rm "$LINKED/${ output }" ; fi'' ) resource.outputs ) }
                                                                                                        ${ yaml 0 }
                                                                                                        rm "$ROOT/lock"
                                                                                                        flock -u 201
                                                                                                        exit 0
                                                                                                    else
                                                                                                        ${ yaml 31504 }
                                                                                                        yq --yaml-output "." "$STASH/release.failure.yaml" >&2
                                                                                                        rm "$ROOT/lock"
                                                                                                        flock -u 201
                                                                                                        exit 64
                                                                                                    fi
                                                                                                fi
                                                                                            fi
                                                                                            rm "$ROOT/lock"
                                                                                            flock -u 201
                                                                                        fi
                                                                                    '' ;
                                                                            } ;
                                                                } ;
                                                in builtins.map mapper points ;
                                        setup =
                                            pkgs.writeShellApplication
                                                {
                                                    name = "setup" ;
                                                    runtimeInputs = [ pkgs.coreutils ] ;
                                                    text =
                                                        ''
                                                            rm --recursive --force /home/${ config.personal.name }/${ config.personal.stash }/linked
                                                            ${ builtins.concatStringsSep "\n" ( builtins.map ( script : ''${ script.setup }/bin/setup'' ) ( builtins.sort ( a : b : a.index < b.index ) scripts ) ) }
                                                            if [ ! -e /home/${ config.personal.name }/${ config.personal.stash }/direct/${ builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString config.personal.current-time ) ) }/teardown ]
                                                            then
                                                                ln --symbolic ${ teardown }/bin/teardown /home/${ config.personal.name }/${ config.personal.stash }/direct/${ builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString config.personal.current-time ) ) }/teardown
                                                            fi
                                                        '' ;
                                                } ;
                                        teardown =
                                            pkgs.writeShellApplication
                                                {
                                                    name = "teardown" ;
                                                    runtimeInputs = [ pkgs.coreutils ] ;
                                                    text =
                                                        ''
                                                            ${ builtins.concatStringsSep "\n" ( builtins.map ( script : ''${ script.teardown }/bin/teardown'' ) ( builtins.sort ( a : b : a.index > b.index ) scripts ) ) }
                                                        '' ;
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
                                                                tlp =
                                                                    {
                                                                        enable = true;
                                                                        settings =
                                                                            {
                                                                                START_CHARGE_THRESH_BAT0 = 40 ;
                                                                                STOP_CHARGE_THRESH_BAT0 = 80 ;
                                                                            } ;
                                                                    } ;
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
                                                                        stash-cleanup =
                                                                            {
                                                                                after = [ "network.target" ] ;
                                                                                serviceConfig =
                                                                                    {
                                                                                        ExecStart =
                                                                                            let
                                                                                                script =
                                                                                                    pkgs.writeShellApplication
                                                                                                        {
                                                                                                            name = "script" ;
                                                                                                            runtimeInputs = [ pkgs.coreutils pkgs.findutils ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    NOW="$( date +%s )"
                                                                                                                    RECYCLE_BIN="$( mktemp --directory )"
                                                                                                                    find /home/${ config.personal.name }/${ config.personal.stash }/direct -mindepth 1 -maxdepth 1 -type d ! -name ${ builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString config.personal.current-time ) ) } | while read -r DIRECTORY
                                                                                                                    do
                                                                                                                        if [ -L "$DIRECTORY/teardown" ] && [ -x "DIRECTORY/teardown" ]
                                                                                                                        then
                                                                                                                            "$DIRECTORY/teardown"
                                                                                                                        fi
                                                                                                                        if [ -f "$DIRECTORY/release.success.yaml" ]
                                                                                                                        then
                                                                                                                            LAST_ACCESS="$( stat "$DIRECTORY/release.success.yaml" --format "%X" )"
                                                                                                                            if [ "$(( "$NOW" - "$LAST_ACCESS" ))" -gt ${ builtins.toString config.personal.stale } ]
                                                                                                                            then
                                                                                                                                mv "$DIRECTORY" "$RECYCLE_BIN"
                                                                                                                            fi
                                                                                                                        fi
                                                                                                                    done
                                                                                                                '' ;
                                                                                                        } ;
                                                                                                in "${ script }/bin/script" ;
                                                                                        Owner = config.personal.name ;
                                                                                    } ;
                                                                                wantedBy = [ "multi-user.target" ] ;
                                                                            } ;
                                                                    } ;
                                                                timers =
                                                                    {
                                                                        stash-cleanup =
                                                                            {
                                                                                timerConfig =
                                                                                    {
                                                                                        OnCalendar = "daily" ;
                                                                                    } ;
                                                                                wantedBy = [ "timers.target" ] ;
                                                                            } ;
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
                                                                        teardown
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
                                                                stale = lib.mkOption { default = 60 * 60 * 24 * 7 * 2 ; type = lib.types.int ; } ;
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
