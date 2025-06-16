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
                                                        mapper = resource : { name = resource.name ; value = builtins.concatLists [ [ resource.dependencies ] ( builtins.map ( dependency : builtins.getAttr dependency dependencies ) resource.dependencies ) ] ; } ;
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
                                                                        dependencies ? x : { } ,
                                                                        init-packages ? pkgs : [ ] ,
                                                                        init-script ? x : "" ,
                                                                        outputs ? [ ] ,
                                                                        release-packages ? pkgs : [ ] ,
                                                                        release-script ? x : ""
                                                                    } :
                                                                        let
                                                                            list =
                                                                                visitor.lib.implementation
                                                                                    {
                                                                                        lambda = path : value : [ ( builtins.concatStringsSep "/" ( builtins.map builtins.toJSON path ) ) ] ;
                                                                                        list = path : list : builtins.concatLists list ;
                                                                                        set = path : set : builtins.concatLists ( builtins.attrValues set ) ;
                                                                                    }
                                                                                    resources ;
                                                                            set = dependencies tree ;
                                                                            strings = builtins.attrValues set ;
                                                                            tree =
                                                                                visitor.lib.implementation
                                                                                    {
                                                                                        lambda = path : value : builtins.concatStringsSep "/" ( builtins.map builtins.toJSON path ) ;
                                                                                    }
                                                                                    resources ;
                                                                            validated = builtins.map ( dependency : if builtins.elem  dependency list then dependency else builtins.throw "depdency ${ dependency } is not correct." ) strings ;
                                                                            dependencies_ = validated ;
                                                                            dependencies__ = set ;
                                                                            tree2 =
                                                                                visitor.lib.implementation
                                                                                    {
                                                                                        lambda = path : value : dependency : builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" config.personal.name config.personal.stash "direct" ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString config.personal.current-time ) ) ) ] ( builtins.map builtins.toJSON path ) [ "mount" dependency ] ] ) ;
                                                                                    }
                                                                                    resources ;
                                                                            outputs_ =
                                                                                builtins.listToAttrs
                                                                                    (
                                                                                        builtins.map
                                                                                            (
                                                                                                output :
                                                                                                    {
                                                                                                        name = output ;
                                                                                                        value =
                                                                                                            builtins.concatStringsSep
                                                                                                                "/"
                                                                                                                (
                                                                                                                    builtins.concatLists
                                                                                                                        [
                                                                                                                            [
                                                                                                                                ""
                                                                                                                                "home"
                                                                                                                                config.personal.name
                                                                                                                                config.personal.stash
                                                                                                                                "direct"
                                                                                                                                ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString config.personal.current-time ) ) )
                                                                                                                            ]
                                                                                                                            ( builtins.map builtins.toJSON path )
                                                                                                                            [
                                                                                                                                "mount"
                                                                                                                                output
                                                                                                                            ]
                                                                                                                        ]
                                                                                                                ) ;
                                                                                                    }
                                                                                            )
                                                                                            outputs
                                                                                    ) ;
                                                                            in
                                                                                {
                                                                                    dependencies = dependencies_ ;
                                                                                    dependencies__ = dependencies__ ;
                                                                                    init-packages = init-packages ;
                                                                                    init-script = init-script { outputs = outputs_ ; tree = tree2 ; } ;
                                                                                    name = builtins.concatStringsSep "/" ( builtins.map builtins.toJSON path ) ;
                                                                                    outputs = builtins.sort builtins.lessThan outputs ;
                                                                                    outputs_ = outputs_ ;
                                                                                    path = path ;
                                                                                    release-packages = release-packages ;
                                                                                    release-script = release-script { outputs = outputs_ ; tree = tree2 ; } ;
                                                                                    tree2 = tree2 ;
                                                                                } ;
                                                                in [ ( identity ( value null ) ) ] ;
                                                    list = path : list : builtins.concatLists list ;
                                                    null = path : value : [ ] ;
                                                    set = path : set : builtins.concatLists ( builtins.attrValues set ) ;
                                                }
                                                resources ;
                                        resources =
                                            let
                                                post-commit =
                                                    pkgs.writeShellApplication
                                                        {
                                                            name = "post-commit" ;
                                                            runtimeInputs = [ pkgs.coreutils pkgs.git ] ;
                                                            text =
                                                                ''
                                                                    while ! git push origin HEAD
                                                                    do
                                                                        sleep 1s
                                                                    done
                                                                '' ;
                                                        } ;
                                                ssh-command =
                                                    configuration-file :
                                                        pkgs.writeShellApplication
                                                            {
                                                                name = "ssh" ;
                                                                runtimeInputs = [ pkgs.openssh ] ;
                                                                text =
                                                                    ''
                                                                        exec ssh -F ${ configuration-file } $@
                                                                    '' ;
                                                        } ;
                                                in
                                                    {
                                                        couple = { } ;
                                                        family = { } ;
                                                        personal =
                                                            {
                                                                dot-gnupg =
                                                                    ignore :
                                                                        {
                                                                            init-packages = pkgs : [ pkgs.age pkgs.coreutils pkgs.gnupg ] ;
                                                                            init-script =
                                                                                { ... } :
                                                                                    ''
                                                                                        export GNUPGHOME=/mount/.gnupg
                                                                                        mkdir "$GNUPGHOME"
                                                                                        chmod 0700 "$GNUPGHOME"
                                                                                        age --decrypt --identity ${ config.personal.agenix } --output /work/secret-keys.asc ${ secrets }/secret-keys.asc.age
                                                                                        gpg --batch --yes --homedir "$GNUPGHOME" --import "/work/secret-keys.asc" 2>&1
                                                                                        age --decrypt --identity ${ config.personal.agenix } --output /work/ownertrust.asc ${ secrets }/ownertrust.asc.age
                                                                                        gpg --batch --yes --homedir "$GNUPGHOME" --import-ownertrust /work/ownertrust.asc 2>&1
                                                                                        gpg --batch --yes --homedir "$GNUPGHOME" --update-trustdb 2>&1
                                                                                    '' ;
                                                                            outputs = [ ".gnupg" ] ;
                                                                        } ;
                                                                dot-ssh =
                                                                    {
                                                                        boot =
                                                                            ignore :
                                                                                {
                                                                                    init-packages = pkgs : [ pkgs.age ] ;
                                                                                    init-script =
                                                                                        { outputs , tree } :
                                                                                            ''
                                                                                                age --decrypt --identity ${ config.personal.agenix } ${ secrets }/dot-ssh/boot/identity.asc.age > /mount/identity
                                                                                                age --decrypt --identity ${ config.personal.agenix } ${ secrets }/dot-ssh/boot/known-hosts.asc.age > /mount/known-hosts
                                                                                                cat > /mount/config <<EOF
                                                                                                Host github.com
                                                                                                IdentityFile ${ outputs.identity }
                                                                                                UserKnownHostsFile ${ outputs.known-hosts }
                                                                                                StrictHostKeyChecking true
                                                                                                EOF
                                                                                                chmod 0400 /mount/identity /mount/known-hosts /mount/config
                                                                                            '' ;
                                                                                    outputs = [ "config" "identity" "known-hosts" ] ;
                                                                                } ;
                                                                        viktor =
                                                                            ignore :
                                                                                {
                                                                                    init-packages = pkgs : [ pkgs.age ] ;
                                                                                    init-script =
                                                                                        { outputs , tree } :
                                                                                            ''
                                                                                                age --decrypt --identity ${ config.personal.agenix } ${ secrets }/dot-ssh/viktor/identity.asc.age > /mount/identity
                                                                                                age --decrypt --identity ${ config.personal.agenix } ${ secrets }/dot-ssh/viktor/known-hosts.asc.age > /mount/known-hosts
                                                                                                cat > /mount/config <<EOF
                                                                                                Host github.com
                                                                                                IdentityFile ${ outputs.identity }
                                                                                                UserKnownHostsFile ${ outputs.known-hosts }
                                                                                                StrictHostKeyChecking true
                                                                                                EOF
                                                                                                chmod 0400 /mount/identity /mount/known-hosts /mount/config
                                                                                            '' ;
                                                                                    outputs = [ "config" "identity" "known-hosts" ] ;
                                                                                } ;
                                                                    } ;
                                                                repository =
                                                                    {
                                                                        personal =
                                                                            ignore :
                                                                                {
                                                                                    dependencies = tree : { dot-ssh = tree.personal.dot-ssh.viktor ; } ;
                                                                                    init-packages = pkgs : [ pkgs.coreutils pkgs.git ] ;
                                                                                    init-script =
                                                                                        { ... } :
                                                                                            ''
                                                                                                export GIT_DIR=/mount/git
                                                                                                export GIT_WORK_TREE=/mount/work-tree
                                                                                                mkdir "$GIT_DIR"
                                                                                                mkdir "$GIT_WORK_TREE"
                                                                                                git init 2>&1

                                                                                            '' ;
                                                                                    outputs = [ "git" "work-tree" ] ;
                                                                                } ;
                                                                    } ;
                                                            } ;
                                                        scratch =
                                                            {
                                                                one =
                                                                    ignore :
                                                                        {
                                                                            init-packages = pkgs : [ pkgs.coreutils ] ;
                                                                            init-script = { ... } : "echo one > /mount/one" ;
                                                                            outputs = [ "one" ] ;
                                                                        } ;
                                                                two =
                                                                    ignore :
                                                                        {
                                                                            dependencies = tree : { one = tree.scratch.one ; } ;
                                                                            init-packages = pkgs : [ pkgs.coreutils ] ;
                                                                            init-script = { outputs , tree } : ''ln --symbolic "/home/emory/stash/direct/$UNIQ_TOKEN/scratch/one/mount/one" /mount/two'' ;
                                                                            outputs = [ "two" ] ;
                                                                        } ;
                                                            } ;
                                                    } ;
                                        scripts =
                                            let
                                                mapper =
                                                    resource :
                                                        let
                                                            dependencies-transitive-closure = builtins.getAttr resource.name dependencies ;
                                                            index =
                                                                let
                                                                    find = builtins.elemAt filtered 0 ;
                                                                    filtered = builtins.filter ( dependency : dependency.value.name == resource.name ) indexed ;
                                                                    indexed = builtins.genList ( index : { index = index ; value = builtins.elemAt sorted index ; } ) ( builtins.length sorted ) ;
                                                                    listed = builtins.attrValues ( builtins.mapAttrs ( name : value : { name = name ; value = value ; } ) dependencies ) ;
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
                                                                                                            "--ro-bind /home/${ config.personal.name }/${ config.personal.stash }/direct /home/${ config.personal.name }/${ config.personal.stash }/direct"
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
                                                                                                    ''jq --null-input --arg CODE "${ builtins.toString code }" --arg DEPENDENCIES '${ builtins.concatStringsSep "," resource.dependencies }' --arg EXPECTED "${ builtins.concatStringsSep "\n" resource.outputs }" --arg INDEX ${ builtins.toString index } --arg INIT_SCRIPT "${ pkgs.writeShellApplication { name = "init" ; text = resource.init-script ; } }" --arg OBSERVED "$( find "$STASH/mount" -mindepth 1 -maxdepth 1 -exec basename {} \; | LC_ALL=C sort )" --arg OUTPUT "${ builtins.concatStringsSep "," resource.outputs }" --arg RELEASE_SCRIPT "${ pkgs.writeShellApplication { name = "release" ; text = resource.release-script ; } }" '{ "dependencies" : $DEPENDENCIES , "expected" : $EXPECTED , "index" : $INDEX , "observed" : $OBSERVED , "init-script" : $INIT_SCRIPT , "release-script" : $RELEASE_SCRIPT }' | yq --yaml-output "." > "$STASH/init.${ if code == 0 then "success" else "failure" }.yaml"''
                                                                                                else
                                                                                                    ''jq --null-input --arg CODE "${ builtins.toString code }" --arg DEPENDENCIES '${ builtins.concatStringsSep "," resource.dependencies }' --arg EXPECTED "${ builtins.concatStringsSep "\n" resource.outputs }" --arg INDEX ${ builtins.toString index } --arg INIT_SCRIPT "${ pkgs.writeShellApplication { name = "init" ; text = resource.init-script ; } }" --arg OBSERVED "$( find "$STASH/mount" -mindepth 1 -maxdepth 1 -exec basename {} \; | LC_ALL=C sort )" --arg OUTPUT "${ builtins.concatStringsSep "," resource.outputs }" --arg RELEASE_SCRIPT "${ pkgs.writeShellApplication { name = "release" ; text = resource.release-script ; } }" --arg STANDARD_ERROR "$( cat "$STASH/init.standard-error" )" --arg STANDARD_OUTPUT "$( cat "$STASH/init.standard-output" )" --arg STATUS "$?" '{ "code" : $CODE , "dependencies" : $DEPENDENCIES , "expected" : $EXPECTED , "index" : $INDEX , "observed" : $OBSERVED , "init-script" : $INIT_SCRIPT , "release-script" : $RELEASE_SCRIPT ,"standard-error" : $STANDARD_ERROR , "standard-output" : $STANDARD_OUTPUT , "status" : $STATUS }' | yq --yaml-output "." > "$STASH/init.${ if code == 0 then "success" else "failure" }.yaml"'' ;
                                                                                        in
                                                                                            ''
                                                                                                ROOT=${ builtins.concatStringsSep "/" [ "" "home" config.personal.name config.personal.stash ] } ;
                                                                                                mkdir --parents "$ROOT"
                                                                                                exec 201> "$ROOT/lock"
                                                                                                flock -x 201
                                                                                                export UNIQ_TOKEN="${ builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString config.personal.current-time ) ) }"
                                                                                                STASH=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$ROOT" "direct" "$UNIQ_TOKEN" ] ( builtins.map builtins.toJSON resource.path ) ] ) } ;
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
                                                                                                    rm "$ROOT/lock"
                                                                                                    flock -u 201
                                                                                                    exit 0
                                                                                                else
                                                                                                    # FIXME VERIFY THE DEPENDENCIES HAVE BEEN MADE
                                                                                                    if ${ init }/bin/init > "$STASH/init.standard-output" 2> "$STASH/init.standard-error"
                                                                                                    then
                                                                                                        if [ -s "$STASH/init.standard-error" ]
                                                                                                        then
                                                                                                            ${ yaml 20189 }
                                                                                                            yq --yaml-output "." "$STASH/init.failure.yaml" >&2
                                                                                                            rm "$ROOT/lock"
                                                                                                            flock -u 201
                                                                                                            exit 64
                                                                                                        elif [ "${ builtins.concatStringsSep "\n" resource.outputs }" != "$( find "$STASH/mount" -mindepth 1 -maxdepth 1 -exec basename {} \; | LC_ALL=C sort )" ]
                                                                                                        then
                                                                                                            ${ yaml 850 }
                                                                                                            yq --yaml-output "." "$STASH/init.failure.yaml" >&2
                                                                                                            rm "$ROOT/lock"
                                                                                                            flock -u 201
                                                                                                            exit 64
                                                                                                        else
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
                                                                                                            "--ro-bind $LINK /home/${ config.personal.name }/${ config.personal.stash }/direct"
                                                                                                            "--tmpfs /work"
                                                                                                        ] ;
                                                                                                    name = "release" ;
                                                                                                    runScript = resource.release-script ;
                                                                                                    targetPkgs = resource.release-packages;
                                                                                                } ;
                                                                                        yaml =
                                                                                            code :
                                                                                                if code == 31314 then
                                                                                                    ''jq --null-input --arg CODE "${ builtins.toString code }" --arg DEPENDENCIES '${ builtins.concatStringsSep "," resource.dependencies }' --arg EXPECTED "${ builtins.concatStringsSep "\n" resource.outputs }" --arg INDEX ${ builtins.toString index } --arg INIT_SCRIPT "${ pkgs.writeShellApplication { name = "init" ; text = resource.init-script ; } }" --arg OBSERVED "$( find "$STASH/mount" -mindepth 1 -maxdepth 1 -exec basename {} \; | LC_ALL=C sort )" --arg OUTPUT "${ builtins.concatStringsSep "," resource.outputs }" --arg RELEASE_SCRIPT "${ pkgs.writeShellApplication { name = "release" ; text = resource.release-script ; } }" '{ "code" : $CODE , "dependencies" : $DEPENDENCIES , "expected" : $EXPECTED , "index" : $INDEX , "observed" : $OBSERVED , "init-script" : $INIT_SCRIPT , "release-script" : $RELEASE_SCRIPT }' | yq --yaml-output "." > "$STASH/release.${ if code == 0 then "success" else "failure" }.yaml"''
                                                                                                else
                                                                                                    ''jq --null-input --arg CODE "${ builtins.toString code }" --arg DEPENDENCIES '${ builtins.concatStringsSep "," resource.dependencies }' --arg EXPECTED "${ builtins.concatStringsSep "\n" resource.outputs }" --arg INDEX ${ builtins.toString index } --arg INIT_SCRIPT "${ pkgs.writeShellApplication { name = "init" ; text = resource.init-script ; } }" --arg OBSERVED "$( find "$STASH/mount" -mindepth 1 -maxdepth 1 -exec basename {} \; | LC_ALL=C sort )" --arg OUTPUT "${ builtins.concatStringsSep "," resource.outputs }" --arg RELEASE_SCRIPT "${ pkgs.writeShellApplication { name = "release" ; text = resource.release-script ; } }" --arg STANDARD_ERROR "$( cat "$STASH/release.standard-error" )" --arg STANDARD_OUTPUT "$( cat "$STASH/release.standard-output" )" --arg STATUS "$?" '{ "code" : $CODE , "dependencies" : $DEPENDENCIES , "expected" : $EXPECTED , "index" : $INDEX , "observed" : $OBSERVED , "init-script" : $INIT_SCRIPT , "release-script" : $RELEASE_SCRIPT ,"standard-error" : $STANDARD_ERROR , "standard-output" : $STANDARD_OUTPUT , "status" : $STATUS }' | yq --yaml-output "." > "$STASH/release.${ if code == 0 then "success" else "failure" }.yaml"'' ;
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
                                        password-store-extensions-dir =
                                            pkgs.stdenv.mkDerivation
                                                {
                                                    installPhase =
                                                        let
                                                            expiry =
                                                                pkgs.writeShellApplication
                                                                    {
                                                                        name = "expiry" ;
                                                                        runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.pass ] ;
                                                                        text =
                                                                            ''
                                                                                export PASSWORD_STORE_DIR="/home/${ config.personal.name }/${ config.personal.stash }/direct/$UNIQ_TOKEN/personal/pass/boot/work-tree"
                                                                                export GIT_WORK_TREE="/home/${ config.personal.name }/${ config.personal.stash }/direct/$UNIQ_TOKEN/personal/pass/boot/work-tree"
                                                                                export GIT_DIR="/home/${ config.personal.name }/${ config.personal.stash }/direct/$UNIQ_TOKEN/personal/pass/boot/git"
                                                                                YEAR_SECONDS=$((366 * 86400))
                                                                                TIMESTAMP=$(date +%s)

                                                                                # Get a list of all password keys tracked by Git
                                                                                git ls-tree -r --name-only HEAD | while IFS= read -r file; do
                                                                                  # Skip non-.gpg files
                                                                                  [[ "$file" != *.gpg ]] && continue

                                                                                  # Get the last commit timestamp for the file
                                                                                  last_commit_ts=$( git log -1 --format="%at" -- "$file" || echo 0)

                                                                                  # Compute the age
                                                                                  age=$((TIMESTAMP - last_commit_ts))

                                                                                  if (( age >= YEAR_SECONDS )); then
                                                                                    # Strip ".gpg" and print
                                                                                    key="${ builtins.concatStringsSep "" [ "$" "{" "file%.gpg}" "}" ] }"
                                                                                    echo "$key"
                                                                                  fi
                                                                                done
                                                                            '' ;
                                                                    } ;
                                                            phonetic =
                                                                pkgs.writeShellApplication
                                                                    {
                                                                        name = "phonetic" ;
                                                                        runtimeInputs = [ pkgs.coreutils ] ;
                                                                        text =
                                                                            ''
                                                                                declare -A NATO=(
                                                                                  [A]=ALPHA [B]=BRAVO [C]=CHARLIE [D]=DELTA [E]=ECHO [F]=FOXTROT
                                                                                  [G]=GOLF [H]=HOTEL [I]=INDIA [J]=JULIETT [K]=KILO [L]=LIMA
                                                                                  [M]=MIKE [N]=NOVEMBER [O]=OSCAR [P]=PAPA [Q]=QUEBEC [R]=ROMEO
                                                                                  [S]=SIERRA [T]=TANGO [U]=UNIFORM [V]=VICTOR [W]=WHISKEY [X]=XRAY
                                                                                  [Y]=YANKEE [Z]=ZULU
                                                                                )

                                                                                declare -A PHONETIC_LOWER=(
                                                                                  [a]=apple [b]=banana [c]=cherry [d]=date [e]=elder [f]=fig
                                                                                  [g]=grape [h]=hazel [i]=ivy [j]=juniper [k]=kiwi [l]=lemon
                                                                                  [m]=mango [n]=nectar [o]=olive [p]=peach [q]=quince [r]=raisin
                                                                                  [s]=strawberry [t]=tomato [u]=ugli [v]=vanilla [w]=walnut [x]=xigua
                                                                                  [y]=yam [z]=zucchini
                                                                                )

                                                                                declare -A DIGITS=(
                                                                                  [0]=Zero [1]=One [2]=Two [3]=Three [4]=Four
                                                                                  [5]=Five [6]=Six [7]=Seven [8]=Eight [9]=Nine
                                                                                )

                                                                                declare -A SYMBOLS=(
                                                                                  ['@']=At ['#']=Hash ['$']=Dollar ['%']=Percent ['&']=Ampersand
                                                                                  ['*']=Asterisk ['_']=Underscore ['-']=Dash ['=']=Equal ['+']=Plus
                                                                                  ['^']=Caret ['~']=Tilde ['|']=Pipe [':']=Colon [';']=Semicolon
                                                                                  [',']=Comma ['.']=Dot ['/']=ForwardSlash
                                                                                  ["\\"]=BackwardSlash
                                                                                  ["\'"]=SingleQuote
                                                                                  ['"']=DoubleQuote ['`']=Backtick ['<']=Less ['>']=Greater
                                                                                  ['?']=Question ['(']=LeftRoundBracket [')']=RightRoundBracket
                                                                                  ['[']=LeftSquareBracket [']']=RightSquareBracket
                                                                                  ['{']=LeftCurlyBracket ['}']=RightCurlyBracket
                                                                                )

                                                                                declare -A CONTROL=(
                                                                                  [0]=NULL [1]=STARTOFHEADING [2]=STARTOFTEXT [3]=ENDOFTEXT
                                                                                  [4]=ENDOFTRANSMISSION [5]=ENQUIRY [6]=ACKNOWLEDGE [7]=BELL
                                                                                  [8]=BACKSPACE [9]=TAB [10]=NEWLINE [11]=VERTICALTAB
                                                                                  [12]=FORMFEED [13]=CARRIAGERETURN [14]=SHIFTOUT [15]=SHIFTIN
                                                                                  [16]=DATALINKESCAPE [17]=DEVICECONTROL1 [18]=DEVICECONTROL2
                                                                                  [19]=DEVICECONTROL3 [20]=DEVICECONTROL4 [21]=NEGATIVEACKNOWLEDGE
                                                                                  [22]=SYNCHRONOUSIDLE [23]=ENDOFTRANSMITBLOCK [24]=CANCEL
                                                                                  [25]=ENDOFMEDIUM [26]=SUBSTITUTE [27]=ESCAPE [28]=FILESEPARATOR
                                                                                  [29]=GROUPSEPARATOR [30]=RECORDSEPARATOR [31]=UNITSEPARATOR
                                                                                  [127]=DELETE
                                                                                )

                                                                                output=()

                                                                                while IFS= read -r -n1 char; do
                                                                                  [[ -z "$char" ]] && continue
                                                                                  ascii=$(printf "%d" "'$char")

                                                                                  if [[ $ascii -lt 32 || $ascii -eq 127 ]]; then
                                                                                    raw="${ builtins.concatStringsSep "" [ "$" "{" "CONTROL[$ascii]:-UNKNOWN" "}" ] }"
                                                                                    transformed="${ builtins.concatStringsSep "" [ "$" "{" "raw:0:1," "}" ] }${ builtins.concatStringsSep "" [ "$" "{" "raw:1^^" "}" ] }"  # lowercase first letter, rest uppercase
                                                                                    output+=("$transformed")

                                                                                  elif [[ ${ builtins.concatStringsSep "" [ "$" "{" "char" "}" ] } =~ [A-Z] ]]; then
                                                                                    output+=("${ builtins.concatStringsSep "" [ "$" "{" "NATO[$char]:-UNKNOWN" "}" ] }")

                                                                                  elif [[ ${ builtins.concatStringsSep "" [ "$" "{" "char" "}" ] } =~ [a-z] ]]; then
                                                                                    output+=("${ builtins.concatStringsSep "" [ "$" "{" "PHONETIC_LOWER[$char]:-unknown" "}" ] }")

                                                                                  elif [[ ${ builtins.concatStringsSep "" [ "$" "{" "char" "}" ] } =~ [0-9] ]]; then
                                                                                    output+=("${ builtins.concatStringsSep "" [ "$" "{" "DIGITS[$char]:-Digit$char" "}" ] }")

                                                                                  elif [[ -n "${ builtins.concatStringsSep "" [ "$" "{" "SYMBOLS[$char]+set" "}" ] }" ]]; then
                                                                                    output+=("${ builtins.concatStringsSep "" [ "$" "{" "SYMBOLS[$char]" "}" ] }")

                                                                                  else
                                                                                    output+=("Unknown($ascii)")
                                                                                  fi
                                                                                done < <( pass show "$@" )

                                                                                echo OPEN
                                                                                printf "%s\n" "${ builtins.concatStringsSep "" [ "$" "{" "output[@]" "}" ] }"
                                                                                echo CLOSE
                                                                            '' ;
                                                                    } ;
                                                        warn =
                                                            pkgs.writeShellApplication
                                                                {
                                                                    name = "warn" ;
                                                                    runtimeInputs = [ pkgs.pass ] ;
                                                                    text =
                                                                        ''
                                                                            export GNUPGHOME="/home/${ config.personal.name }/${ config.personal.stash }/direct/$UNIQ_TOKEN/personal/dot-gnupg/homedir"
                                                                            ENTRY=${ builtins.concatStringsSep "" [ "$" "{" "1:-" "}" ] }
                                                                            FILE="$PASSWORD_STORE_DIR/$ENTRY.gpg"
                                                                            
                                                                            if [[ -z "$ENTRY" || ! -f "$FILE" ]]; then
                                                                              echo "Usage: pass warn <entry>" >&2
                                                                              exit 1
                                                                            fi
                                                                            
                                                                            # Extract long key IDs from the encrypted file
                                                                            mapfile -t LONG_KEY_IDS < <(
                                                                              gpg --list-packets "$FILE" 2>/dev/null \
                                                                              | awk '/^:pubkey enc packet:/ { print $NF }'
                                                                            )
                                                                            
                                                                            if [[ ${ builtins.concatStringsSep "" [ "$" "{" "#LONG_KEY_IDS[@]" "}" ] } -eq 0 ]]; then
                                                                              echo "No encryption keys found in $FILE" >&2
                                                                              exit 1
                                                                            fi
                                                                            
                                                                            echo "Encryption Long Key IDs found in $ENTRY:" >&2
                                                                            printf '  %s\n' "${ builtins.concatStringsSep "" [ "$" "{" "LONG_KEY_IDS[@]" "}" ] }" >&2
                                                                            
                                                                            # Convert long key IDs to full fingerprints
                                                                            mapfile -t ENCRYPTION_FPRS < <(
                                                                              for longid in "${ builtins.concatStringsSep "" [ "$" "{" "LONG_KEY_IDS[@]" "}" ] }"; do
                                                                                gpg --with-colons --fingerprint "$longid" 2>/dev/null \
                                                                                | awk -F: '/^fpr:/ { print $10; exit }'
                                                                              done
                                                                            )
                                                                            
                                                                            echo "Corresponding full fingerprints:" >&2
                                                                            printf '  %s\n' "${ builtins.concatStringsSep "" [ "$" "{" "ENCRYPTION_FPRS[@]" "}" ] }" >&2
                                                                            
                                                                            mapfile -t CURRENT_FPRS < "/home/${ config.personal.name }/${ config.personal.stash }/direct/$UNIQ_TOKEN/personal/pass/.password-store-dir/.gpg-id"
                                                                            
                                                                            
                                                                            echo "Current trusted key fingerprints:" >&2
                                                                            printf '  %s\n' "${ builtins.concatStringsSep "" [ "$" "{" "CURRENT_FPRS[@]" "}" ] }" >&2
                                                                            
                                                                            # Check if all encryption fingerprints are in current trusted keys
                                                                            WARNING=0
                                                                            for fpr in "${ builtins.concatStringsSep "" [ "$" "{" "ENCRYPTION_FPRS[@]" "}" ] }"; do
                                                                              if ! printf '%s\n' "${ builtins.concatStringsSep "" [ "$" "{" "CURRENT_FPRS[@]" "}" ] }" | grep -qx "$fpr"; then
                                                                                echo "⚠️  Warning: $ENTRY was encrypted with an unknown or old GPG key fingerprint:" >&2
                                                                                echo "   $fpr" >&2
                                                                                WARNING=1
                                                                              fi
                                                                            done
                                                                            
                                                                            # Finally, show the password
                                                                            pass show "$ENTRY"
                                                                            
                                                                            exit $WARNING                                                                        
                                                                        '' ;
                                                                } ;
                                                        in
                                                            ''
                                                                mkdir $out
                                                                ln --symbolic ${ expiry }/bin/expiry $out/expiry.bash
                                                                ln --symbolic ${ phonetic }/bin/phonetic $out/phonetic.bash
                                                                ln --symbolic ${ warn }/bin/warn $out/warn.bash
                                                            '' ;
                                                    nativeBuildInputs = [ pkgs.coreutils ] ;
                                                    name = "password-store-extensions-dir" ;
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
                                                                variables =
                                                                    {
                                                                        "PASSWORD_STORE_ENABLE_EXTENSIONS" = "true" ;
                                                                        "PASSWORD_STORE_EXTENSIONS_DIR" = "${ password-store-extensions-dir }" ;
                                                                        "PASSWORD_STORE_CHARACTER_SET" = config.personal.pass.character-set ;
                                                                        "PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS" = config.personal.pass.character-set-no-symbols ;
                                                                        "PASSWORD_STORE_DIR" = "/home/${ config.personal.name }/${ config.personal.stash }/direct/$UNIQ_TOKEN/personal/pass/boot/.password-store-dir" ;
                                                                        "PASSWORD_STORE_GENERATED_LENGTH" = builtins.toString config.personal.pass.generated-length ;
                                                                        "PASSWORD_STORE_GPG_OPTS" = "--homedir /home/${ config.personal.name }/${ config.personal.stash }/direct/$UNIQ_TOKEN/personal/dot-gnupg/homedir" ;
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
                                                                                                                    if [ -d /home/${ config.personal.name }/${ config.personal.stash }/direct ]
                                                                                                                    then
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
                                                                                                                    fi
                                                                                                                '' ;
                                                                                                        } ;
                                                                                                in "${ script }/bin/script" ;
                                                                                        User = config.personal.name ;
                                                                                    } ;
                                                                                wantedBy = [ "multi-user.target" ] ;
                                                                            } ;
                                                                        stash-setup =
                                                                            {
                                                                                after = [ "network.target" ] ;
                                                                                serviceConfig =
                                                                                    {
                                                                                        ExecStart = "${ setup }/bin/setup" ;
                                                                                        User = config.personal.name ;
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
                                                                        stash-setup =
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
                                                                        pkgs.chromium
                                                                        pkgs.jetbrains.idea-community
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
                                                                git-crypt = lib.mkOption { default = "" ; type = lib.types.str ; } ;
                                                                hash-length = lib.mkOption { default = 16 ; type = lib.types.int ; } ;
                                                                name = lib.mkOption { type = lib.types.str ; } ;
                                                                pass =
                                                                    {
                                                                        character-set = lib.mkOption { default = ".,_=2345ABCDEFGHJKLMabcdefghjkmn" ; type = lib.types.str ; } ;
                                                                        character-set-no-symbols = lib.mkOption { default = "6789NPQRSTUVWXYZpqrstuvwxyz" ; type = lib.types.str ; } ;
                                                                        generated-length = lib.mkOption { default = 25 ; type = lib.types.int ; } ;
                                                                    } ;
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
