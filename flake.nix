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
                                                                                            ROOT_DIR=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" config.personal.name config.personal.stash ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toJSON ( builtins.readFile config.personal.current-time ) ) ) ) ] ] ) }
                                                                                            mkdir --parents "$ROOT_DIR"
                                                                                            exec 200> "$ROOT_DIR/lock"
                                                                                            flock -s 200
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
                                                                    (
                                                                        let
                                                                            crypt =
                                                                                branch : commit-message : run-inputs : run-text : ignore :
                                                                                    {
                                                                                        runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.git-crypt ] ;
                                                                                        text =
                                                                                            let
                                                                                                application =
                                                                                                    pkgs.writeShellApplication
                                                                                                        {
                                                                                                            name = "application" ;
                                                                                                            runtimeInputs = [ pkgs.coreutils pkgs.flock pkgs.git pkgs.git-crypt ] ;
                                                                                                            text =
                                                                                                                ''
                                                                                                                    exec 201> "$ROOT/lock"
                                                                                                                    flock -x 201
                                                                                                                    if git fetch origin ${ branch } 2>&1
                                                                                                                    then
                                                                                                                        git checkout ${ branch } 2>&1
                                                                                                                        git-crypt unlock
                                                                                                                    else
                                                                                                                        git checkout -b ${ branch } 2>&1
                                                                                                                        git-crypt init 2>&1
                                                                                                                        git-crypt add-gpg-user B4A123BD34C93E5EDE57CCB466DF829A8C7285A2
                                                                                                                        git-crypt unlock
                                                                                                                        cat > "$GIT_WORK_TREE/.gitattributes" <<EOF
                                                                                                                    "flag" filter=git-crypt diff=git-crypt
                                                                                                                    "profile/**" filter=git-crypt diff=git-crypt
                                                                                                                    EOF
                                                                                                                        git add .gitattributes
                                                                                                                        date +%s > "$GIT_WORK_TREE/flag"
                                                                                                                        git commit -am "Initialized Branch"
                                                                                                                    fi
                                                                                                                    ${ pkgs.writeShellApplication { name = "run" ; runtimeInputs = run-inputs ; text = run-text ; } }/bin/run
                                                                                                                    git add profile
                                                                                                                    if git commit -am "${ commit-message }"
                                                                                                                    then
                                                                                                                        while ! git push origin HEAD
                                                                                                                        do
                                                                                                                            echo there was a problem pushing >&2
                                                                                                                            sleep 1
                                                                                                                        done
                                                                                                                    fi
                                                                                                                    flock -u 201
                                                                                                                '' ;
                                                                                                        } ;
                                                                                                in
                                                                                                    ''
                                                                                                        ROOT="$1"
                                                                                                        GIT_DIR="$ROOT/git"
                                                                                                        GIT_WORK_TREE="$ROOT/work-tree"
                                                                                                        GNUPGHOME="$( "$2/boot/dot-gnupg/config" )"
                                                                                                        export GNUPGHOME
                                                                                                        mkdir "$ROOT"
                                                                                                        cat > "$ROOT/.envrc" <<EOF
                                                                                                        export ROOT="$ROOT"
                                                                                                        export GNUPGHOME="$GNUPGHOME"
                                                                                                        export GIT_DIR="$GIT_DIR"
                                                                                                        export GIT_WORK_TREE="$GIT_WORK_TREE"
                                                                                                        EOF
                                                                                                        mkdir "$GIT_DIR"
                                                                                                        mkdir "$GIT_WORK_TREE"
                                                                                                        export GIT_DIR
                                                                                                        export GIT_WORK_TREE
                                                                                                        git init 2>&1
                                                                                                        git config alias.application "!${ application }/bin/application"
                                                                                                        git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F $( "$2/boot/dot-ssh/boot/config" )"
                                                                                                        git config user.email "${ config.personal.email }"
                                                                                                        git config user.name "${ config.personal.description }"
                                                                                                        git remote add origin git@github.com:AFnRFCb7/9f41f49f-5426-4287-9a91-7e2afadfd79a.git
                                                                                                    '' ;
                                                                                    } ;
                                                                            in
                                                                                {
                                                                                    boot =
                                                                                        {
                                                                                            brave =
                                                                                                {
                                                                                                    emory =
                                                                                                        crypt
                                                                                                            "ee9af81a-425b-4229-a79b-4984cb7041b8"
                                                                                                            "brave session ${ config.personal.current-time }"
                                                                                                            [ pkgs.brave ]
                                                                                                            ''
                                                                                                                export HOME="$GIT_WORK_TREE/profile"
                                                                                                                export BRAVE_USER_DATA_DIR="$HOME/.config/BraveSoftware/BraveBrowser"
                                                                                                                brave
                                                                                                            '' ;
                                                                                                } ;
                                                                                            chromium =
                                                                                                {
                                                                                                    emory =
                                                                                                        crypt
                                                                                                            "1ffa9bce-46ca-4690-b979-ff65a99d6d60"
                                                                                                            "chrome session ${ config.personal.current-time }"
                                                                                                            [ pkgs.chromium ]
                                                                                                            ''
                                                                                                                export HOME="$GIT_WORK_TREE/profile"
                                                                                                                chromium --user-data-dir "$HOME/.config/chromium"
                                                                                                            '' ;
                                                                                                } ;
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
                                                                                                                        age --decrypt --identity ${ config.personal.agenix } --output "$1" "${ secrets.outPath }/ownertrust.asc.age"
                                                                                                                        chmod 0400 "$1"
                                                                                                                    '' ;
                                                                                                            } ;
                                                                                                    secret-keys =
                                                                                                        ignore :
                                                                                                            {
                                                                                                                runtimeInputs = [ pkgs.age pkgs.coreutils ] ;
                                                                                                                text =
                                                                                                                    ''
                                                                                                                        age --decrypt --identity ${ config.personal.agenix } --output "$1" "${ secrets.outPath }/secret-keys.asc.age"
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
                                                                                            firefox =
                                                                                                {
                                                                                                    emory =
                                                                                                        crypt
                                                                                                            "800aec06-545e-4d53-83b6-8cf0266360f7"
                                                                                                            "firefox session ${ config.personal.current-time }"
                                                                                                            [ pkgs.firefox ]
                                                                                                            ''
                                                                                                                export HOME="$GIT_WORK_TREE/profile"
                                                                                                                firefox
                                                                                                            '' ;
                                                                                                } ;
                                                                                            gnucash =
                                                                                                {
                                                                                                    emory =
                                                                                                        crypt
                                                                                                            "66baea75-1780-4c1d-a7c3-dd644c47944c"
                                                                                                            "gnucash session ${ config.personal.current-time }"
                                                                                                            [ pkgs.gnucash ]
                                                                                                            ''
                                                                                                                export HOME="$GIT_WORK_TREE/profile"
                                                                                                                gnucash "$HOME/gnucash.gnucash"
                                                                                                            '' ;
                                                                                                    me =
                                                                                                        crypt
                                                                                                            "a5192e42-2810-4808-8308-cf742e5bf080"
                                                                                                            "gnucash session ${ config.personal.current-time }"
                                                                                                            [ pkgs.gnucash ]
                                                                                                            ''
                                                                                                                export HOME="$GIT_WORK_TREE/profile/home"
                                                                                                                mkdir --parents "$HOME"
                                                                                                                mkdir --parents "$GIT_WORK_TREE/profile/gnucash"
                                                                                                                gnucash "$GIT_WORK_TREE/profile/gnucash/gnucash.gnucash"
                                                                                                            '' ;
                                                                                                } ;
                                                                                            pass =
                                                                                                let
                                                                                                    expiryn =
                                                                                                        pkgs.writeShellApplication
                                                                                                            {
                                                                                                                name = "expiryn" ;
                                                                                                                runtimeInputs = [ pkgs.bc pkgs.coreutils pkgs.pass ] ;
                                                                                                                text =
                                                                                                                    ''
                                                                                                                        EXPIRY=$( pass expiry )
                                                                                                                        NUMB=$( echo "$EXPIRY" | wc --lines )
                                                                                                                        ceil_sqrt=$( echo "sqrt($NUMB)" | bc -l | awk '{printf("%d\n", ($1 == int($1)) ? $1 : int($1)+1)}')
                                                                                                                        echo "$EXPIRY" | while read -r KEY
                                                                                                                        do
                                                                                                                            echo "$RANDOM" "$KEY"
                                                                                                                        done | sort --key 1 --numeric | cut --fields 2 --delimiter " " | head --lines "$ceil_sqrt"
                                                                                                                    '' ;
                                                                                                            } ;
                                                                                                    expiry =
                                                                                                        pkgs.writeShellApplication
                                                                                                            {
                                                                                                                name = "expiry" ;
                                                                                                                runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.pass ] ;
                                                                                                                text =
                                                                                                                    ''
                                                                                                                        GIT_DIR="$GIT_ROOT/work-tree/.git"
                                                                                                                        export GIT_DIR
                                                                                                                        GIT_WORK_TREE="$GIT_ROOT/work-tree"
                                                                                                                        export GIT_WORK_TREE
                                                                                                                        PASSWORD_STORE_DIR="$GIT_ROOT/work-tree"
                                                                                                                        export PASSWORD_STORE_DIR
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
                                                                                                            warn =
                                                                                                                pkgs.writeShellApplication
                                                                                                                    {
                                                                                                                        name = "warn" ;
                                                                                                                        runtimeInputs = [ pkgs.coreutils pkgs.gnupg ] ;
                                                                                                                        text =
                                                                                                                            ''
                                                                                                                                export GNUPGHOME="$GNUPGHOME"
                                                                                                                                ENTRY=${ builtins.concatStringsSep "" [ "$" "{" "1:-" "}" ]}
                                                                                                                                FILE=${ builtins.concatStringsSep "" [ "$" "{" "PASSWORD_STORE_DIR" "}" ]}/${ builtins.concatStringsSep "" [ "$" "{" "ENTRY" "}" ] }.gpg

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

                                                                                                                                # Get current trusted key full fingerprints
                                                                                                                                # mapfile -t CURRENT_FPRS < <(
                                                                                                                                #   gpg --with-colons --list-keys 2>/dev/null \
                                                                                                                                #   | awk -F: '/^fpr:/ { print $10 }'
                                                                                                                                # )
                                                                                                                                mapfile -t CURRENT_FPRS < "$PASSWORD_STORE_DIR/.gpg-id"


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
                                                                                                        {
                                                                                                            archive =
                                                                                                                ignore :
                                                                                                                    {
                                                                                                                        runtimeInputs = [ pkgs.coreutils pkgs.gnused ] ;
                                                                                                                        text =
                                                                                                                            ''
                                                                                                                                mkdir "$1"
                                                                                                                                GIT_ROOT="$( "$2/boot/repository/pass-secrets" )"
                                                                                                                                GIT_WORK_TREE="$GIT_ROOT/work-tree"
                                                                                                                                cat > "$1/.envrc" <<EOF
                                                                                                                                export GIT_DIR="$GIT_ROOT/work-tree/.git"
                                                                                                                                export GIT_WORK_TREE="$GIT_WORK_TREE"
                                                                                                                                export PASSWORD_STORE_DIR="$GIT_WORK_TREE"
                                                                                                                                export PASSWORD_STORE_GPG_OPTS="--homedir $( "$2/boot/dot-gnupg/config" )"
                                                                                                                                export PASSWORD_STORE_ENABLE_EXTENSIONS=true
                                                                                                                                export PASSWORD_STORE_EXTENSIONS_DIR="$1"
                                                                                                                                EOF
                                                                                                                                sed -e "s#\$GIT_ROOT#$GIT_ROOT#" -e "w$1/expiry.bash" ${ expiry }/bin/expiry
                                                                                                                                chmod 0500 "$1/expiry.bash"
                                                                                                                                ln --symbolic ${ phonetic }/bin/phonetic "$1/phonetic.bash"
                                                                                                                                sed -e "s#\$GNUPGHOME#$( "$2/boot/dot-gnupg/config" )#" -e "s#\$PASSWORD_STORE_DIR#$GIT_WORK_TREE#" -e "w$1/warn.bash" ${ warn }/bin/warn
                                                                                                                                chmod 0500 "$1/warn.bash"
                                                                                                                                ln --symbolic ${ expiryn }/bin/expiryn "$1/expiryn.bash"
                                                                                                                            '' ;
                                                                                                                    } ;
                                                                                                            passphrases =
                                                                                                                ignore :
                                                                                                                    {
                                                                                                                        runtimeInputs = [ pkgs.coreutils pkgs.gnused ] ;
                                                                                                                        text =
                                                                                                                            ''
                                                                                                                                mkdir "$1"
                                                                                                                                GIT_ROOT="$( "$2/boot/repository/passphrases" )"
                                                                                                                                GIT_WORK_TREE="$GIT_ROOT/work-tree"
                                                                                                                                cat > "$1/.envrc" <<EOF
                                                                                                                                export GIT_DIR="$GIT_ROOT/work-tree/.git"
                                                                                                                                export GIT_WORK_TREE="$GIT_WORK_TREE"
                                                                                                                                export PASSWORD_STORE_DIR="$GIT_WORK_TREE"
                                                                                                                                export PASSWORD_STORE_GPG_OPTS="--homedir $( "$2/boot/dot-gnupg/config" )"
                                                                                                                                export PASSWORD_STORE_ENABLE_EXTENSIONS=true
                                                                                                                                export PASSWORD_STORE_EXTENSIONS_DIR="$1"
                                                                                                                                EOF
                                                                                                                                sed -e "s#\$GIT_ROOT#$GIT_ROOT#" -e "w$1/expiry.bash" ${ expiry }/bin/expiry
                                                                                                                                chmod 0500 "$1/expiry.bash"
                                                                                                                                ln --symbolic ${ phonetic }/bin/phonetic "$1/phonetic.bash"
                                                                                                                                sed -e "s#\$GNUPGHOME#$( "$2/boot/dot-gnupg/config" )#" -e "s#\$PASSWORD_STORE_DIR#$GIT_WORK_TREE#" -e "w$1/warn.bash" ${ warn }/bin/warn
                                                                                                                                chmod 0500 "$1/warn.bash"
                                                                                                                                ln --symbolic ${ expiryn }/bin/expiryn "$1/expiryn.bash"
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
                                                                                                                        OUT=$( git config --get application.url )
                                                                                                                        while ! git push origin HEAD
                                                                                                                        do
                                                                                                                            sleep 1
                                                                                                                        done
                                                                                                                        BRANCH="$( git rev-parse --abbrev-ref HEAD )"
                                                                                                                        if [[ "$BRANCH" == scratch/* ]]
                                                                                                                        then
                                                                                                                            nixos-rebuild build-vm --flake .#myhost --override-input personal "$( "$OUT/boot/repository/personal" )/work-tree" --override-input secrets "$( "$OUT/boot/repository/age-secrets" )/work-tree" --override-input visitor "$( "$OUT/boot/repository/visitor" )/work-tree"
                                                                                                                            mv result ..
                                                                                                                        elif [[ "$BRANCH" == sub/* ]]
                                                                                                                        then
                                                                                                                            nixos-rebuild build-vm --flake .#myhost --update-input personal --update-input secrets --update-input visitor
                                                                                                                            mv result ..
                                                                                                                        elif [[ "$BRANCH" == issue/* ]]
                                                                                                                        then
                                                                                                                            nixos-rebuild build-vm --flake .#myhost
                                                                                                                            mv result ..
                                                                                                                        elif [[ "$BRANCH" == milestone/* ]]
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
                                                                                                                                    env -i HOME="$HOME" PATH="$PATH" GIT_DIR="$1/git" GIT_WORK_TREE="$1/work-tree" git commit -am "" --allow-empty --allow-empty-message < /dev/null
                                                                                                                                    env -i HOME="$HOME" PATH="$PATH" GIT_DIR="$1/git" GIT_WORK_TREE="$1/work-tree" git rev-parse HEAD > "inputs.$2.commit" < /dev/null
                                                                                                                                    git add "inputs.$2.commit"
                                                                                                                                }
                                                                                                                                fun "$( "$OUT/boot/repository/personal" )" personal
                                                                                                                                fun "$( "$OUT/boot/repository/age-secrets" )" secrets
                                                                                                                                fun "$( "$OUT/boot/repository/visitor" )" visitor
                                                                                                                            )
                                                                                                                        fi
                                                                                                                        date +%s > "$GIT_WORK_TREE/current-time.nix"
                                                                                                                        git add "$GIT_WORK_TREE/current-time.nix"
                                                                                                                    '' ;
                                                                                                            } ;
                                                                                                    promote =
                                                                                                        pkgs.writeShellApplication
                                                                                                            {
                                                                                                                name = "promote" ;
                                                                                                                runtimeInputs = [ pkgs.coreutils pkgs.nixos-rebuild pkgs.nix ] ;
                                                                                                                text =
                                                                                                                    ''
                                                                                                                        rm --force nixos.qcow2 result
                                                                                                                        OUT=$( git config --get application.url )
                                                                                                                        git checkout -b "scratch/$( uuidgen )"
                                                                                                                        case "$1" in
                                                                                                                            0)
                                                                                                                                fun() {
                                                                                                                                    env -i HOME="$HOME" PATH="$PATH" GIT_DIR="$1/git" GIT_WORK_TREE="$1/work-tree" git commit -am "" --allow-empty --allow-empty-message < /dev/null
                                                                                                                                    env -i HOME="$HOME" PATH="$PATH" GIT_DIR="$1/git" GIT_WORK_TREE="$1/work-tree" git rev-parse HEAD > "inputs.$2.commit" < /dev/null
                                                                                                                                    git add "inputs.$2.commit"
                                                                                                                                }
                                                                                                                                fun "$( "$OUT/boot/repository/personal" )" personal
                                                                                                                                fun "$( "$OUT/boot/repository/age-secrets" )" secrets
                                                                                                                                fun "$( "$OUT/boot/repository/visitor" )" visitor
                                                                                                                                nixos-rebuild build-vm --flake ./work-tree.#myhost --override-input personal "$( "$OUT/boot/repository/personal" )/work-tree" --override-input secrets "$( "$OUT/boot/repository/age-secrets" )/work-tree" --override-input visitor "$( "$OUT/boot/repository/visitor" )/work-tree"
                                                                                                                                git commit -am "promoted to $1" --allow-empty
                                                                                                                                result/bin/run-nixos-vm
                                                                                                                                ;;
                                                                                                                            1)
                                                                                                                                cd work-tree
                                                                                                                                nix flake lock --update-input personal --update-input secrets --update-input visitor
                                                                                                                                nixos-rebuild build-vm --flake .#myhost
                                                                                                                                git commit -am "promoted to $1" --allow-empty
                                                                                                                                mv result ..
                                                                                                                                cd ..
                                                                                                                                result/bin/run-nixos-vm
                                                                                                                                ;;
                                                                                                                            2)
                                                                                                                                nixos-rebuild build-vm --flake ./work-tree#myhost
                                                                                                                                git commit -am "promoted to $1" --allow-empty
                                                                                                                                result/bin/run-nixos-vm
                                                                                                                                ;;
                                                                                                                            3)
                                                                                                                                nix-collect-garbage
                                                                                                                                nixos-rebuild build-vm-with-bootloader --flake ./work-tree#myhost
                                                                                                                                git commit -am "promoted to $1" --allow-empty
                                                                                                                                result/bin/run-nixos-vm
                                                                                                                                ;;
                                                                                                                            4)
                                                                                                                                date +%s > work-tree/current-time.nix
                                                                                                                                sudo nixos-rebuild test --flake .work-tree/#myhost
                                                                                                                                git commit -am "promoted to $1" --allow-empty
                                                                                                                                SCRATCH_BRANCH="scratch/$( uuidgen )"
                                                                                                                                git checkout -b "$SCRATCH_BRANCH"
                                                                                                                                git fetch origin development
                                                                                                                                git diff origin/development
                                                                                                                                git reset --soft origin/development
                                                                                                                                git commit -a
                                                                                                                                git checkout development
                                                                                                                                git rebase origin/development
                                                                                                                                git rebase "$SCRATCH_BRANCH"
                                                                                                                                git push origin HEAD
                                                                                                                                ;;
                                                                                                                            5)
                                                                                                                                git fetch origin development
                                                                                                                                git fetch origin main
                                                                                                                                git checkout main
                                                                                                                                git rebase origin/main
                                                                                                                                git merge --ff-only development
                                                                                                                                sudo nixos-rebuild switch --flake .work-tree/#myhost
                                                                                                                                git push origin HEAD
                                                                                                                                nix-collect-garbage
                                                                                                                                ;;
                                                                                                                            *)
                                                                                                                                echo wrong
                                                                                                                                exit 64
                                                                                                                                ;;
                                                                                                                        esac
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
                                                                                                                            let
                                                                                                                                gnupg-generate-key =
                                                                                                                                    pkgs.writeShellApplication
                                                                                                                                        {
                                                                                                                                            name = "gnupg-generate-key" ;
                                                                                                                                            runtimeInputs = [ pkgs.age pkgs.coreutils pkgs.gnupg ] ;
                                                                                                                                            text =
                                                                                                                                                let
                                                                                                                                                    gpg-key-conf =
                                                                                                                                                        builtins.toFile
                                                                                                                                                            "gpg-key.conf"
                                                                                                                                                            ''
                                                                                                                                                                Key-Type: RSA
                                                                                                                                                                Key-Length: 4096
                                                                                                                                                                Subkey-Type: RSA
                                                                                                                                                                Subkey-Length: 4096
                                                                                                                                                                Name-Real: ${ config.personal.description }
                                                                                                                                                                Name-Email: ${ config.personal.email }
                                                                                                                                                                Name-Comment:  Key Created ${ builtins.readFile config.personal.current-time }
                                                                                                                                                                Expire-Date: 6m
                                                                                                                                                                %commit
                                                                                                                                                            '' ;
                                                                                                                                                    in
                                                                                                                                                        ''
                                                                                                                                                            gpg --batch --generate-key ${ gpg-key-conf }
                                                                                                                                                            readarray -t KEYS < <(gpg --with-colons --fixed-list-mode --list-keys | awk -F: '/^pub/ { print $5, $7 }' | sort -k2 | awk '{ print $1 }')
                                                                                                                                                            TARGET_KEY_ID="${ builtins.concatStringsSep "" [ "$" "{" "KEYS[-1]" "}" ] }"
                                                                                                                                                            SIGNING_KEY_ID="${ builtins.concatStringsSep "" [ "$" "{" "KEYS[-2]" "}" ] }"
                                                                                                                                                            gpg --local-user "$SIGNING_KEY_ID" --sign-key "$TARGET_KEY_ID"
                                                                                                                                                            gpg --check-sigs "$TARGET_KEY_ID"
                                                                                                                                                            gpg --update-trustdb
                                                                                                                                                            gpg --list-secret-keys --with-subkey-fingerprint
                                                                                                                                                            # shellcheck disable=SC2046
                                                                                                                                                            gpg --export-secret-keys --armor $(gpg --list-secret-keys --with-colons | awk -F: '/^sec/ { print $5 }') | age --armor --recipient "$( age-keygen -y < ${ config.personal.agenix } )" --output work-tree/secret-keys.asc.age
                                                                                                                                                            gpg --export-ownertrust --armor | age --armor --recipient "$( age-keygen -y < ${ config.personal.agenix } )" --output work-tree/ownertrust.asc.age
                                                                                                                                                            git add secret-keys.asc.age ownertrust.asc.age
                                                                                                                                                            git commit -am "CHORE:  Generated a new GNUPG KEY"
                                                                                                                                                            git push origin HEAD
                                                                                                                                                        '' ;
                                                                                                                                        } ;
                                                                                                                                    passphrase =
                                                                                                                                        pkgs.writeShellApplication
                                                                                                                                            {
                                                                                                                                                name = "passphrase" ;
                                                                                                                                                runtimeInputs = [ pkgs.openssh ] ;
                                                                                                                                                text =
                                                                                                                                                    ''
                                                                                                                                                        ${ pkgs.openssh }/bin/ssh -F "$DOT_SSH" mobile cat passphrase
                                                                                                                                                    '' ;
                                                                                                                                            } ;
                                                                                                                                in
                                                                                                                                    ''
                                                                                                                                        export GIT_DIR="$1/git"
                                                                                                                                        export GIT_WORK_TREE="$1/work-tree"
                                                                                                                                        mkdir --parents "$1"
                                                                                                                                        mkdir --parents "$GIT_DIR"
                                                                                                                                        mkdir --parents "$GIT_WORK_TREE"
                                                                                                                                        cat > "$1/.envrc" <<EOF
                                                                                                                                        DOT_SSH="\$( "$2/boot/dot-ssh/boot/config" )"
                                                                                                                                        export DOT_SSH
                                                                                                                                        GNUPGHOME="\$( "$2/boot/dot-gnupg/config" )"
                                                                                                                                        export GNUPGHOME
                                                                                                                                        export GIT_DIR="$GIT_DIR"
                                                                                                                                        export GIT_WORK_TREE="$GIT_WORK_TREE"
                                                                                                                                        EOF
                                                                                                                                        git init 2>&1
                                                                                                                                        git config alias.gnupg-generate-key "!${ gnupg-generate-key }/bin/gnupg-generate-key"
                                                                                                                                        git config alias.passphrase "!${ passphrase }/bin/passphrase"
                                                                                                                                        git config alias.scratch "!${ scratch }/bin/scratch"
                                                                                                                                        git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F $( "$2/boot/dot-ssh/boot/config" )"
                                                                                                                                        git config user.name "${ config.personal.description }"
                                                                                                                                        git config user.email "${ config.personal.email }"
                                                                                                                                        ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                                                                        git remote add origin ${ config.personal.repository.age-secrets.remote }
                                                                                                                                        git fetch origin ${ config.personal.repository.age-secrets.branch } 2>&1
                                                                                                                                        git checkout ${ config.personal.repository.age-secrets.branch } 2>&1
                                                                                                                                    '' ;
                                                                                                                    } ;
                                                                                                            career =
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
                                                                                                                                git remote add origin git@github.com:viktordanek/career.git
                                                                                                                                git fetch origin main 2>&1
                                                                                                                                git checkout origin/main 2>&1
                                                                                                                            '' ;
                                                                                                                    } ;
                                                                                                            passphrases =
                                                                                                                ignore :
                                                                                                                    {
                                                                                                                        runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.pass ] ;
                                                                                                                        text =
                                                                                                                            ''
                                                                                                                                export GIT_WORK_TREE="$1/work-tree"
                                                                                                                                export GIT_DIR="$GIT_WORK_TREE/.git"
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
                                                                                                                                git remote add origin ${ config.personal.repository.pass-secrets.remote }
                                                                                                                                if git fetch origin 60e0f839-8f0e-4568-a522-3c0d5de2e1aa 2>&1
                                                                                                                                then
                                                                                                                                    git checkout 60e0f839-8f0e-4568-a522-3c0d5de2e1aa 2>&1
                                                                                                                                    ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                                                                else
                                                                                                                                    git checkout -b 60e0f839-8f0e-4568-a522-3c0d5de2e1aa 2>&1
                                                                                                                                    export PASSWORD_STORE_DIR="$GIT_WORK_TREE"
                                                                                                                                    pass init B4A123BD34C93E5EDE57CCB466DF829A8C7285A2 2>&1
                                                                                                                                fi
                                                                                                                            '' ;
                                                                                                                    } ;
                                                                                                            pass-secrets =
                                                                                                                ignore :
                                                                                                                    {
                                                                                                                        runtimeInputs = [ pkgs.coreutils pkgs.git ] ;
                                                                                                                        text =
                                                                                                                            ''
                                                                                                                                export GIT_WORK_TREE="$1/work-tree"
                                                                                                                                export GIT_DIR="$GIT_WORK_TREE/.git"
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
                                                                                                                                git config alias.promote "!${ promote }/bin/promote"
                                                                                                                                git config alias.scratch "!${ scratch }/bin/scratch"
                                                                                                                                git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F $( "$2/boot/dot-ssh/boot/config" )"
                                                                                                                                git config user.name "${ config.personal.description }"
                                                                                                                                git config user.email "${ config.personal.email }"
                                                                                                                                git config application.url "$2"
                                                                                                                                ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
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
                                                                                    couple =
                                                                                        {
                                                                                            pass =
                                                                                                {
                                                                                                    secrets =
                                                                                                        ignore :
                                                                                                            {
                                                                                                                runtimeInputs = [ pkgs.coreutils pkgs.gnused ] ;
                                                                                                                text =
                                                                                                                    ''
                                                                                                                        mkdir "$1"
                                                                                                                        GIT_ROOT="$( "$2/couple/repository/passwords" )"
                                                                                                                        GIT_WORK_TREE="$GIT_ROOT/work-tree"
                                                                                                                        cat > "$1/.envrc" <<EOF
                                                                                                                        export GIT_DIR="$GIT_ROOT/work-tree/.git"
                                                                                                                        export GIT_WORK_TREE="$GIT_WORK_TREE"
                                                                                                                        export PASSWORD_STORE_DIR="$GIT_WORK_TREE"
                                                                                                                        export PASSWORD_STORE_GPG_OPTS="--homedir $( "$2/boot/dot-gnupg/config" )"
                                                                                                                        export PASSWORD_STORE_ENABLE_EXTENSIONS=false
                                                                                                                        EOF
                                                                                                                    '' ;
                                                                                                            } ;
                                                                                                } ;
                                                                                            repository =
                                                                                                {
                                                                                                    passwords =
                                                                                                        ignore :
                                                                                                            {
                                                                                                                runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.pass ] ;
                                                                                                                text =
                                                                                                                    ''
                                                                                                                        export GIT_WORK_TREE="$1/work-tree"
                                                                                                                        export GIT_DIR="$GIT_WORK_TREE/.git"
                                                                                                                        mkdir --parents "$1"
                                                                                                                        mkdir --parents "$GIT_DIR"
                                                                                                                        mkdir --parents "$GIT_WORK_TREE"
                                                                                                                        cat > "$1/.envrc" <<EOF
                                                                                                                        export GIT_DIR="$GIT_DIR"
                                                                                                                        export GIT_WORK_TREE="$GIT_WORK_TREE"
                                                                                                                        EOF
                                                                                                                        git init 2>&1
                                                                                                                        git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F $( "$2/boot/dot-ssh/boot/config" )"
                                                                                                                        git config user.name "${ config.personal.description }"
                                                                                                                        git config user.email "${ config.personal.email }"
                                                                                                                        git remote add origin ${ config.personal.repository.pass-secrets.remote }
                                                                                                                        if git fetch origin 5d5683c3-fc44-47a3-aab9-864aba5ad5a7 2>&1
                                                                                                                        then
                                                                                                                            git checkout 5d5683c3-fc44-47a3-aab9-864aba5ad5a7 2>&1
                                                                                                                        else
                                                                                                                            git checkout -b 5d5683c3-fc44-47a3-aab9-864aba5ad5a7 2>&1
                                                                                                                            export PASSWORD_STORE_DIR="$GIT_WORK_TREE"
                                                                                                                            pass init 5d5683c3-fc44-47a3-aab9-864aba5ad5a7 2>&1
                                                                                                                        fi
                                                                                                                    '' ;
                                                                                                            } ;
                                                                                                } ;
                                                                                        } ;
                                                                                    family =
                                                                                        {
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
                                                                                    runtimeInputs = [ pkgs.findutils pkgs.git pkgs.jetbrains.idea-community ] ;
                                                                                    text =
                                                                                        ''
                                                                                            find ${ derivation } -mindepth 1 -type f -exec {} \;
                                                                                            idea-community /home/${ config.personal.name }/${ config.personal.stash }
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
