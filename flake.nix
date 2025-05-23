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
                                                            dot-gnupg-config =
                                                                visitor.lib.implementation
                                                                    {
                                                                        lambda = path : value : let point = value null ; in if point.dot-gnupg-config then "$( ${ point.command } )" else unimplemented path value ;
                                                                        null = unimplemented ;
                                                                    }
                                                                    secondary ;
                                                            dot-ssh-config =
                                                                visitor.lib.implementation
                                                                    {
                                                                        lambda = path : value : let point = value null ; in if point.dot-ssh-config then "$( ${ point.command } )" else unimplemented path value ;
                                                                        null = unimplemented ;
                                                                    }
                                                                    secondary ;
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
                                                            repositories =
                                                                visitor.lib.implementation
                                                                    {
                                                                        lambda = path : value : let point = value null ; in if point.repository then "$( ${ point.command } )" else unimplemented path value ;
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
                                                                                        crypt =
                                                                                            fun :
                                                                                                let
                                                                                                    application =
                                                                                                        pkgs.writeShellApplication
                                                                                                            {
                                                                                                                name = "crypt" ;
                                                                                                                runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.git-crypt pkgs.jq pkgs.yq ] ;
                                                                                                                text =
                                                                                                                    let
                                                                                                                        point =
                                                                                                                            let
                                                                                                                                identity_ =
                                                                                                                                    {
                                                                                                                                        branch ? "main" ,
                                                                                                                                        dot-gnupg ,
                                                                                                                                        email ,
                                                                                                                                        inputs ? { } ,
                                                                                                                                        name ,
                                                                                                                                        origin ,
                                                                                                                                        ssh-config
                                                                                                                                    } :
                                                                                                                                        {
                                                                                                                                            branch = branch ;
                                                                                                                                            dot-gnupg = dot-gnupg ;
                                                                                                                                            email = email ;
                                                                                                                                            inputs = inputs ;
                                                                                                                                            name = name ;
                                                                                                                                            origin = origin ;
                                                                                                                                            ssh-config = ssh-config ;
                                                                                                                                        } ;
                                                                                                                                    in identity_ ( fun { dot-gnupg-config = dot-gnupg-config ; dot-ssh-config = dot-ssh-config ; repositories = repositories ; } ) ;
                                                                                                                        post-commit =
                                                                                                                            pkgs.writeShellApplication
                                                                                                                                {
                                                                                                                                    name = "post-commit" ;
                                                                                                                                    runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.nix pkgs.nixos-rebuild ] ;
                                                                                                                                    text =
                                                                                                                                        ''
                                                                                                                                            while ! git push origin HEAD
                                                                                                                                            do
                                                                                                                                                sleep 1
                                                                                                                                            done
                                                                                                                                        '' ;
                                                                                                                                } ;
                                                                                                                        pre-commit =
                                                                                                                            pkgs.writeShellApplication
                                                                                                                                {
                                                                                                                                    name = "pre-commit" ;
                                                                                                                                    runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.nix pkgs.nixos-rebuild ] ;
                                                                                                                                    text =
                                                                                                                                        ''
                                                                                                                                            BRANCH=$( git rev-parse --abbrev-ref HEAD )
                                                                                                                                            if [ -z "$BRANCH" ] || [[ "$BRANCH" != scratch/* ]]
                                                                                                                                            then
                                                                                                                                                git scratch
                                                                                                                                            fi
                                                                                                                                        '' ;
                                                                                                                                } ;
                                                                                                                        in
                                                                                                                            ''
                                                                                                                                STASH_FILE=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" primary.name primary.stash ( builtins.substring 0 primary.hash-length ( builtins.hashString "sha512" ( builtins.toJSON ( primary.seed ) ) ) ) "stash" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                                                                FLAG_DIRECTORY=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" primary.name primary.stash ( builtins.substring 0 primary.hash-length ( builtins.hashString "sha512" ( builtins.toJSON ( primary.seed ) ) ) ) "flag" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                                                                if [ -d "$FLAG_DIRECTORY" ] && [ -f "$FLAG_DIRECTORY/error.yaml" ]
                                                                                                                                then
                                                                                                                                    exec 201> "$FLAG_DIRECTORY/lock"
                                                                                                                                    flock -s 201
                                                                                                                                    yq --yaml-output "$FLAG_DIRECTORY/error.yaml" >&2
                                                                                                                                    flock -u 201
                                                                                                                                    exit 64
                                                                                                                                elif [ -d "$FLAG_DIRECTORY" ]
                                                                                                                                then
                                                                                                                                    exec 201> "$FLAG_DIRECTORY/lock"
                                                                                                                                    flock -s 201
                                                                                                                                    echo "$STASH_FILE"
                                                                                                                                    flock -u 201
                                                                                                                                else
                                                                                                                                    mkdir --parents "$FLAG_DIRECTORY"
                                                                                                                                    exec 201> "$FLAG_DIRECTORY/lock"
                                                                                                                                    flock -x 201
                                                                                                                                    if
                                                                                                                                        (
                                                                                                                                            export GIT_DIR="$STASH_FILE/git"
                                                                                                                                            mkdir --parent "$GIT_DIR"
                                                                                                                                            export GIT_WORK_TREE="$STASH_FILE/work-tree"
                                                                                                                                            mkdir --parents "$GIT_WORK_TREE"
                                                                                                                                            GNUPGHOME=${ point.dot-gnupg }
                                                                                                                                            export GNUPGHOME
                                                                                                                                            cat > "$STASH_FILE/.envrc" <<EOF
                                                                                                                                export GNUPGHOME="$GNUPGHOME"
                                                                                                                                export GIT_DIR="$GIT_DIR"
                                                                                                                                export GIT_WORK_TREE="$GIT_WORK_TREE"
                                                                                                                                EOF
                                                                                                                                            git init > /dev/null 2>&1
                                                                                                                                            git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F ${ point.ssh-config }"
                                                                                                                                            git config user.email "${ point.email }"
                                                                                                                                            git config user.name "${ point.name }"
                                                                                                                                            ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                                                                            ln --symbolic ${ pre-commit }/bin/pre-commit "$GIT_DIR/hooks/pre-commit"
                                                                                                                                            git remote add origin "${ point.origin }"
                                                                                                                                            if git fetch origin ${ point.branch } > /dev/null 2>&1
                                                                                                                                            then
                                                                                                                                                git checkout ${ point.branch } > /dev/null 2>&1
                                                                                                                                            else
                                                                                                                                                git checkout -b ${ point.branch } > /dev/null 2>&1
                                                                                                                                                git commit --no-verify --allow-empty --allow-empty-message -m "" > /dev/null 2>&1
                                                                                                                                            fi
                                                                                                                                        ) > "$FLAG_DIRECTORY/standard-output" 2> "$FLAG_DIRECTORY/standard-error"
                                                                                                                                    then
                                                                                                                                        STATUS="$?"
                                                                                                                                    else
                                                                                                                                        STATUS="$?"
                                                                                                                                    fi
                                                                                                                                    if [ "$STATUS" == "0" ] && [ ! -s "$FLAG_DIRECTORY/standard-error" ]
                                                                                                                                    then
                                                                                                                                        echo "$STASH_FILE"
                                                                                                                                        flock -u 201
                                                                                                                                    else
                                                                                                                                        jq --null-input --arg STANDARD_ERROR "$( cat "$FLAG_DIRECTORY/standard-error" )" --arg STANDARD_OUTPUT "$( cat "$FLAG_DIRECTORY/standard-output" )" --arg STATUS "$STATUS" '{ "standard-error": $STANDARD_ERROR , "standard-output" : $STANDARD_OUTPUT , "status" : $STATUS }' | yq --yaml-output "." > "$FLAG_DIRECTORY/error.yaml"
                                                                                                                                        yq --yaml-output "$FLAG_DIRECTORY/error.yaml" >&2
                                                                                                                                        flock -u 201
                                                                                                                                        exit 64
                                                                                                                                    fi
                                                                                                                                fi
                                                                                                                            '' ;
                                                                                                            } ;
                                                                                                    in { crypt = true ; dot-gnupg-config = false ; dot-ssh-config = false ; identity = false ; command = "${ application }/bin/crypt" ; known-host = false ; pass = false ; repository = false ; } ;
                                                                                        dot-gnupg-config =
                                                                                            { ownertrust , secret-keys } :
                                                                                                let
                                                                                                    application =
                                                                                                        pkgs.writeShellApplication
                                                                                                            {
                                                                                                                name = "dot-gnupg-config" ;
                                                                                                                runtimeInputs = [ pkgs.coreutils pkgs.gnupg pkgs.jq pkgs.yq ] ;
                                                                                                                text =
                                                                                                                    ''
                                                                                                                        STASH_FILE=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" primary.name primary.stash ( builtins.substring 0 primary.hash-length ( builtins.hashString "sha512" ( builtins.toJSON ( primary.seed ) ) ) ) "stash" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                                                        FLAG_DIRECTORY=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" primary.name primary.stash ( builtins.substring 0 primary.hash-length ( builtins.hashString "sha512" ( builtins.toJSON ( primary.seed ) ) ) ) "flag" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                                                        if [ -d "$FLAG_DIRECTORY" ] && [ -f "$FLAG_DIRECTORY/error.yaml" ]
                                                                                                                        then
                                                                                                                            exec 201> "$FLAG_DIRECTORY/lock"
                                                                                                                            flock -s 201
                                                                                                                            yq --yaml-output "$FLAG_DIRECTORY/error.yaml" >&2
                                                                                                                            flock -u 201
                                                                                                                            exit 64
                                                                                                                        elif [ -d "$FLAG_DIRECTORY" ] && [ -f "$FLAG_DIRECTORY/error.yaml" ]
                                                                                                                        then
                                                                                                                            exec 201> "$FLAG_DIRECTORY/lock"
                                                                                                                            flock -s 201
                                                                                                                            echo "$STASH_FILE"
                                                                                                                            flock -u 201
                                                                                                                        else
                                                                                                                            mkdir --parents "$FLAG_DIRECTORY"
                                                                                                                            exec 201> "$FLAG_DIRECTORY/lock"
                                                                                                                            flock -x 201
                                                                                                                            if
                                                                                                                                (
                                                                                                                                    export GNUPGHOME="$STASH_FILE"
                                                                                                                                    mkdir --parents $GNUPGHOME
                                                                                                                                    chmod 0700 "$GNUPGHOME"
                                                                                                                                    gpg --batch --yes --home "$GNUPGHOME" --import ${ secret-keys } 2>&1
                                                                                                                                    gpg --home "$GNUPGHOME" --import-ownertrust ${ ownertrust } 2>&1
                                                                                                                                    gpg --home "$GNUPGHOME" --update-trustdb 2>&1
                                                                                                                                    ) > "$FLAG_DIRECTORY/standard-output" 2> "$FLAG_DIRECTORY/standard-error"
                                                                                                                            then
                                                                                                                                STATUS="$?"
                                                                                                                            else
                                                                                                                                STATUS="$?"
                                                                                                                            fi
                                                                                                                            if [ "$STATUS" == "0" ] && [ ! -s "$FLAG_DIRECTORY/standard-error" ]
                                                                                                                            then
                                                                                                                                echo "$STASH_FILE"
                                                                                                                            else
                                                                                                                                jq --null-input --arg STANDARD_ERROR "$( cat "$FLAG_DIRECTORY/standard-error" )" --arg STANDARD_OUTPUT "$( cat "$FLAG_DIRECTORY/standard-output" )" --arg STATUS "$STATUS" '{ "standard-error": $STANDARD_ERROR , "standard-output" : $STANDARD_OUTPUT , "status" : $STATUS }' | yq --yaml-output "." > "$FLAG_DIRECTORY/error.yaml"
                                                                                                                            fi
                                                                                                                            flock -u 201
                                                                                                                        fi
                                                                                                                    '' ;
                                                                                                            } ;
                                                                                                    in { dot-gnupg-config = true ; dot-ssh-config = false ; identity = false ; command = "${ application }/bin/dot-gnupg-config" ; known-host = false ; pass = false ; repository = false ; } ;
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
                                                                                                    in { dot-gnupg-config = false ; dot-ssh-config = true ; identity = false ; command = "${ application }/bin/dot-ssh-config" ; known-host = false ; pass = false ; repository = false ; } ;
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
                                                                                                    in { dot-gnupg-config = false ; dot-ssh-config = false ; identity = true ; command = "${ application }/bin/identity" ; known-host = false ; pass = false ; repository = false ; } ;
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
                                                                                                    in { dot-gnupg-config = false ; dot-ssh-config = false ; identity = false ; command = "${ application }/bin/known-host" ; known-host = true ; pass = false ; repository = false ; } ;
                                                                                        pass =
                                                                                            fun :
                                                                                                let
                                                                                                    application =
                                                                                                        pkgs.writeShellApplication
                                                                                                            {
                                                                                                                name = "pass" ;
                                                                                                                runtimeInputs = [ pkgs.pass ] ;
                                                                                                                text =
                                                                                                                    let
                                                                                                                        extension-dir =
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
                                                                                                                                                                GIT_DIR="${ point.repository }/git"
                                                                                                                                                                export GIT_DIR
                                                                                                                                                                GIT_WORK_TREE="${ point.repository }/work-tree"
                                                                                                                                                                export GIT_WORK_TREE
                                                                                                                                                                # Constants
                                                                                                                                                                YEAR_SECONDS=$((366 * 86400))
                                                                                                                                                                TIMESTAMP=$(date +%s)

                                                                                                                                                                # Get a list of all password keys tracked by Git
                                                                                                                                                                git ls-tree -r --name-only HEAD | while IFS= read -r file; do
                                                                                                                                                                  # Skip non-.gpg files
                                                                                                                                                                  [[ "$file" != *.gpg ]] && continue

                                                                                                                                                                  # Get the last commit timestamp for the file
                                                                                                                                                                  last_commit_ts=$(git log -1 --format="%at" -- "$file" || echo 0)

                                                                                                                                                                  # Compute the age
                                                                                                                                                                  age=$((TIMESTAMP - last_commit_ts))

                                                                                                                                                                  if (( age >= YEAR_SECONDS )); then
                                                                                                                                                                    # Strip ".gpg" and print
                                                                                                                                                                    key="${ builtins.concatStringsSep "" [ "$" "{" "file%.gpg" "}" ] }"
                                                                                                                                                                    echo "$key"
                                                                                                                                                                  fi
                                                                                                                                                                done

                                                                                                                                                            '' ;
                                                                                                                                                    } ;
                                                                                                                                            phonetic =
                                                                                                                                                pkgs.writeShellApplication
                                                                                                                                                    {
                                                                                                                                                        name = "phonetic" ;
                                                                                                                                                        runtimeInputs = [ pkgs.coreutils pkgs.pass ] ;
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
                                                                                                                                            in
                                                                                                                                                ''
                                                                                                                                                    ${ pkgs.coreutils }/bin/mkdir $out
                                                                                                                                                    makeWrapper ${ expiry }/bin/expiry $out/expiry.bash
                                                                                                                                                    makeWrapper ${ phonetic }/bin/phonetic $out/phonetic.bash
                                                                                                                                                '' ;
                                                                                                                                    name = "extensions-dir" ;
                                                                                                                                    nativeBuildInputs = [ pkgs.makeWrapper ] ;
                                                                                                                                    src = ./. ;
                                                                                                                                } ;
                                                                                                                        point =
                                                                                                                            let
                                                                                                                                identity =
                                                                                                                                    {
                                                                                                                                        character-set ? ".,_=2345ABCDEFGHJKLMabcdefghjkmn" ,
                                                                                                                                        character-set-no-symbols ? "6789NPQRSTUVWXYZpqrstuvwxyz" ,
                                                                                                                                        dot-gnupg ,
                                                                                                                                        generated-length ? 25 ,
                                                                                                                                        repository
                                                                                                                                    } :
                                                                                                                                        {
                                                                                                                                            character-set = character-set ;
                                                                                                                                            character-set-no-symbols = character-set-no-symbols ;
                                                                                                                                            dot-gnupg = dot-gnupg ;
                                                                                                                                            generated-length = builtins.toString generated-length ;
                                                                                                                                            repository = repository ;
                                                                                                                                        } ;
                                                                                                                                in identity ( fun { dot-gnupg-config = dot-gnupg-config ; repositories = repositories ; } ) ;
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
                                                                                                                                    mkdir --parents "$STASH_FILE"
                                                                                                                                    cat > "$STASH_FILE/.envrc" <<EOF
                                                                                                                                export GIT_DIR="\${ point.repository }/git"
                                                                                                                                export GIT_WORK_TREE="\${ point.repository }/work-tree"
                                                                                                                                export PASSWORD_STORE_CHARACTER_SET=${ point.character-set }
                                                                                                                                export PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS=${ point.character-set-no-symbols }
                                                                                                                                export PASSWORD_STORE_GENERATED_LENGTH="${ point.generated-length }"
                                                                                                                                export PASSWORD_STORE_DIR="\${ point.repository }/work-tree"
                                                                                                                                export PASSWORD_STORE_ENABLE_EXTENSIONS=true;
                                                                                                                                export PASSWORD_STORE_EXTENSIONS_DIR=${ extension-dir }
                                                                                                                                export PASSWORD_STORE_GPG_OPTS="--homedir \${ point.dot-gnupg }"
                                                                                                                                EOF
                                                                                                                                    echo "$STASH_FILE"
                                                                                                                                    flock -u 201
                                                                                                                                fi
                                                                                                                            '' ;
                                                                                                            } ;
                                                                                                    in { dot-gnupg-config = false ; dot-ssh-config = false ; identity = false ; command = "${ application }/bin/pass" ; known-host = false ; pass = true ; repository = false ; } ;
                                                                                        repository =
                                                                                            fun :
                                                                                                let
                                                                                                    application =
                                                                                                        pkgs.writeShellApplication
                                                                                                            {
                                                                                                                name = "repository" ;
                                                                                                                runtimeInputs = [ pkgs.git ] ;
                                                                                                                text =
                                                                                                                    let
                                                                                                                        point =
                                                                                                                            let
                                                                                                                                identity_ =
                                                                                                                                    {
                                                                                                                                        branch ? "main" ,
                                                                                                                                        email ,
                                                                                                                                        inputs ? { } ,
                                                                                                                                        name ,
                                                                                                                                        origin ,
                                                                                                                                        ssh-config
                                                                                                                                    } :
                                                                                                                                        {
                                                                                                                                            branch = branch ;
                                                                                                                                            email = email ;
                                                                                                                                            inputs = inputs ;
                                                                                                                                            name = name ;
                                                                                                                                            origin = origin ;
                                                                                                                                            ssh-config = ssh-config ;
                                                                                                                                        } ;
                                                                                                                                    in identity_ ( fun { dot-ssh-config = dot-ssh-config ; repositories = repositories ; } ) ;
                                                                                                                        post-commit =
                                                                                                                            pkgs.writeShellApplication
                                                                                                                                {
                                                                                                                                    name = "post-commit" ;
                                                                                                                                    runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.nix pkgs.nixos-rebuild ] ;
                                                                                                                                    text =
                                                                                                                                        if point.origin == "mobile:private"
                                                                                                                                        then
                                                                                                                                            ''
                                                                                                                                                while ! git push origin HEAD
                                                                                                                                                do
                                                                                                                                                    sleep 1
                                                                                                                                                done
                                                                                                                                                BRANCH=$( git rev-parse --abbrev-ref HEAD )
                                                                                                                                                if [ "$BRANCH" == "main" ]
                                                                                                                                                then
                                                                                                                                                    nix flake check
                                                                                                                                                    sudo nixos-rebuild switch --flake .#myhost
                                                                                                                                                    nix-collect-garbage --delete-older-than 7d
                                                                                                                                                elif [ "$BRANCH" == "development" ]
                                                                                                                                                then
                                                                                                                                                    nix flake check
                                                                                                                                                    sudo nixos-rebuild test --flake .#myhost
                                                                                                                                                elif [[ "$BRANCH" == milestone/* ]]
                                                                                                                                                then
                                                                                                                                                    nix-collect-garbage
                                                                                                                                                    nix flake check
                                                                                                                                                    nixos-rebuild build-vm-with-bootloader .#myhost
                                                                                                                                                elif [[ "$BRANCH" == issue/* ]]
                                                                                                                                                then
                                                                                                                                                    nix flake check
                                                                                                                                                    nixos-rebuild build-vm --flake .#myhost
                                                                                                                                                elif [[ "$BRANCH" == sub/* ]]
                                                                                                                                                then
                                                                                                                                                    nix flake check
                                                                                                                                                    nixos-rebuild build-vm .#myhost
                                                                                                                                                elif [[ "$BRANCH" == scratch/* ]]
                                                                                                                                                then
                                                                                                                                                    nix flake check  ${ builtins.concatStringsSep " " ( builtins.attrValues ( builtins.mapAttrs ( name : value : ''--override-input ${ name } "${ value }/work-tree"'' ) point.inputs ) ) }
                                                                                                                                                    nixos-rebuild build-vm --flake .#myhost ${ builtins.concatStringsSep " " ( builtins.attrValues ( builtins.mapAttrs ( name : value : ''--override-input ${ name } "${ value }/work-tree"'' ) point.inputs ) ) }
                                                                                                                                                    mv result ..
                                                                                                                                                else
                                                                                                                                                    echo "BRANCH=$BRANCH does not follow the naming rules." >&2
                                                                                                                                                    exit 64
                                                                                                                                                fi
                                                                                                                                            ''
                                                                                                                                        else if point.origin == "git@github.com:viktordanek/personal.git" || point.origin == "git@github.com:viktordanek/visitor.git" then
                                                                                                                                            ''
                                                                                                                                                while ! git push origin HEAD
                                                                                                                                                do
                                                                                                                                                    sleep 1
                                                                                                                                                done
                                                                                                                                                nix flake check ${ builtins.concatStringsSep " " ( builtins.attrValues ( builtins.mapAttrs ( name : value : ''--override-input ${ name } "${ value }/work-tree"'' ) point.inputs ) ) }
                                                                                                                                            ''
                                                                                                                                        else
                                                                                                                                            ''
                                                                                                                                                while ! git push origin HEAD
                                                                                                                                                do
                                                                                                                                                    sleep 1
                                                                                                                                                done
                                                                                                                                            '' ;
                                                                                                                                } ;
                                                                                                                        pre-commit =
                                                                                                                            pkgs.writeShellApplication
                                                                                                                                {
                                                                                                                                    name = "pre-commit" ;
                                                                                                                                    runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.nix pkgs.nixos-rebuild ] ;
                                                                                                                                    text =
                                                                                                                                        if point.origin == "mobile:private" then
                                                                                                                                            ''
                                                                                                                                                BRANCH=$( git rev-parse --abbrev-ref HEAD )
                                                                                                                                                if [ "$BRANCH" == "main" ]
                                                                                                                                                then
                                                                                                                                                    date +%s > current-time.nix
                                                                                                                                                    git add current-time.nix
                                                                                                                                                    nix-collect-garbage
                                                                                                                                                    nix flake check
                                                                                                                                                    nixos-rebuild build-vm --flake .#myhost
                                                                                                                                                elif [ "$BRANCH" == "development" ]
                                                                                                                                                then
                                                                                                                                                    date +%s > current-time.nix
                                                                                                                                                    git add current-time.nix
                                                                                                                                                    nix-collect-garbage
                                                                                                                                                    nix flake check
                                                                                                                                                    nixos-rebuild build-vm --flake .#myhost
                                                                                                                                                elif [[ "$BRANCH" == milestone/* ]]
                                                                                                                                                then
                                                                                                                                                    nix-collect-garbage
                                                                                                                                                    nix flake check
                                                                                                                                                    nixos-rebuild build-vm --flake .#myhost
                                                                                                                                                elif [[ "$BRANCH" == issue/* ]]
                                                                                                                                                then
                                                                                                                                                    nix flake check
                                                                                                                                                    nixos-rebuild build-vm --flake .#myhost
                                                                                                                                                elif [[ "$BRANCH" == sub/* ]]
                                                                                                                                                then
                                                                                                                                                    nix flake check
                                                                                                                                                fi
                                                                                                                                            ''
                                                                                                                                        else
                                                                                                                                            ''
                                                                                                                                                BRANCH=$( git rev-parse --abbrev-ref HEAD )
                                                                                                                                                if [ -z "$BRANCH" ] || [[ "$BRANCH" != scratch/* ]]
                                                                                                                                                then
                                                                                                                                                    git scratch
                                                                                                                                                fi
                                                                                                                                            '' ;
                                                                                                                                } ;
                                                                                                                        scratch =
                                                                                                                            pkgs.writeShellApplication
                                                                                                                                {
                                                                                                                                    name = "scratch" ;
                                                                                                                                    runtimeInputs = [ pkgs.git pkgs.libuuid ] ;
                                                                                                                                    text =
                                                                                                                                        ''
                                                                                                                                            git checkout -b "scratch/$( uuidgen )"
                                                                                                                                        '' ;
                                                                                                                                } ;
                                                                                                                        start =
                                                                                                                            pkgs.writeShellApplication
                                                                                                                                {
                                                                                                                                    name = "start" ;
                                                                                                                                    runtimeInputs = [ pkgs.git ] ;
                                                                                                                                    text =
                                                                                                                                        ''
                                                                                                                                            git fetch origin "$1"
                                                                                                                                            git checkout "origin/$1"
                                                                                                                                            git scratch
                                                                                                                                            git commit -am "$( cat )" --allow-empty --allow-empty-message
                                                                                                                                        '' ;
                                                                                                                                } ;
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
                                                                                                                                    export GIT_DIR="$STASH_FILE/git"
                                                                                                                                    mkdir --parent "$GIT_DIR"
                                                                                                                                    export GIT_WORK_TREE="$STASH_FILE/work-tree"
                                                                                                                                    mkdir --parents "$GIT_WORK_TREE"
                                                                                                                                    cat > "$STASH_FILE/.envrc" <<EOF
                                                                                                                                export GIT_DIR="$GIT_DIR"
                                                                                                                                export GIT_WORK_TREE="$GIT_WORK_TREE"
                                                                                                                                EOF
                                                                                                                                    git init > /dev/null 2>&1
                                                                                                                                    git config alias.nix "!${ pkgs.nix }/bin/nix"
                                                                                                                                    git config alias.scratch "!${ scratch }/bin/scratch"
                                                                                                                                    git config alias.start "!${ start }/bin/start"
                                                                                                                                    git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F ${ point.ssh-config }"
                                                                                                                                    git config user.email "${ point.email }"
                                                                                                                                    git config user.name "${ point.name }"
                                                                                                                                    ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                                                                    ln --symbolic ${ pre-commit }/bin/pre-commit "$GIT_DIR/hooks/pre-commit"
                                                                                                                                    git remote add origin "${ point.origin }"
                                                                                                                                    if git fetch origin ${ point.branch } > /dev/null 2>&1
                                                                                                                                    then
                                                                                                                                        git checkout ${ point.branch } > /dev/null 2>&1
                                                                                                                                    else
                                                                                                                                        git checkout -b ${ point.branch } > /dev/null 2>&1
                                                                                                                                        git commit --no-verify --allow-empty --allow-empty-message -m "" > /dev/null 2>&1
                                                                                                                                    fi
                                                                                                                                    echo "$STASH_FILE"
                                                                                                                                    flock -u 201
                                                                                                                                fi
                                                                                                                            '' ;
                                                                                                            } ;
                                                                                                    in { dot-gnupg-config = false ; dot-ssh-config = false ; identity = false ; command = "${ application }/bin/repository" ; known-host = false ; pass = false ; repository = true ; } ;
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
                                                                    builtins.concatLists
                                                                        [
                                                                            [
                                                                                pkgs.git
                                                                                pkgs.git-crypt
                                                                                pkgs.gnupg
                                                                                pkgs.pass
                                                                                (
                                                                                    pkgs.writeShellApplication
                                                                                        {
                                                                                            name = "portfolio" ;
                                                                                            runtimeInputs = [ pkgs.coreutils pkgs.findutils ] ;
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
                                                                                            runtimeInputs = [ pkgs.coreutils pkgs.findutils pkgs.jetbrains.idea-community ] ;
                                                                                            text =
                                                                                                ''
                                                                                                    find ${ derivation } -mindepth 1 -type f -exec {} \;
                                                                                                    idea-community /home/${ primary.name }/${ primary.stash }/${ builtins.substring 0 primary.hash-length ( builtins.hashString "sha512" ( builtins.toJSON primary.seed ) ) }
                                                                                                '' ;
                                                                                        }
                                                                                )
                                                                            ]
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
