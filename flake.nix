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
                                                                                    stash =
                                                                                        ''
                                                                                            export STASH_FILE=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" config.personal.name config.personal.stash ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toJSON ( builtins.readFile config.personal.current-time ) ) ) ) "output" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                            STATUS_DIR=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" config.personal.name config.personal.stash ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toJSON ( builtins.readFile config.personal.current-time ) ) ) ) "status" ] ( builtins.map builtins.toJSON path ) ] ) }
                                                                                            mkdir --parents "$STATUS_DIR"
                                                                                            exec 201> "$STATUS_DIR/lock"
                                                                                            flock -x 201
                                                                                            if [ -f "$STATUS_DIR/success.yaml" ]
                                                                                            then
                                                                                                echo "$STASH_FILE"
                                                                                                flock -u 201
                                                                                                exit 0
                                                                                            elif [ -f "$STATUS_DIR/failure.yaml" ]
                                                                                            then
                                                                                                cat "$STATUS_DIR/failure.yaml" | yq --yaml-output >&2
                                                                                                exit 64
                                                                                            else
                                                                                                mkdir --parents "$( dirname "$STASH_FILE" )"
                                                                                                if ${ pkgs.writeShellApplication ( ( value null ) // { name = "initial" ; } ) }/bin/initial "$STASH_FILE" "$OUT" > "$STATUS_DIR/standard-output" 2> "$STATUS_DIR/standard-error"
                                                                                                then
                                                                                                    STATUS="$?"
                                                                                                else
                                                                                                    STATUS="$?"
                                                                                                fi
                                                                                                echo "$STATUS" > "$STATUS_DIR/status"
                                                                                                if [ "$STATUS" == 0 ] && [ ! -s "$STATUS_DIR/standard-error" ]
                                                                                                then
                                                                                                    touch "$STATUS_DIR/success.yaml"
                                                                                                    echo "$STASH_FILE"
                                                                                                    flock -u 201
                                                                                                    exit 0
                                                                                                else
                                                                                                    jq --null-input --arg SCRIPT ${ pkgs.writeShellApplication ( ( value null ) // { name = "initial" ; } ) }/bin/initial --arg OUT "$OUT" --arg STANDARD_ERROR "$( cat "$STATUS_DIR/standard-error" )" --arg STANDARD_OUTPUT "$( cat "$STATUS_DIR/standard-output" )" --arg STASH_FILE "$STASH_FILE}" --arg STATUS "$STATUS" '{ "out" : $OUT , "script" : $SCRIPT , "standard-error" : $STANDARD_ERROR , "standard-output" : $STANDARD_OUTPUT , "stash-file" : $STASH_FILE , "status" : $STATUS }' | yq --yaml-output "." > "$STATUS_DIR/failure.yaml"
                                                                                                    cat "$STATUS_DIR/failure.yaml" | yq --yaml-output
                                                                                                    flock -u 201
                                                                                                    exit 64
                                                                                                fi
                                                                                            fi
                                                                                        '' ;
                                                                                    in [ "makeWrapper ${ pkgs.writeShellScript "stash" stash } ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$out" ] ( builtins.map builtins.toJSON path ) ] ) } --set PATH ${ pkgs.coreutils }/bin:${ pkgs.flock }/bin:${ pkgs.jq }/bin:${ pkgs.yq }/bin --set OUT $out" ] ;
                                                                        list = path : list : builtins.concatLists [ [ "mkdir --parents ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$out" ] ( builtins.map builtins.toJSON path ) ] ) }" ] ( builtins.concatLists list ) ] ;
                                                                        null = path : value : [ "mkdir --parents ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$out" ] ( builtins.map builtins.toJSON path ) ] ) }" ] ;
                                                                        set = path : set : builtins.concatLists [ [ "mkdir --parents ${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$out" ] ( builtins.map builtins.toJSON path ) ] ) }" ] ( builtins.concatLists ( builtins.attrValues set ) ) ] ;
                                                                    }
                                                                    {
                                                                        boot =
                                                                            {
                                                                                dot-gnupg =
                                                                                    {
                                                                                        config =
                                                                                            ignore :
                                                                                                {
                                                                                                    runtimeInputs = [ pkgs.gnupg ] ;
                                                                                                    text =
                                                                                                        ''
                                                                                                            export GNUPGHOME="$1"
                                                                                                            mkdir --parents "$GNUPGHOME"
                                                                                                            chmod 0700 "$GNUPGHOME"
                                                                                                            gpg --batch --yes --home "$GNUPGHOME" --import "$( "$2/boot/dot-gnupg/secret-keys" )" 2>&1
                                                                                                            gpg --batch --yes --home "$GNUPGHOME" --import-ownertrust "$( "$2/boot/dot-gnupg/ownertrust" )" 2>&1
                                                                                                            gpg --batch --yes --home "$GNUPGHOME" --update-trustdb 2>&1
                                                                                                        '' ;
                                                                                                } ;
                                                                                        ownertrust =
                                                                                            ignore :
                                                                                                {
                                                                                                    runtimeInputs = [ pkgs.age pkgs.coreutils ] ;
                                                                                                    text =
                                                                                                        ''
                                                                                                            age --decrypt --identity ${ config.personal.agenix } --output "$1" ${ secrets + "/ownertrust.asc.age" }
                                                                                                            chmod 0400 "$1"
                                                                                                        '' ;
                                                                                                } ;
                                                                                        secret-keys =
                                                                                            ignore :
                                                                                                {
                                                                                                    runtimeInputs = [ pkgs.age pkgs.coreutils ] ;
                                                                                                    text =
                                                                                                        ''
                                                                                                            age --decrypt --identity ${ config.personal.agenix } --output "$1" ${ secrets + "/secret-keys.asc.age" }
                                                                                                            chmod 0400 "$1"
                                                                                                        '' ;
                                                                                                } ;
                                                                                    } ;
                                                                                dot-ssh =
                                                                                    {
                                                                                        boot =
                                                                                            {
                                                                                                config =
                                                                                                    ignore :
                                                                                                        {
                                                                                                            runtimeInputs = [ pkgs.coreutils ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    cat > "$1" <<EOF
                                                                                                                    IdentityFile "$( "$2/boot/dot-ssh/boot/identity" )"
                                                                                                                    UserKnownHostsFile "$( "$2/boot/dot-ssh/boot/known-hosts" )"
                                                                                                                    StrictHostKeyChecking yes

                                                                                                                    Host github.com
                                                                                                                    HostName github.com

                                                                                                                    Host mobile
                                                                                                                    HostName 192.168.1.202
                                                                                                                    Port 8022
                                                                                                                    EOF
                                                                                                                    chmod 0400 "$1"
                                                                                                                '' ;
                                                                                                        } ;
                                                                                                identity =
                                                                                                    ignore :
                                                                                                        {
                                                                                                            runtimeInputs = [ pkgs.age pkgs.coreutils ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    age --decrypt --identity ${ config.personal.agenix } --output "$1" ${ secrets + "/dot-ssh/boot/identity.asc.age" }
                                                                                                                    chmod 0400 "$1"
                                                                                                                '' ;
                                                                                                        } ;
                                                                                                known-hosts =
                                                                                                    ignore :
                                                                                                        {
                                                                                                            runtimeInputs = [ pkgs.age pkgs.coreutils ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    age --decrypt --identity ${ config.personal.agenix } --output "$1" ${ secrets + "/dot-ssh/boot/known-hosts.asc.age" }
                                                                                                                    chmod 0400 "$1"
                                                                                                                '' ;
                                                                                                        } ;
                                                                                            } ;
                                                                                        viktor =
                                                                                            {
                                                                                                config =
                                                                                                    ignore :
                                                                                                        {
                                                                                                            runtimeInputs = [ pkgs.coreutils ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    cat > "$1" <<EOF
                                                                                                                    IdentityFile "$( "$2/boot/dot-ssh/viktor/identity" )"
                                                                                                                    UserKnownHostsFile "$( "$2/boot/dot-ssh/viktor/known-hosts" )"
                                                                                                                    StrictHostKeyChecking yes
                                                                                                                    Host github.com
                                                                                                                    HostName github.com
                                                                                                                    EOF
                                                                                                                    chmod 0400 "$1"
                                                                                                                '' ;
                                                                                                        } ;
                                                                                                identity =
                                                                                                    ignore :
                                                                                                        {
                                                                                                            runtimeInputs = [ pkgs.age pkgs.coreutils ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    age --decrypt --identity ${ config.personal.agenix } --output "$1" ${ secrets + "/dot-ssh/viktor/identity.asc.age" }
                                                                                                                    chmod 0400 "$1"
                                                                                                                '' ;
                                                                                                        } ;
                                                                                                known-hosts =
                                                                                                    ignore :
                                                                                                        {
                                                                                                            runtimeInputs = [ pkgs.age pkgs.coreutils ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    age --decrypt --identity ${ config.personal.agenix } --output "$1" ${ secrets + "/dot-ssh/viktor/known-hosts.asc.age" }
                                                                                                                    chmod 0400 "$1"
                                                                                                                '' ;
                                                                                                        } ;
                                                                                            } ;
                                                                                    } ;
                                                                                pass =
                                                                                    {
                                                                                        archive =
                                                                                            ignore :
                                                                                                {
                                                                                                    runtimeInputs = [ ] ;
                                                                                                    text =
                                                                                                        ''
                                                                                                            mkdir "$1"
                                                                                                            GIT_ROOT="$( "$2/boot/repository/pass-secrets" )"
                                                                                                            GIT_WORK_TREE="$GIT_ROOT/work-tree"
                                                                                                            cat > "$1/.envrc" <<EOF
                                                                                                            export GIT_DIR="$GIT_ROOT/work-tree"
                                                                                                            export GIT_WORK_TREE="$GIT_WORK_TREE"
                                                                                                            export PASSWORD_STORE_DIR="$GIT_WORK_TREE"
                                                                                                            export PASSWORD_STORE_GPG_OPTS="--homedir $( "$2/boot/dot-gnupg/config" )"
                                                                                                            EOF
                                                                                                        '' ;
                                                                                                } ;
                                                                                    } ;
                                                                                repository =
                                                                                    let
                                                                                        post-checkout =
                                                                                            pkgs.writeShellApplication
                                                                                                {
                                                                                                    name = "post-checkout" ;
                                                                                                    runtimeInputs = [ pkgs.coreutils pkgs.git ] ;
                                                                                                    text =
                                                                                                        ''
                                                                                                            if [ -d "$GIT_DIR/rebase-apply" ] || [ -d "$GIT_DIR/rebase-merge" ]
                                                                                                            then
                                                                                                                exec $( dirname "$0" )/post-commit
                                                                                                            fi
                                                                                                        '' ;
                                                                                                } ;
                                                                                        post-commit =
                                                                                            pkgs.writeShellApplication
                                                                                                {
                                                                                                    name = "post-commit" ;
                                                                                                    runtimeInputs = [ pkgs.coreutils pkgs.git ] ;
                                                                                                    text =
                                                                                                        ''
                                                                                                            while ! git push origin HEAD
                                                                                                            do
                                                                                                                sleep 1
                                                                                                            done
                                                                                                        '' ;
                                                                                                } ;
                                                                                        post-commit-private =
                                                                                            pkgs.writeShellApplication
                                                                                                {
                                                                                                    name = "post-commit" ;
                                                                                                    runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.nixos-rebuild ] ;
                                                                                                    text =
                                                                                                        ''
                                                                                                            while ! git push origin HEAD
                                                                                                            do
                                                                                                                sleep 1
                                                                                                            done
                                                                                                            BRANCH="$( git rev-parse --abbrev-ref HEAD )"
                                                                                                            if [[ "$BRANCH" == scratch/* ]]
                                                                                                            then
                                                                                                                nixos-rebuild build-vm --flake .#myhost --override-input personal "$( "$OUT/boot/repository/personal" )/work-tree" --override-input secrets "$( "$OUT/boot/repository/age-secrets" )/work-tree" --override-input visitor "$( "$OUT/boot/repository/visitor" )/work-tree"
                                                                                                                mv result ..
                                                                                                            if [[ "$BRANCH" == sub/* ]]
                                                                                                            then
                                                                                                                nixos-rebuild build-vm --flake .#myhost --update-input personal --update-input secrets --update-input visitor
                                                                                                                mv result ..
                                                                                                            if [[ "$BRANCH" == issue/* ]]
                                                                                                            then
                                                                                                                nixos-rebuild build-vm --flake .#myhost
                                                                                                                mv result ..
                                                                                                            if [[ "$BRANCH" == milestone/* ]]
                                                                                                            then
                                                                                                                nixos-rebuild build-vm-with-bootloader --flake .#myhost
                                                                                                                mv result ..
                                                                                                            elif [ "$BRANCH" == "development" ]
                                                                                                            then
                                                                                                                sudo nixos-rebuild test --flake .#myhost
                                                                                                            elif [ "$BRANCH" == "main" ]
                                                                                                            then
                                                                                                                sudo nixos-rebuild switch --flake .#myhost
                                                                                                            fi
                                                                                                        '' ;
                                                                                                } ;
                                                                                        pre-commit =
                                                                                            pkgs.writeShellApplication
                                                                                                {
                                                                                                    name = "pre-commit" ;
                                                                                                    runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.libuuid ] ;
                                                                                                    text =
                                                                                                        ''
                                                                                                            BRANCH="$( git rev-parse --abbrev-ref HEAD )"
                                                                                                            if [[ "$BRANCH" != scratch/* ]]
                                                                                                            then
                                                                                                                git checkout -b "scratch/$( uuidgen )"
                                                                                                            fi
                                                                                                        '' ;
                                                                                                } ;
                                                                                        pre-commit-private =
                                                                                            pkgs.writeShellApplication
                                                                                                {
                                                                                                    name = "pre-commit" ;
                                                                                                    runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.nixos-rebuild ] ;
                                                                                                    text =
                                                                                                        ''
                                                                                                            BRANCH="$( git rev-parse --abbrev-ref HEAD )"
                                                                                                            if [ -z "$BRANCH" ]
                                                                                                            then
                                                                                                                BRANCH="scratch/$( uuidgen )"
                                                                                                                git checkout -b "$BRANCH"
                                                                                                            elif [[ "$BRANCH" == scratch/* ]]
                                                                                                            then
                                                                                                                (
                                                                                                                    fun() {
                                                                                                                        env -i HOME="$HOME" PATH="$PATH" GIT_DIR="$( "$1" )/git" GIT_WORK_TREE="$( "$1" )/work-tree" git commit -am "" --allow-empty --allow-empty-message < /dev/null
                                                                                                                        env -i HOME="$HOME" PATH="$PATH" GIT_DIR="$( "$1" )/git" GIT_WORK_TREE="$( "$1" )/work-tree" git rev-parse HEAD > "inputs.$2.commit" < /dev/null
                                                                                                                        git add "inputs.$2.commit"
                                                                                                                    }
                                                                                                                    fun "$OUT/boot/repository/personal" personal
                                                                                                                    fun "$OUT/boot/repository/age-secrets" secrets
                                                                                                                    fun "$OUT/boot/repository/visitor" visitor
                                                                                                                )
                                                                                                            fi
                                                                                                            date +%s > "$GIT_WORK_TREE/current-time.nix"
                                                                                                            git add "$GIT_WORK_TREE/current-time.nix"
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
                                                                                        in
                                                                                            {
                                                                                                age-secrets =
                                                                                                    ignore :
                                                                                                        {
                                                                                                            runtimeInputs = [ pkgs.coreutils pkgs.git ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    export GIT_DIR="$1/git"
                                                                                                                    export GIT_WORK_TREE="$1/work-tree"
                                                                                                                    mkdir --parents "$1"
                                                                                                                    mkdir --parents "$GIT_DIR"
                                                                                                                    mkdir --parents "$GIT_WORK_TREE"
                                                                                                                    cat > "$1/.envrc" <<EOF
                                                                                                                    export GIT_DIR="$GIT_DIR"
                                                                                                                    export GIT_WORK_TREE="$GIT_WORK_TREE"
                                                                                                                    EOF
                                                                                                                    git init 2>&1
                                                                                                                    git config alias.scratch "!${ scratch }/bin/scratch"
                                                                                                                    git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F $( "$2/boot/dot-ssh/boot/config" )"
                                                                                                                    git config user.name "${ config.personal.description }"
                                                                                                                    git config user.email "${ config.personal.email }"
                                                                                                                    ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                                                    ln --symbolic ${ pre-commit }/bin/pre-commit "$GIT_DIR/hooks/pre-commit"
                                                                                                                    git remote add origin ${ config.personal.repository.age-secrets.remote }
                                                                                                                    git fetch origin ${ config.personal.repository.age-secrets.branch } 2>&1
                                                                                                                    git checkout ${ config.personal.repository.age-secrets.branch } 2>&1
                                                                                                                '' ;
                                                                                                        } ;
                                                                                                pass-secrets =
                                                                                                    ignore :
                                                                                                        {
                                                                                                            runtimeInputs = [ pkgs.coreutils pkgs.git ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    export GIT_DIR="$1/git"
                                                                                                                    export GIT_WORK_TREE="$1/work-tree"
                                                                                                                    mkdir --parents "$1"
                                                                                                                    mkdir --parents "$GIT_DIR"
                                                                                                                    mkdir --parents "$GIT_WORK_TREE"
                                                                                                                    cat > "$1/.envrc" <<EOF
                                                                                                                    export GIT_DIR="$GIT_DIR"
                                                                                                                    export GIT_WORK_TREE="$GIT_WORK_TREE"
                                                                                                                    EOF
                                                                                                                    git init 2>&1
                                                                                                                    git config alias.scratch "!${ scratch }/bin/scratch"
                                                                                                                    git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F $( "$2/boot/dot-ssh/boot/config" )"
                                                                                                                    git config user.name "${ config.personal.description }"
                                                                                                                    git config user.email "${ config.personal.email }"
                                                                                                                    ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                                                    ln --symbolic ${ pre-commit }/bin/pre-commit "$GIT_DIR/hooks/pre-commit"
                                                                                                                    git remote add origin ${ config.personal.repository.pass-secrets.remote }
                                                                                                                    git fetch origin ${ config.personal.repository.pass-secrets.branch } 2>&1
                                                                                                                    git checkout ${ config.personal.repository.pass-secrets.branch } 2>&1
                                                                                                                '' ;
                                                                                                        } ;
                                                                                                personal =
                                                                                                    ignore :
                                                                                                        {
                                                                                                            runtimeInputs = [ pkgs.coreutils pkgs.git ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    export GIT_DIR="$1/git"
                                                                                                                    export GIT_WORK_TREE="$1/work-tree"
                                                                                                                    mkdir --parents "$1"
                                                                                                                    cat > "$1/.envrc" <<EOF
                                                                                                                    export GIT_DIR="$GIT_DIR"
                                                                                                                    export GIT_WORK_TREE="$GIT_WORK_TREE"
                                                                                                                    EOF
                                                                                                                    mkdir "$GIT_DIR"
                                                                                                                    mkdir "$GIT_WORK_TREE"
                                                                                                                    git init 2>&1
                                                                                                                    git config alias.scratch "!${ scratch }/bin/scratch"
                                                                                                                    git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F $( "$2/boot/dot-ssh/viktor/config" )"
                                                                                                                    git config user.name "Victor Danek"
                                                                                                                    git config user.email "viktordanek10@gmail.com"
                                                                                                                    ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                                                    ln --symbolic ${ pre-commit }/bin/pre-commit "$GIT_DIR/hooks/pre-commit"
                                                                                                                    git remote add origin git@github.com:viktordanek/personal.git
                                                                                                                    git fetch origin main 2>&1
                                                                                                                    git checkout origin/main 2>&1
                                                                                                                '' ;
                                                                                                        } ;
                                                                                                private =
                                                                                                    ignore :
                                                                                                        {
                                                                                                            runtimeInputs = [ pkgs.coreutils pkgs.git ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    export GIT_DIR="$1/git"
                                                                                                                    export GIT_WORK_TREE="$1/work-tree"
                                                                                                                    mkdir --parents "$1"
                                                                                                                    cat > "$1/.envrc" <<EOF
                                                                                                                    export OUT="$2"
                                                                                                                    export GIT_DIR="$GIT_DIR"
                                                                                                                    export GIT_WORK_TREE="$GIT_WORK_TREE"
                                                                                                                    EOF
                                                                                                                    mkdir --parents "$GIT_DIR"
                                                                                                                    mkdir --parents "$GIT_WORK_TREE"
                                                                                                                    git init 2>&1
                                                                                                                    git config alias.scratch "!${ scratch }/bin/scratch"
                                                                                                                    git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F $( "$2/boot/dot-ssh/boot/config" )"
                                                                                                                    git config user.name "${ config.personal.description }"
                                                                                                                    git config user.email "${ config.personal.email }"
                                                                                                                    ln --symbolic ${ post-commit-private }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                                                    ln --symbolic ${ post-commit-private }/bin/post-commit "$GIT_DIR/hooks/post-rebase"
                                                                                                                    ln --symbolic ${ pre-commit-private }/bin/pre-commit "$GIT_DIR/hooks/pre-commit"
                                                                                                                    git remote add origin mobile:private
                                                                                                                    git fetch origin 2>&1
                                                                                                                    git checkout origin/main 2>&1
                                                                                                                '' ;
                                                                                                        } ;
                                                                                                visitor =
                                                                                                    ignore :
                                                                                                        {
                                                                                                            runtimeInputs = [ pkgs.coreutils pkgs.git ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    export GIT_DIR="$1/git"
                                                                                                                    export GIT_WORK_TREE="$1/work-tree"
                                                                                                                    mkdir --parents "$1"
                                                                                                                    cat > "$1/.envrc" <<EOF
                                                                                                                    export GIT_DIR="$GIT_DIR"
                                                                                                                    export GIT_WORK_TREE="$GIT_WORK_TREE"
                                                                                                                    EOF
                                                                                                                    mkdir "$GIT_DIR"
                                                                                                                    mkdir "$GIT_WORK_TREE"
                                                                                                                    git init 2>&1
                                                                                                                    git config alias.scratch "!${ scratch }/bin/scratch"
                                                                                                                    git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F $( "$2/boot/dot-ssh/viktor/config" )"
                                                                                                                    git config user.name "Victor Danek"
                                                                                                                    git config user.email "viktordanek10@gmail.com"
                                                                                                                    ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                                                    ln --symbolic ${ pre-commit }/bin/pre-commit "$GIT_DIR/hooks/pre-commit"
                                                                                                                    git remote add origin git@github.com:viktordanek/visitor.git
                                                                                                                    git fetch origin main 2>&1
                                                                                                                    git checkout origin/main 2>&1
                                                                                                                '' ;
                                                                                                        } ;
                                                                                            } ;
                                                                            } ;
                                                                    } ;
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
