{
    inputs =
        {
        } ;
    outputs =
        { self } :
            {
                lib =
                    {
                        agenix ,
                        nixpkgs ,
                        secrets ,
                        system ,
                        visitor
                    } :
                        let
                            unimplemented = path : value : builtins.throw "The ${ builtins.typeOf value } visitor for ${ builtins.concatStringsSep " / " ( builtins.map builtins.toJSON path ) } is purposefully unimplemented." ;
                            module =
                                { config , lib , pkgs , ... } :
                                    let
                                        current-time = builtins.toString ( builtins.import config.personal.current-time ) ;
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
                                                                        environment-name ? "environment" ,
                                                                        environment-packages ? pkgs : [ ] ,
                                                                        environment-script ? x : "" ,
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
                                                                                        lambda = path : value : dependency : builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" config.personal.name config.personal.stash "direct" ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString current-time ) ) ) ] ( builtins.map builtins.toJSON path ) [ "mount" dependency ] ] ) ;
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
                                                                                                                                ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString current-time ) ) )
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
                                                                                    environment-name = environment-name ;
                                                                                    environment-packages = environment-packages ;
                                                                                    environment-script = environment-script ;
                                                                                    init-packages = init-packages ;
                                                                                    init-script = init-script ;
                                                                                    name = builtins.concatStringsSep "/" ( builtins.map builtins.toJSON path ) ;
                                                                                    outputs = builtins.sort builtins.lessThan outputs ;
                                                                                    outputs_ = outputs_ ;
                                                                                    path = path ;
                                                                                    release-packages = release-packages ;
                                                                                    release-script = release-script ;
                                                                                    tools = { dependencies = dependencies__ ; outputs = outputs_ ; tree = tree2 ; } ;
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
                                                        let
                                                            application =
                                                                pkgs.writeShellApplication
                                                                    {
                                                                        name = "ssh" ;
                                                                        runtimeInputs = [ pkgs.openssh ] ;
                                                                        text =
                                                                            ''
                                                                                exec ssh -F ${ configuration-file } "$@"
                                                                            '' ;
                                                                    } ;
                                                            in "git config core.sshCommand ${ application }/bin/ssh" ;
                                                in
                                                    {
                                                        couple = { } ;
                                                        family = { } ;
                                                        personal =
                                                            {
                                                                calcurse =
                                                                    ignore :
                                                                        {
                                                                            dependencies = tree : { dot-ssh = tree.personal.dot-ssh.boot ; dot-gnupg = tree.personal.dot-gnupg ; } ;
                                                                            init-packages = pkgs : [ pkgs.coreutils pkgs.git pkgs.git-crypt pkgs.gnupg ] ;
                                                                            init-script =
                                                                                { ... } :
                                                                                    ''
                                                                                        export GIT_DIR=/mount/git
                                                                                        export GIT_WORK_TREE=/mount/work-tree
                                                                                        mkdir "$GIT_DIR"
                                                                                        mkdir "$GIT_WORK_TREE"
                                                                                        export GNUPGHOME=${ foobar [ "personal" "dot-gnupg" ] "config" }
                                                                                        git init 2>&1
                                                                                        ${ ssh-command ( foobar [ "personal" "dot-ssh" "boot" ] "config" ) }
                                                                                        git config user.email ${ config.personal.email }
                                                                                        git config user.name "${ config.personal.description }"
                                                                                        ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                        git remote add origin ${ config.personal.calcurse.remote }
                                                                                        if git fetch origin ${ config.personal.calcurse.branch } 2>&1
                                                                                        then
                                                                                            echo "branch already exists"
                                                                                            git checkout ${ config.personal.calcurse.branch } 2>&1
                                                                                            git-crypt unlock
                                                                                        else
                                                                                            echo "branch does not already exist"
                                                                                            git checkout -b ${ config.personal.calcurse.branch } 2>&1
                                                                                            git-crypt init 2>&1
                                                                                            echo git-crypt add-gpg-user ${ config.personal.calcurse.recipient } 2>&1
                                                                                            git-crypt add-gpg-user ${ config.personal.calcurse.recipient } 2>&1
                                                                                            cat > "$GIT_WORK_TREE/.gitattributes" <<EOF
                                                                                        config/** filter=git-crypt diff=git-crypt
                                                                                        data/** filter=git-crypt diff=git-crypt
                                                                                        EOF
                                                                                            gpg --list-keys
                                                                                            echo before unlock
                                                                                            git-crypt unlock
                                                                                            echo after unlock
                                                                                            mkdir "$GIT_WORK_TREE/config"
                                                                                            touch "$GIT_WORK_TREE/config/.gitkeep"
                                                                                            mkdir "$GIT_WORK_TREE/data"
                                                                                            touch "$GIT_WORK_TREE/data/.gitkeep"
                                                                                            git add .gitattributes config/.gitkeep data/.gitkeep
                                                                                            git commit -m "Initialize git-crypt with .gitattributes" 2>&1
                                                                                            git push origin HEAD 2>&1
                                                                                        fi
                                                                                    '' ;
                                                                            outputs = [ "git" "work-tree" ] ;
                                                                        } ;
                                                                chromium =
                                                                    ignore :
                                                                        {
                                                                            dependencies = tree : { dot-ssh = tree.personal.dot-ssh.boot ; dot-gnupg = tree.personal.dot-gnupg ; } ;
                                                                            init-packages = pkgs : [ pkgs.coreutils pkgs.git pkgs.git-crypt pkgs.gnupg ] ;
                                                                            init-script =
                                                                                { ... } :
                                                                                    ''
                                                                                        export GIT_DIR=/mount/git
                                                                                        export GIT_WORK_TREE=/mount/work-tree
                                                                                        mkdir "$GIT_DIR"
                                                                                        mkdir "$GIT_WORK_TREE"
                                                                                        export GNUPGHOME=${ foobar [ "personal" "dot-gnupg" ] "config" }
                                                                                        git init 2>&1
                                                                                        ${ ssh-command ( foobar [ "personal" "dot-ssh" "boot" ] "config" ) }
                                                                                        git config user.email ${ config.personal.email }
                                                                                        git config user.name "${ config.personal.description }"
                                                                                        ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                        git remote add origin ${ config.personal.chromium.remote }
                                                                                        if git fetch origin ${ config.personal.chromium.branch } 2>&1
                                                                                        then
                                                                                            echo "branch already exists"
                                                                                            git checkout ${ config.personal.chromium.branch } 2>&1
                                                                                            git-crypt unlock
                                                                                        else
                                                                                            echo "branch does not already exist"
                                                                                            git checkout -b ${ config.personal.chromium.branch } 2>&1
                                                                                            git-crypt init 2>&1
                                                                                            echo git-crypt add-gpg-user ${ config.personal.chromium.recipient } 2>&1
                                                                                            git-crypt add-gpg-user ${ config.personal.chromium.recipient } 2>&1
                                                                                            cat > "$GIT_WORK_TREE/.gitattributes" <<EOF
                                                                                        config/** filter=git-crypt diff=git-crypt
                                                                                        data/** filter=git-crypt diff=git-crypt
                                                                                        EOF
                                                                                            gpg --list-keys
                                                                                            git-crypt unlock
                                                                                            mkdir "$GIT_WORK_TREE/config"
                                                                                            touch "$GIT_WORK_TREE/config/.gitkeep"
                                                                                            mkdir "$GIT_WORK_TREE/data"
                                                                                            touch "$GIT_WORK_TREE/data/.gitkeep"
                                                                                            git add .gitattributes config/.gitkeep data/.gitkeep
                                                                                            git commit -m "Initialize git-crypt with .gitattributes" 2>&1
                                                                                            git push origin HEAD 2>&1
                                                                                        fi
                                                                                    '' ;
                                                                            outputs = [ "git" "work-tree" ] ;
                                                                        } ;
                                                                dot-gnupg =
                                                                    ignore :
                                                                        {
                                                                            init-packages = pkgs : [ pkgs.age pkgs.coreutils pkgs.gnupg ] ;
                                                                            init-script =
                                                                                { ... } :
                                                                                    ''
                                                                                        export GNUPGHOME=/mount/config
                                                                                        mkdir "$GNUPGHOME"
                                                                                        chmod 0700 "$GNUPGHOME"
                                                                                        age --decrypt --identity ${ config.personal.agenix } --output /work/secret-keys.asc ${ secrets }/secret-keys.asc.age
                                                                                        gpg --batch --yes --homedir "$GNUPGHOME" --import "/work/secret-keys.asc" 2>&1
                                                                                        age --decrypt --identity ${ config.personal.agenix } --output /work/ownertrust.asc ${ secrets }/ownertrust.asc.age
                                                                                        gpg --batch --yes --homedir "$GNUPGHOME" --import-ownertrust /work/ownertrust.asc 2>&1
                                                                                        gpg --batch --yes --homedir "$GNUPGHOME" --update-trustdb 2>&1
                                                                                    '' ;
                                                                            outputs = [ "config" ] ;
                                                                        } ;
                                                                dot-ssh =
                                                                    {
                                                                        boot =
                                                                            ignore :
                                                                                {
                                                                                    init-packages = pkgs : [ pkgs.age ] ;
                                                                                    init-script =
                                                                                        { dependencies , outputs } :
                                                                                            ''
                                                                                                age --decrypt --identity ${ config.personal.agenix } ${ secrets }/dot-ssh/boot/identity.asc.age > /mount/identity
                                                                                                age --decrypt --identity ${ config.personal.agenix } ${ secrets }/dot-ssh/boot/known-hosts.asc.age > /mount/known-hosts
                                                                                                cat > /mount/config <<EOF
                                                                                                HostName github.com
                                                                                                Host github.com
                                                                                                IdentityFile ${ outputs.identity }
                                                                                                UserKnownHostsFile ${ outputs.known-hosts }
                                                                                                StrictHostKeyChecking true
                                                                                                EOF
                                                                                                chmod 0400 /mount/identity /mount/known-hosts /mount/config
                                                                                            '' ;
                                                                                    outputs = [ "config" "identity" "known-hosts" ] ;
                                                                                } ;
                                                                        mobile =
                                                                            ignore :
                                                                                {
                                                                                    init-packages = pkgs : [ pkgs.age ] ;
                                                                                    init-script =
                                                                                        { dependencies , outputs } :
                                                                                            ''
                                                                                                age --decrypt --identity ${ config.personal.agenix } ${ secrets }/dot-ssh/boot/identity.asc.age > /mount/identity
                                                                                                age --decrypt --identity ${ config.personal.agenix } ${ secrets }/dot-ssh/boot/known-hosts.asc.age > /mount/known-hosts
                                                                                                cat > /mount/config <<EOF
                                                                                                Host mobile
                                                                                                HostName 192.168.1.202
                                                                                                IdentityFile ${ outputs.identity }
                                                                                                Port 8022
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
                                                                                        { dependencies , outputs } :
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
                                                                gnucash =
                                                                    ignore :
                                                                        {
                                                                            dependencies = tree : { dot-ssh = tree.personal.dot-ssh.boot ; dot-gnupg = tree.personal.dot-gnupg ; } ;
                                                                            init-packages = pkgs : [ pkgs.coreutils pkgs.git pkgs.git-crypt pkgs.gnupg ] ;
                                                                            init-script =
                                                                                { ... } :
                                                                                    ''
                                                                                        export GIT_DIR=/mount/git
                                                                                        export GIT_WORK_TREE=/mount/work-tree
                                                                                        mkdir "$GIT_DIR"
                                                                                        mkdir "$GIT_WORK_TREE"
                                                                                        export GNUPGHOME=${ foobar [ "personal" "dot-gnupg" ] "config" }
                                                                                        git init 2>&1
                                                                                        ${ ssh-command ( foobar [ "personal" "dot-ssh" "boot" ] "config" ) }
                                                                                        git config user.email ${ config.personal.email }
                                                                                        git config user.name "${ config.personal.description }"
                                                                                        ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                        git remote add origin ${ config.personal.gnucash.remote }
                                                                                        if git fetch origin ${ config.personal.gnucash.branch } 2>&1
                                                                                        then
                                                                                            echo "branch already exists"
                                                                                            git checkout ${ config.personal.gnucash.branch } 2>&1
                                                                                            git-crypt unlock
                                                                                        else
                                                                                            echo "branch does not already exist"
                                                                                            git checkout -b ${ config.personal.gnucash.branch } 2>&1
                                                                                            git-crypt init 2>&1
                                                                                            echo git-crypt add-gpg-user ${ config.personal.gnucash.recipient } 2>&1
                                                                                            git-crypt add-gpg-user ${ config.personal.gnucash.recipient } 2>&1
                                                                                            cat > "$GIT_WORK_TREE/.gitattributes" <<EOF
                                                                                        config/** filter=git-crypt diff=git-crypt
                                                                                        data/** filter=git-crypt diff=git-crypt
                                                                                        home/** filter=git-crypt diff=git-crypt
                                                                                        EOF
                                                                                            gpg --list-keys
                                                                                            git-crypt unlock
                                                                                            mkdir "$GIT_WORK_TREE/config"
                                                                                            touch "$GIT_WORK_TREE/config/.gitkeep"
                                                                                            mkdir "$GIT_WORK_TREE/data"
                                                                                            touch "$GIT_WORK_TREE/data/.gitkeep"
                                                                                            mkdir "$GIT_WORK_TREE/home"
                                                                                            touch "$GIT_WORK_TREE/home/.gitkeep"
                                                                                            git add .gitattributes config/.gitkeep data/.gitkeep home/.gitkeep
                                                                                            git commit -m "Initialize git-crypt with .gitattributes" 2>&1
                                                                                            git push origin HEAD 2>&1
                                                                                        fi
                                                                                    '' ;
                                                                            outputs = [ "git" "work-tree" ] ;
                                                                        } ;
                                                                jrnl =
                                                                    ignore :
                                                                        {
                                                                            dependencies = tree : { dot-ssh = tree.personal.dot-ssh.boot ; dot-gnupg = tree.personal.dot-gnupg ; } ;
                                                                            init-packages = pkgs : [ pkgs.coreutils pkgs.git pkgs.git-crypt pkgs.gnupg ] ;
                                                                            init-script =
                                                                                { ... } :
                                                                                    ''
                                                                                        export GIT_DIR=/mount/git
                                                                                        export GIT_WORK_TREE=/mount/work-tree
                                                                                        mkdir "$GIT_DIR"
                                                                                        mkdir "$GIT_WORK_TREE"
                                                                                        export GNUPGHOME=${ foobar [ "personal" "dot-gnupg" ] "config" }
                                                                                        git init 2>&1
                                                                                        ${ ssh-command ( foobar [ "personal" "dot-ssh" "boot" ] "config" ) }
                                                                                        git config user.email ${ config.personal.email }
                                                                                        git config user.name "${ config.personal.description }"
                                                                                        ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                        git remote add origin ${ config.personal.jrnl.remote }
                                                                                        if git fetch origin ${ config.personal.jrnl.branch } 2>&1
                                                                                        then
                                                                                            echo "branch already exists"
                                                                                            git checkout ${ config.personal.jrnl.branch } 2>&1
                                                                                            git-crypt unlock
                                                                                        else
                                                                                            echo "branch does not already exist"
                                                                                            git checkout -b ${ config.personal.jrnl.branch } 2>&1
                                                                                            git-crypt init 2>&1
                                                                                            echo git-crypt add-gpg-user ${ config.personal.jrnl.recipient } 2>&1
                                                                                            git-crypt add-gpg-user ${ config.personal.jrnl.recipient } 2>&1
                                                                                            cat > "$GIT_WORK_TREE/.gitattributes" <<EOF
                                                                                        config/** filter=git-crypt diff=git-crypt
                                                                                        data/** filter=git-crypt diff=git-crypt
                                                                                        EOF
                                                                                            gpg --list-keys
                                                                                            echo before unlock
                                                                                            git-crypt unlock
                                                                                            echo after unlock
                                                                                            mkdir "$GIT_WORK_TREE/config"
                                                                                            touch "$GIT_WORK_TREE/config/.gitkeep"
                                                                                            mkdir "$GIT_WORK_TREE/data"
                                                                                            touch "$GIT_WORK_TREE/data/.gitkeep"
                                                                                            git add .gitattributes config/.gitkeep data/.gitkeep
                                                                                            git commit -m "Initialize git-crypt with .gitattributes" 2>&1
                                                                                            git push origin HEAD 2>&1
                                                                                        fi
                                                                                    '' ;
                                                                            outputs = [ "git" "work-tree" ] ;
                                                                        } ;
                                                                ledger =
                                                                    ignore :
                                                                        {
                                                                            dependencies = tree : { dot-ssh = tree.personal.dot-ssh.boot ; dot-gnupg = tree.personal.dot-gnupg ; } ;
                                                                            init-packages = pkgs : [ pkgs.coreutils pkgs.git pkgs.git-crypt pkgs.gnupg ] ;
                                                                            init-script =
                                                                                { ... } :
                                                                                    ''
                                                                                        export GIT_DIR=/mount/git
                                                                                        export GIT_WORK_TREE=/mount/work-tree
                                                                                        mkdir "$GIT_DIR"
                                                                                        mkdir "$GIT_WORK_TREE"
                                                                                        export GNUPGHOME=${ foobar [ "personal" "dot-gnupg" ] "config" }
                                                                                        git init 2>&1
                                                                                        ${ ssh-command ( foobar [ "personal" "dot-ssh" "boot" ] "config" ) }
                                                                                        git config user.email ${ config.personal.email }
                                                                                        git config user.name "${ config.personal.description }"
                                                                                        ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                        git remote add origin ${ config.personal.ledger.remote }
                                                                                        if git fetch origin ${ config.personal.ledger.branch } 2>&1
                                                                                        then
                                                                                            echo "branch already exists"
                                                                                            git checkout ${ config.personal.ledger.branch } 2>&1
                                                                                            git-crypt unlock
                                                                                        else
                                                                                            echo "branch does not already exist"
                                                                                            git checkout -b ${ config.personal.ledger.branch } 2>&1
                                                                                            git-crypt init 2>&1
                                                                                            echo git-crypt add-gpg-user ${ config.personal.ledger.recipient } 2>&1
                                                                                            git-crypt add-gpg-user ${ config.personal.ledger.recipient } 2>&1
                                                                                            cat > "$GIT_WORK_TREE/.gitattributes" <<EOF
                                                                                        config/** filter=git-crypt diff=git-crypt
                                                                                        data/** filter=git-crypt diff=git-crypt
                                                                                        finance.ledger filter=git-crypt diff=git-crypt
                                                                                        EOF
                                                                                            gpg --list-keys
                                                                                            echo before unlock
                                                                                            git-crypt unlock
                                                                                            echo after unlock
                                                                                            mkdir "$GIT_WORK_TREE/config"
                                                                                            touch "$GIT_WORK_TREE/config/.gitkeep"
                                                                                            mkdir "$GIT_WORK_TREE/data"
                                                                                            touch "$GIT_WORK_TREE/data/.gitkeep"
                                                                                            touch "$GIT_WORK_TREE/finance.ledger"
                                                                                            git add .gitattributes config/.gitkeep data/.gitkeep
                                                                                            git commit -m "Initialize git-crypt with .gitattributes" 2>&1
                                                                                            git push origin HEAD 2>&1
                                                                                        fi
                                                                                    '' ;
                                                                            outputs = [ "git" "work-tree" ] ;
                                                                        } ;
                                                                pass =
                                                                    ignore :
                                                                        {
                                                                            dependencies = tree : { dot-gnupg = tree.personal.dot-gnupg ; dot-ssh = tree.personal.dot-ssh.boot ; } ;
                                                                            init-packages = pkgs : [ pkgs.coreutils pkgs.git ] ;
                                                                            init-script =
                                                                                { dependencies , ... } :
                                                                                    ''
                                                                                        export GIT_DIR=/mount/git
                                                                                        export GIT_WORK_TREE=/mount/work-tree
                                                                                        mkdir "$GIT_DIR"
                                                                                        mkdir "$GIT_WORK_TREE"
                                                                                        git init 2>&1
                                                                                        ${ ssh-command dependencies.dot-ssh.config }
                                                                                        git config user.email "${ config.personal.email }"
                                                                                        git config user.name "${ config.personal.description }"
                                                                                        ln --symbolic ${ post-commit }/bin/post-commit /mount/git/hooks/post-commit
                                                                                        git remote add origin ${ config.personal.pass.remote } 2>&1
                                                                                        git fetch origin ${ config.personal.pass.branch } 2>&1
                                                                                        git checkout ${ config.personal.pass.branch } 2>&1
                                                                                    '' ;
                                                                                outputs = [ "git" "work-tree" ] ;
                                                                        } ;
                                                                repository =
                                                                    {
                                                                        personal =
                                                                            ignore :
                                                                                {
                                                                                    dependencies = tree : { dot-ssh = tree.personal.dot-ssh.viktor ; } ;
                                                                                    init-packages = pkgs : [ pkgs.coreutils pkgs.git pkgs.libuuid ] ;
                                                                                    init-script =
                                                                                        { dependencies , outputs } :
                                                                                            ''
                                                                                                cat > /mount/.envrc <<EOF
                                                                                                export GIT_DIR=${ outputs.git }
                                                                                                export GIT_WORK_TREE=${ outputs.workspace }/work-tree
                                                                                                EOF
                                                                                                export GIT_DIR=/mount/git
                                                                                                export GIT_WORK_TREE=/mount/workspace/work-tree
                                                                                                mkdir "$GIT_DIR"
                                                                                                mkdir --parents "$GIT_WORK_TREE"
                                                                                                git init 2>&1
                                                                                                ${ ssh-command dependencies.dot-ssh.config }
                                                                                                git config user.email "${ config.personal.email }"
                                                                                                git config user.name "${ config.personal.description }"
                                                                                                ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                                git remote add origin "git@github.com:viktordanek/personal.git"
                                                                                                git fetch origin main 2>&1
                                                                                                git checkout origin/main 2>&1
                                                                                                git checkout -b "scratch/$( uuidgen)" 2>&1
                                                                                            '' ;
                                                                                    outputs = [ ".envrc" "git" "workspace" ] ;
                                                                                } ;
                                                                        private =
                                                                            ignore :
                                                                                {
                                                                                    dependencies = tree : { dot-ssh = tree.personal.dot-ssh.mobile ; personal = tree.personal.repository.personal ; secrets = tree.personal.repository.secrets ; stash = tree.personal.repository.stash ; visitor = tree.personal.repository.visitor ; } ;
                                                                                    init-packages = pkgs : [ pkgs.coreutils pkgs.git pkgs.libuuid ] ;
                                                                                    init-script =
                                                                                        { dependencies , outputs } :
                                                                                            let

                                                                                                bin =
                                                                                                    pkgs.stdenv.mkDerivation
                                                                                                        {
                                                                                                            installPhase =
                                                                                                                let
                                                                                                                    checks =
                                                                                                                        pkgs.writeShellApplication
                                                                                                                            {
                                                                                                                                name = "checks" ;
                                                                                                                                runtimeInputs = [ pkgs.coreutils pkgs.nix ] ;
                                                                                                                                text =
                                                                                                                                    ''
                                                                                                                                        nix flake check \
                                                                                                                                            --override-input personal ${ dependencies.personal.workspace }/work-tree \
                                                                                                                                            --override-input secrets ${ dependencies.secrets.workspace }/work-tree \
                                                                                                                                            --override-input stash ${ dependencies.stash.workspace }/work-tree \
                                                                                                                                            --override-input visitor ${ dependencies.visitor.workspace }/work-tree \
                                                                                                                                            ${ outputs.workspace }/work-tree
                                                                                                                                    '' ;
                                                                                                                            } ;
                                                                                                                    live-promote =
                                                                                                                        pkgs.writeShellApplication
                                                                                                                            {
                                                                                                                                name = "live-promote" ;
                                                                                                                                runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.nixos-rebuild ] ;
                                                                                                                                text =
                                                                                                                                    ''
                                                                                                                                        date +%s > ${ outputs.workspace }/work-tree/current-time.nix
                                                                                                                                        fun ( )
                                                                                                                                            {
                                                                                                                                                export GIT_DIR="$1"
                                                                                                                                                export GIT_WORK_TREE="$2"
                                                                                                                                                git commit -am "" --allow-empty --allow-empty-message < /dev/null > /dev/null 2>&1
                                                                                                                                                echo -n "--override-input $3 $GIT_WORK_TREE"
                                                                                                                                            }
                                                                                                                                        cat > nixos-rebuild.sh <<EOF
                                                                                                                                        ${ pkgs.nixos-rebuild }/bin/nixos-rebuild \
                                                                                                                                          build-vm \
                                                                                                                                          --flake ${ outputs.workspace }/work-tree#myhost \
                                                                                                                                          $( fun ${ dependencies.personal.git } ${ dependencies.personal.workspace }/work-tree personal ) \
                                                                                                                                          $( fun ${ dependencies.secrets.git } ${ dependencies.secrets.workspace }/work-tree secrets ) \
                                                                                                                                          $( fun ${ dependencies.secrets.git } ${ dependencies.stash.workspace }/work-tree stash ) \
                                                                                                                                          $( fun ${ dependencies.visitor.git } ${ dependencies.visitor.workspace }/work-tree visitor )
                                                                                                                                        EOF
                                                                                                                                        chmod a+rwx nixos-rebuild.sh
                                                                                                                                        git commit -am "promoted $0" --allow-empty > /dev/null 2>&1
                                                                                                                                        ./nixos-rebuild.sh
                                                                                                                                        TARGET="$( git rev-parse HEAD )"
                                                                                                                                        VIRTUAL_MACHINES=${ outputs.virtual-machines }
                                                                                                                                        mkdir --parents "$VIRTUAL_MACHINES/$TARGET"
                                                                                                                                        mv result "$VIRTUAL_MACHINES/$TARGET/result"
                                                                                                                                        export LD_LIBRARY_PATH=${ pkgs.e2fsprogs }/bin
                                                                                                                                        cd "$VIRTUAL_MACHINES/$TARGET"
                                                                                                                                        result/bin/run-nixos-vm
                                                                                                                                    '' ;
                                                                                                                            } ;
                                                                                                                    update-promote =
                                                                                                                        pkgs.writeShellApplication
                                                                                                                            {
                                                                                                                                name = "update-promote" ;
                                                                                                                                runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.nixos-rebuild ] ;
                                                                                                                                text =
                                                                                                                                    ''
                                                                                                                                        date +%s > ${ outputs.workspace }/work-tree/current-time.nix
                                                                                                                                        nixos-rebuild build-vm --flake ${ outputs.workspace }/work-tree#myhost --update-input personal --update-input secrets --update-input stash --update-input visitor
                                                                                                                                        git commit -am "promoted $0" --allow-empty
                                                                                                                                        TARGET="$( git rev-parse HEAD )"
                                                                                                                                        VIRTUAL_MACHINES=${ outputs.virtual-machines }
                                                                                                                                        mkdir --parents "$VIRTUAL_MACHINES/$TARGET"
                                                                                                                                        mv result "$VIRTUAL_MACHINES/$TARGET/result"
                                                                                                                                        export LD_LIBRARY_PATH=${ pkgs.e2fsprogs }/bin
                                                                                                                                        export LD_LIBRARY_PATH=${ pkgs.e2fsprogs }/bin
                                                                                                                                        cd "$VIRTUAL_MACHINES/$TARGET"
                                                                                                                                        result/bin/run-nixos-vm
                                                                                                                                    '' ;
                                                                                                                            } ;
                                                                                                                    stable-promote =
                                                                                                                        pkgs.writeShellApplication
                                                                                                                            {
                                                                                                                                name = "stable-promote" ;
                                                                                                                                runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.nixos-rebuild ] ;
                                                                                                                                text =
                                                                                                                                    ''
                                                                                                                                        date +%s > ${ outputs.workspace }/work-tree/current-time.nix
                                                                                                                                        nixos-rebuild build-vm --flake ${ outputs.workspace }/work-tree#myhost
                                                                                                                                        git commit -am "promoted $0" --allow-empty
                                                                                                                                        TARGET="$( git rev-parse HEAD )"
                                                                                                                                        VIRTUAL_MACHINES=${ outputs.virtual-machines }
                                                                                                                                        mkdir --parents "$VIRTUAL_MACHINES/$TARGET"
                                                                                                                                        mv result "$VIRTUAL_MACHINES/$TARGET/result"
                                                                                                                                        export LD_LIBRARY_PATH=${ pkgs.e2fsprogs }/bin
                                                                                                                                        TARGET="$( git rev-parse HEAD )"
                                                                                                                                        cd "$VIRTUAL_MACHINES/$TARGET"
                                                                                                                                        result/bin/run-nixos-vm

                                                                                                                                    '' ;
                                                                                                                            } ;
                                                                                                                   stress-promote =
                                                                                                                        pkgs.writeShellApplication
                                                                                                                            {
                                                                                                                                name = "stress-promote" ;
                                                                                                                                runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.nixos-rebuild ] ;
                                                                                                                                text =
                                                                                                                                    ''
                                                                                                                                        date +%s > ${ outputs.workspace }/work-tree/current-time.nix
                                                                                                                                        nixos-rebuild build-vm-with-bootloader --flake ${ outputs.workspace }/work-tree#myhost
                                                                                                                                        git commit -am "promoted $0" --allow-empty
                                                                                                                                        TARGET="$( git rev-parse HEAD )"
                                                                                                                                        VIRTUAL_MACHINES=${ outputs.virtual-machines }
                                                                                                                                        mkdir --parents "$VIRTUAL_MACHINES/$TARGET"
                                                                                                                                        mv result "$VIRTUAL_MACHINES/$TARGET/result"
                                                                                                                                        export LD_LIBRARY_PATH=${ pkgs.e2fsprogs }/bin
                                                                                                                                        cd "$VIRTUAL_MACHINES/$TARGET"
                                                                                                                                        result/bin/run-nixos-vm
                                                                                                                                    '' ;
                                                                                                                            } ;
                                                                                                                   development-promote =
                                                                                                                        pkgs.writeShellApplication
                                                                                                                            {
                                                                                                                                name = "development-promote" ;
                                                                                                                                runtimeInputs = [ pkgs.coreutils pkgs.coreutils pkgs.git pkgs.nano pkgs.nixos-rebuild pkgs.libuuid ] ;
                                                                                                                                text =
                                                                                                                                    ''
                                                                                                                                        date +%s > ${ outputs.workspace }/work-tree/current-time.nix
                                                                                                                                        sudo nixos-rebuild test --flake ${ outputs.workspace }/work-tree#myhost
                                                                                                                                        git commit -am "promoted $0" --allow-empty
                                                                                                                                        SCRATCH=$( uuidgen )
                                                                                                                                        git checkout -b "$SCRATCH"
                                                                                                                                        git fetch origin development
                                                                                                                                        git diff origin/development
                                                                                                                                        git reset --soft origin/development
                                                                                                                                        git commit -a
                                                                                                                                        git checkout development
                                                                                                                                        git rebase origin/development
                                                                                                                                        if ! git rebase "$SCRATCH" ; then
                                                                                                                                          date +%s > ${ outputs.workspace }/work-tree/current-time.nix
                                                                                                                                          git add current-time.nix
                                                                                                                                          git rebase --continue
                                                                                                                                        fi
                                                                                                                                        git push origin HEAD
                                                                                                                                    '' ;
                                                                                                                            } ;
                                                                                                                   main-promote =
                                                                                                                        pkgs.writeShellApplication
                                                                                                                            {
                                                                                                                                name = "main-promote" ;
                                                                                                                                runtimeInputs = [ pkgs.git pkgs.nix pkgs.nixos-rebuild pkgs.nano pkgs.libuuid ] ;
                                                                                                                                text =
                                                                                                                                    ''
                                                                                                                                        git fetch origin development
                                                                                                                                        git fetch origin main
                                                                                                                                        git checkout main
                                                                                                                                        git rebase origin/main
                                                                                                                                        if ! git rebase origin/development; then
                                                                                                                                          echo "Conflict detected. Overwriting current-time.nix with version from origin/development..."
                                                                                                                                          git checkout --theirs current-time.nix
                                                                                                                                          git add current-time.nix
                                                                                                                                          git rebase --continue
                                                                                                                                        fi
                                                                                                                                        sudo nixos-rebuild switch --flake ${ outputs.workspace }/work-tree#myhost
                                                                                                                                        git push --force-with-lease origin HEAD
                                                                                                                                        nix-collect-garbage
                                                                                                                                    '' ;
                                                                                                                            } ;
                                                                                                                        in
                                                                                                                            ''
                                                                                                                                mkdir --parents $out/bin
                                                                                                                                makeWrapper ${ checks }/bin/checks $out/bin/checks
                                                                                                                                makeWrapper ${ live-promote }/bin/live-promote $out/bin/live-promote
                                                                                                                                makeWrapper ${ update-promote }/bin/update-promote $out/bin/update-promote
                                                                                                                                makeWrapper ${ stable-promote }/bin/stable-promote $out/bin/stable-promote
                                                                                                                                makeWrapper ${ stress-promote }/bin/stress-promote $out/bin/stress-promote
                                                                                                                                makeWrapper ${ development-promote }/bin/development-promote $out/bin/development-promote
                                                                                                                                makeWrapper ${ main-promote }/bin/main-promote $out/bin/main-promote
                                                                                                                            '' ;
                                                                                                            name = "bin" ;
                                                                                                            nativeBuildInputs = [ pkgs.makeWrapper ] ;
                                                                                                            src = ./. ;
                                                                                                        } ;
                                                                                                in
                                                                                                    ''
                                                                                                        mkdir /mount/bin
                                                                                                        mkdir /mount/virtual-machines
                                                                                                        cat > /mount/.envrc <<EOF
                                                                                                        export GIT_DIR=${ outputs.git }
                                                                                                        export GIT_WORK_TREE=${ outputs.workspace }/work-tree
                                                                                                        export PATH="$PATH:${ pkgs.coreutils }/bin:${ pkgs.git }/bin:${ pkgs.nix }/bin:${ pkgs.nixos-rebuild }/bin:${ bin }/bin"
                                                                                                        EOF
                                                                                                        export GIT_DIR=/mount/git
                                                                                                        export WORKSPACE=/mount/workspace
                                                                                                        export GIT_WORK_TREE="$WORKSPACE/work-tree"
                                                                                                        mkdir "$GIT_DIR"
                                                                                                        mkdir --parents "$GIT_WORK_TREE"
                                                                                                        git init 2>&1
                                                                                                        ${ ssh-command dependencies.dot-ssh.config }
                                                                                                        git config user.email "${ config.personal.email }"
                                                                                                        git config user.name "${ config.personal.description }"
                                                                                                        git remote add origin mobile:private
                                                                                                        git fetch origin main 2>&1
                                                                                                        git checkout origin/main 2>&1
                                                                                                        git checkout -b "scratch/$( uuidgen )" 2>&1
                                                                                                    '' ;
                                                                                    outputs = [ ".envrc" "bin" "git" "virtual-machines" "workspace" ] ;
                                                                                } ;
                                                                        secrets =
                                                                            ignore :
                                                                                {
                                                                                    dependencies = tree : { dot-ssh = tree.personal.dot-ssh.boot ; } ;
                                                                                    init-packages = pkgs : [ pkgs.coreutils pkgs.git pkgs.libuuid ] ;
                                                                                    init-script =
                                                                                        { dependencies , outputs } :
                                                                                            ''
                                                                                                cat > /mount/.envrc <<EOF
                                                                                                export GIT_DIR=${ outputs.git }
                                                                                                export GIT_WORK_TREE=${ outputs.workspace }/work-tree
                                                                                                EOF
                                                                                                export GIT_DIR=/mount/git
                                                                                                export GIT_WORK_TREE=/mount/workspace/work-tree
                                                                                                mkdir "$GIT_DIR"
                                                                                                mkdir --parents "$GIT_WORK_TREE"
                                                                                                git init 2>&1
                                                                                                ${ ssh-command dependencies.dot-ssh.config }
                                                                                                git config user.email "${ config.personal.email }"
                                                                                                git config user.name "${ config.personal.description }"
                                                                                                ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                                git remote add origin "git@github.com:AFnRFCb7/12e5389b-8894-4de5-9cd2-7dab0678d22b"
                                                                                                git fetch origin main 2>&1
                                                                                                git checkout origin/main 2>&1
                                                                                                git checkout -b "scratch/$( uuidgen)" 2>&1
                                                                                            '' ;
                                                                                    outputs = [ ".envrc" "git" "workspace" ] ;
                                                                                } ;
                                                                        stash =
                                                                            ignore :
                                                                                {
                                                                                    dependencies = tree : { dot-ssh = tree.personal.dot-ssh.viktor ; } ;
                                                                                    init-packages = pkgs : [ pkgs.coreutils pkgs.git pkgs.libuuid ] ;
                                                                                    init-script =
                                                                                        { dependencies , outputs } :
                                                                                            ''
                                                                                                cat > /mount/.envrc <<EOF
                                                                                                export GIT_DIR=${ outputs.git }
                                                                                                export GIT_WORK_TREE=${ outputs.workspace }/work-tree
                                                                                                EOF
                                                                                                export GIT_DIR=/mount/git
                                                                                                export GIT_WORK_TREE=/mount/workspace/work-tree
                                                                                                mkdir "$GIT_DIR"
                                                                                                mkdir --parents "$GIT_WORK_TREE"
                                                                                                git init 2>&1
                                                                                                ${ ssh-command dependencies.dot-ssh.config }
                                                                                                git config user.email "viktordanek10@gmail.com"
                                                                                                git config user.name "Viktor Danek"
                                                                                                ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                                git remote add origin git@github.com:viktordanek/stash.git
                                                                                                if git fetch origin main 2>&1
                                                                                                then
                                                                                                    git checkout origin/main 2>&1
                                                                                                else
                                                                                                    git checkout -b main 2>&1
                                                                                                fi
                                                                                                git checkout -b "scratch/$( uuidgen )" 2>&1
                                                                                            '' ;
                                                                                    outputs = [ ".envrc" "git" "workspace" ] ;
                                                                                } ;
                                                                        visitor =
                                                                            ignore :
                                                                                {
                                                                                    dependencies = tree : { dot-ssh = tree.personal.dot-ssh.viktor ; } ;
                                                                                    init-packages = pkgs : [ pkgs.coreutils pkgs.git pkgs.libuuid ] ;
                                                                                    init-script =
                                                                                        { dependencies , outputs } :
                                                                                            ''
                                                                                                cat > /mount/.envrc <<EOF
                                                                                                export GIT_DIR=${ outputs.git }
                                                                                                export GIT_WORK_TREE=${ outputs.workspace }/work-tree
                                                                                                EOF
                                                                                                export GIT_DIR=/mount/git
                                                                                                export GIT_WORK_TREE=/mount/workspace/work-tree
                                                                                                mkdir "$GIT_DIR"
                                                                                                mkdir --parents "$GIT_WORK_TREE"
                                                                                                git init 2>&1
                                                                                                ${ ssh-command dependencies.dot-ssh.config }
                                                                                                git config user.email "${ config.personal.email }"
                                                                                                git config user.name "${ config.personal.description }"
                                                                                                ln --symbolic ${ post-commit }/bin/post-commit "$GIT_DIR/hooks/post-commit"
                                                                                                git remote add origin "git@github.com:viktordanek/visitor.git"
                                                                                                git fetch origin main 2>&1
                                                                                                git checkout origin/main 2>&1
                                                                                                git checkout -b "scratch/$( uuidgen)" 2>&1
                                                                                            '' ;
                                                                                    outputs = [ ".envrc" "git" "workspace" ] ;
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
                                                                            init-script = { dependencies , outputs } : ''ln --symbolic "/home/emory/stash/direct/$UNIQ_TOKEN/scratch/one/mount/one" /mount/two'' ;
                                                                            outputs = [ "two" ] ;
                                                                        } ;
                                                            } ;
                                                    } ;
                                        foobar = path : output : builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" config.personal.name config.personal.stash "direct" ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString current-time ) ) ) ] ( builtins.map builtins.toJSON path ) [ "mount" output ] ] ) ;
                                        scripts-foobar =
                                            path :
                                                let
                                                    filtered = builtins.filter ( script : script.path == path ) scripts ;
                                                    find = if builtins.length filtered == 1 then builtins.head filtered else builtins.throw "bad path" ;
                                                    in find.environment ;
                                        repository =
                                            name : mount :
                                                pkgs.writeShellApplication
                                                    {
                                                        name = name ;
                                                        runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.jetbrains.idea-community ] ;
                                                        text =
                                                            ''
                                                                idea-community ${ mount }
                                                            '' ;
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
                                                                let
                                                                    environment =
                                                                        pkgs.buildFHSUserEnv
                                                                            {
                                                                                extraBwrapArgs =
                                                                                    [
                                                                                        "--bind /home/${ config.personal.name }/${ config.personal.stash } /home/${ config.personal.name }/${ config.personal.stash }"
                                                                                    ] ;
                                                                                name = resource.environment-name ;
                                                                                runScript =
                                                                                    let
                                                                                        environment = pkgs.writeShellApplication { name = "environment" ; text = resource.environment-script tools ; } ;
                                                                                        in "${ environment }/bin/environment" ;
                                                                                targetPkgs = resource.environment-packages ;
                                                                            } ;
                                                                    init =
                                                                        pkgs.buildFHSUserEnv
                                                                            {
                                                                                extraBwrapArgs =
                                                                                    [
                                                                                        "--bind $MOUNT /mount"
                                                                                        "--bind /home/${ config.personal.name }/${ config.personal.stash }/direct /home/${ config.personal.name }/${ config.personal.stash }/direct"
                                                                                        "--tmpfs /work"
                                                                                    ] ;
                                                                                name = "init" ;
                                                                                runScript =
                                                                                    let
                                                                                        init = pkgs.writeShellApplication { name = "init" ; text = resource.init-script tools ; } ;
                                                                                        in "${ init }/bin/init" ;
                                                                                targetPkgs = resource.init-packages ;
                                                                            } ;
                                                                    release =
                                                                        pkgs.buildFHSUserEnv
                                                                            {
                                                                                extraBwrapArgs =
                                                                                    [
                                                                                        "--ro-bind $LINK /home/${ config.personal.name }/${ config.personal.stash }/direct"
                                                                                        "--tmpfs /work"
                                                                                    ] ;
                                                                                name = "release" ;
                                                                                runScript =
                                                                                    let
                                                                                        release =
                                                                                            pkgs.writeShellApplication
                                                                                                {
                                                                                                    name = "release" ;
                                                                                                    text = resource.release-script tools ;
                                                                                                } ;
                                                                                            in "${ release }/bin/release" ;
                                                                                targetPkgs = resource.release-packages;
                                                                            } ;
                                                                        tools =
                                                                            {
                                                                                dependencies =
                                                                                     builtins.mapAttrs
                                                                                        (
                                                                                            name : value :
                                                                                                let
                                                                                                    list = builtins.getAttr value outputs ;
                                                                                                    in
                                                                                                        builtins.listToAttrs
                                                                                                            (
                                                                                                                builtins.map
                                                                                                                    (
                                                                                                                        output :
                                                                                                                            {
                                                                                                                                name = output ;
                                                                                                                                value = builtins.concatStringsSep "/" [ "" "home" config.personal.name config.personal.stash "direct" ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString current-time ) ) ) value "mount" output ] ;
                                                                                                                            }
                                                                                                                    )
                                                                                                                    list
                                                                                                            )
                                                                                        )
                                                                                        resource.tools.dependencies ;
                                                                                outputs = resource.tools.outputs ;
                                                                            } ;
                                                                    in
                                                                        {
                                                                            environment = environment ;
                                                                            index = index ;
                                                                            path = resource.path ;
                                                                            setup =
                                                                                pkgs.writeShellApplication
                                                                                    {
                                                                                        name = "setup" ;
                                                                                        runtimeInputs = [ pkgs.coreutils pkgs.findutils pkgs.flock pkgs.jq pkgs.yq ] ;
                                                                                        text =
                                                                                            let
                                                                                                yaml =
                                                                                                    code :
                                                                                                        if code == 32126 then
                                                                                                            ''jq --null-input --arg CODE "${ builtins.toString code }" --arg DEPENDENCIES '${ builtins.concatStringsSep "," resource.dependencies }' --arg EXPECTED "${ builtins.concatStringsSep "\n" resource.outputs }" --arg INDEX ${ builtins.toString index } --arg INIT "${ init }/bin/init" --arg OBSERVED "$( find "$STASH/mount" -mindepth 1 -maxdepth 1 -exec basename {} \; | LC_ALL=C sort )" --arg OUTPUT "${ builtins.concatStringsSep "," resource.outputs }" --arg RELEASE "${ release }/bin/release" '{ "dependencies" : $DEPENDENCIES , "expected" : $EXPECTED , "index" : $INDEX , "observed" : $OBSERVED , "init" : $INIT , "release" : $RELEASE }' | yq --yaml-output "." > "$STASH/init.${ if code == 0 then "success" else "failure" }.yaml"''
                                                                                                        else
                                                                                                            ''jq --null-input --arg CODE "${ builtins.toString code }" --arg DEPENDENCIES '${ builtins.concatStringsSep "," resource.dependencies }' --arg EXPECTED "${ builtins.concatStringsSep "\n" resource.outputs }" --arg INDEX ${ builtins.toString index } --arg INIT "${ init }/bin/init" --arg OBSERVED "$( find "$STASH/mount" -mindepth 1 -maxdepth 1 -exec basename {} \; | LC_ALL=C sort )" --arg OUTPUT "${ builtins.concatStringsSep "," resource.outputs }" --arg RELEASE "${ release }/bin/release" --arg STANDARD_ERROR "$( cat "$STASH/init.standard-error" )" --arg STANDARD_OUTPUT "$( cat "$STASH/init.standard-output" )" --arg STATUS "$?" '{ "code" : $CODE , "dependencies" : $DEPENDENCIES , "expected" : $EXPECTED , "index" : $INDEX , "observed" : $OBSERVED , "init" : $INIT , "release" : $RELEASE ,"standard-error" : $STANDARD_ERROR , "standard-output" : $STANDARD_OUTPUT , "status" : $STATUS }' | yq --yaml-output "." > "$STASH/init.${ if code == 0 then "success" else "failure" }.yaml"'' ;
                                                                                                in
                                                                                                    ''
                                                                                                        ROOT=${ builtins.concatStringsSep "/" [ "" "home" config.personal.name config.personal.stash ] } ;
                                                                                                        mkdir --parents "$ROOT"
                                                                                                        exec 201> "$ROOT/lock"
                                                                                                        flock -x 201
                                                                                                        export UNIQ_TOKEN="${ builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString current-time ) ) }"
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
                                                                                                yaml =
                                                                                                    code :
                                                                                                        if code == 31314 then
                                                                                                            ''jq --null-input --arg CODE "${ builtins.toString code }" --arg DEPENDENCIES '${ builtins.concatStringsSep "," resource.dependencies }' --arg EXPECTED "${ builtins.concatStringsSep "\n" resource.outputs }" --arg INDEX ${ builtins.toString index } --arg INIT "${ init }/init" --arg OBSERVED "$( find "$STASH/mount" -mindepth 1 -maxdepth 1 -exec basename {} \; | LC_ALL=C sort )" --arg OUTPUT "${ builtins.concatStringsSep "," resource.outputs }" --arg RELEASE "${ release }/bin/release" '{ "code" : $CODE , "dependencies" : $DEPENDENCIES , "expected" : $EXPECTED , "index" : $INDEX , "observed" : $OBSERVED , "init" : $INIT , "release" : $RELEASE }' | yq --yaml-output "." > "$STASH/release.${ if code == 0 then "success" else "failure" }.yaml"''
                                                                                                        else
                                                                                                            ''jq --null-input --arg CODE "${ builtins.toString code }" --arg DEPENDENCIES '${ builtins.concatStringsSep "," resource.dependencies }' --arg EXPECTED "${ builtins.concatStringsSep "\n" resource.outputs }" --arg INDEX ${ builtins.toString index } --arg INIT "${ init }/bin/init" --arg OBSERVED "$( find "$STASH/mount" -mindepth 1 -maxdepth 1 -exec basename {} \; | LC_ALL=C sort )" --arg OUTPUT "${ builtins.concatStringsSep "," resource.outputs }" --arg RELEASE "${ release }/bin/release" --arg STANDARD_ERROR "$( cat "$STASH/release.standard-error" )" --arg STANDARD_OUTPUT "$( cat "$STASH/release.standard-output" )" --arg STATUS "$?" '{ "code" : $CODE , "dependencies" : $DEPENDENCIES , "expected" : $EXPECTED , "index" : $INDEX , "observed" : $OBSERVED , "init" : $INIT , "release" : $RELEASE ,"standard-error" : $STANDARD_ERROR , "standard-output" : $STANDARD_OUTPUT , "status" : $STATUS }' | yq --yaml-output "." > "$STASH/release.${ if code == 0 then "success" else "failure" }.yaml"'' ;
                                                                                                in
                                                                                            ''
                                                                                                ROOT=${ builtins.concatStringsSep "/" [ "" "home" config.personal.name config.personal.stash ] } ;
                                                                                                if [ -d "$ROOT" ]
                                                                                                then
                                                                                                    exec 201> "$ROOT/lock"
                                                                                                    flock -x 201
                                                                                                    STASH=${ builtins.concatStringsSep "/" ( builtins.concatLists [ [ "$ROOT" "direct" ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString current-time ) ) ) ] ( builtins.map builtins.toJSON resource.path ) ] ) } ;
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
                                                            if [ ! -e /home/${ config.personal.name }/${ config.personal.stash }/direct/${ builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString current-time ) ) }/teardown ]
                                                            then
                                                                ln --symbolic ${ teardown }/bin/teardown /home/${ config.personal.name }/${ config.personal.stash }/direct/${ builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString current-time ) ) }/teardown
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
                                        calcurse =
                                            calcurse-name : git-name : git : work-tree : dot-gnupg : message :
                                                pkgs.stdenv.mkDerivation
                                                    {
                                                        installPhase =
                                                            ''
                                                                mkdir --parents $out/bin
                                                                makeWrapper \
                                                                    ${ pkgs.calcurse }/bin/calcurse \
                                                                    $out/bin/${ calcurse-name } \
                                                                    --set XDG_CONFIG_HOME ${ work-tree }/config \
                                                                    --set XDG_DATA_HOME ${ work-tree }/data
                                                                makeWrapper \
                                                                    ${ pkgs.git }/bin/git \
                                                                    $out/bin/${ git-name } \
                                                                    --set GIT_DIR ${ git } \
                                                                    --set GIT_WORK_TREE ${ work-tree } \
                                                                    --set GNUPGHOME ${ dot-gnupg }
                                                            '' ;
                                                        name = "calcurse" ;
                                                        nativeBuildInputs = [ pkgs.coreutils pkgs.makeWrapper ] ;
                                                        src = ./. ;
                                                    } ;
                                        chromium =
                                            name : git : work-tree : dot-gnupg : message :
                                                pkgs.writeShellApplication
                                                    {
                                                        name = name ;
                                                        runtimeInputs = [ pkgs.chromium pkgs.git-crypt ] ;
                                                        text =
                                                            ''
                                                                export XDG_CONFIG_HOME=${ work-tree }/config
                                                                export XDG_DATA_HOME=${ work-tree }/data
                                                                export GIT_DIR=${ git }
                                                                export GIT_WORK_TREE=${ work-tree }
                                                                export GNUPGHOME=${ dot-gnupg }
                                                                git fetch origin ${ config.personal.chromium.branch }
                                                                git rebase origin/${ config.personal.chromium.branch }
                                                                git-crypt unlock
                                                                cleanup ( )
                                                                    {
                                                                        sleep 10s
                                                                        git add --all config
                                                                        git add --all data
                                                                        git commit -m "${ message }" --allow-empty --allow-empty-message
                                                                        git push origin HEAD
                                                                    }
                                                                trap cleanup EXIT
                                                                chromium
                                                            '' ;
                                                    } ;
                                        gnucash =
                                            name : git : work-tree : dot-gnupg : message :
                                                pkgs.writeShellApplication
                                                    {
                                                        name = name ;
                                                        runtimeInputs = [ pkgs.gnucash pkgs.git-crypt ] ;
                                                        text =
                                                            ''
                                                                export XDG_CONFIG_HOME=${ work-tree }/config
                                                                export XDG_DATA_HOME=${ work-tree }/data
                                                                export HOMEY=${ work-tree }/home
                                                                export GIT_DIR=${ git }
                                                                export GIT_WORK_TREE=${ work-tree }
                                                                export GNUPGHOME=${ dot-gnupg }
                                                                git fetch origin ${ config.personal.gnucash.branch }
                                                                git rebase origin/${ config.personal.gnucash.branch }
                                                                git-crypt unlock
                                                                cleanup ( )
                                                                    {
                                                                        sleep 10s
                                                                        git add --all config
                                                                        git add --all data
                                                                        git add --all home
                                                                        git commit -m "${ message }" --allow-empty --allow-empty-message
                                                                        git push origin HEAD
                                                                    }
                                                                trap cleanup EXIT
                                                                gnucash "$HOMEY/gnucash.gnucash"
                                                            '' ;
                                                    } ;
                                        jrnl =
                                            jrnl-name : git-name : git : work-tree : dot-gnupg : message :
                                                pkgs.stdenv.mkDerivation
                                                    {
                                                        installPhase =
                                                            ''
                                                                mkdir --parents $out/bin
                                                                makeWrapper \
                                                                    ${ pkgs.jrnl }/bin/jrnl \
                                                                    $out/bin/${ jrnl-name } \
                                                                    --set XDG_CONFIG_HOME ${ work-tree }/config \
                                                                    --set XDG_DATA_HOME ${ work-tree }/data
                                                                makeWrapper \
                                                                    ${ pkgs.git }/bin/git \
                                                                    $out/bin/${ git-name } \
                                                                    --set GIT_DIR ${ git } \
                                                                    --set GIT_WORK_TREE ${ work-tree } \
                                                                    --set GNUPGHOME ${ dot-gnupg }
                                                            '' ;
                                                        name = "jrnl" ;
                                                        nativeBuildInputs = [ pkgs.coreutils pkgs.makeWrapper ] ;
                                                        src = ./. ;
                                                    } ;
                                        ledger =
                                            ledger-name : git-name : git : work-tree : dot-gnupg : message :
                                                pkgs.stdenv.mkDerivation
                                                    {
                                                        installPhase =
                                                            ''
                                                                mkdir --parents $out/bin
                                                                makeWrapper \
                                                                    ${ pkgs.ledger }/bin/ledger \
                                                                    $out/bin/${ ledger-name } \
                                                                    --set XDG_CONFIG_HOME ${ work-tree }/config \
                                                                    --set XDG_DATA_HOME ${ work-tree }/data \
                                                                    --set LEDGER_FILE ${ work-tree }/finance.ledger
                                                                makeWrapper \
                                                                    ${ pkgs.git }/bin/git \
                                                                    $out/bin/${ git-name } \
                                                                    --set GIT_DIR ${ git } \
                                                                    --set GIT_WORK_TREE ${ work-tree } \
                                                                    --set GNUPGHOME ${ dot-gnupg }
                                                            '' ;
                                                        name = "ledger" ;
                                                        nativeBuildInputs = [ pkgs.coreutils pkgs.makeWrapper ] ;
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
                                                                bash =
                                                                    {
                                                                        enableCompletion = true ;
                                                                        interactiveShellInit = ''eval "$( ${ pkgs.direnv }/bin/direnv hook bash )"'' ;
                                                                    } ;
                                                                dconf.enable = true ;
                                                                direnv =
                                                                    {
                                                                        nix-direnv.enable = true ;
                                                                        enable = true ;
                                                                    } ;
                                                                gnupg.agent =
                                                                    {
                                                                        enable = true ;
                                                                        pinentryFlavor = "curses" ;
                                                                    } ;
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
                                                            let
                                                                post-commit =
                                                                    let
                                                                        application =
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
                                                                        in "${ application }/bin/post-commit" ;
                                                                in
                                                                    {
                                                                        services =
                                                                            {
                                                                                calcurse =
                                                                                    {
                                                                                        after = [ "network.target" "network-online.target" "dot-gnupg.service" "dot-ssh.service" ] ;
                                                                                        requires = [ "dot-ssh.service" ] ;
                                                                                        serviceConfig =
                                                                                            {
                                                                                                ExecStart =
                                                                                                    let
                                                                                                        application =
                                                                                                            pkgs.writeShellApplication
                                                                                                                {
                                                                                                                    name = "application" ;
                                                                                                                    runtimeInputs = [ pkgs.age pkgs.coreutils pkgs.git pkgs.git-crypt pkgs.gnupg ] ;
                                                                                                                    text =
                                                                                                                        ''
                                                                                                                            export GNUPGHOME=/var/lib/workspaces/dot-gnupg
                                                                                                                            git init 2>&1
                                                                                                                            git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F /var/lib/workspaces/dot-ssh/config"
                                                                                                                            git config user.email ${ config.personal.email }
                                                                                                                            git config user.name "${ config.personal.description }"
                                                                                                                            ln --symbolic ${ post-commit } .git/hooks/post-commit
                                                                                                                            git remote add origin ${ config.personal.calcurse.remote }
                                                                                                                            if git fetch origin ${ config.personal.calcurse.branch } 2>&1
                                                                                                                            then
                                                                                                                                git checkout ${ config.personal.calcurse.branch } 2>&1
                                                                                                                                git-crypt unlock
                                                                                                                            else
                                                                                                                                git checkout -b ${ config.personal.calcurse.branch } 2>&1
                                                                                                                                git-crypt init 2>&1
                                                                                                                                echo git-crypt add-gpg-user ${ config.personal.calcurse.recipient } 2>&1
                                                                                                                                git-crypt add-gpg-user ${ config.personal.calcurse.recipient } 2>&1
                                                                                                                                cat > .gitattributes <<EOF
                                                                                                                            config/** filter=git-crypt diff=git-crypt
                                                                                                                            data/** filter=git-crypt diff=git-crypt
                                                                                                                            EOF
                                                                                                                                git-crypt unlock
                                                                                                                                mkdir config
                                                                                                                                touch config/.gitkeep
                                                                                                                                mkdir data
                                                                                                                                git add .gitattributes config/.gitkeep data/.gitkeep journal.txt
                                                                                                                                git commit -m "Initialize git-crypt with .gitattributes" 2>&1
                                                                                                                                git push origin HEAD 2>&1
                                                                                                                            fi
                                                                                                                        '' ;
                                                                                                                } ;
                                                                                                        in "${ application }/bin/application" ;
                                                                                                StateDirectory = "workspaces/calcurse" ;
                                                                                                User = config.personal.name ;
                                                                                                WorkingDirectory = "/var/lib/workspaces/calcurse" ;
                                                                                            } ;
                                                                                        unitConfig =
                                                                                            {
                                                                                                ConditionPathExists = "!/var/lib/workspaces/calcurse" ;
                                                                                            } ;
                                                                                        wants = [ "network-online.target" ] ;
                                                                                        wantedBy = [ "multi-user.target" ] ;
                                                                                    } ;
                                                                                chromium =
                                                                                    {
                                                                                        after = [ "network.target" "network-online.target" "dot-gnupg.service" "dot-ssh.service" ] ;
                                                                                        requires = [ "dot-ssh.service" ] ;
                                                                                        serviceConfig =
                                                                                            {
                                                                                                ExecStart =
                                                                                                    let
                                                                                                        application =
                                                                                                            pkgs.writeShellApplication
                                                                                                                {
                                                                                                                    name = "application" ;
                                                                                                                    runtimeInputs = [ pkgs.age pkgs.coreutils pkgs.git pkgs.git-crypt pkgs.gnupg ] ;
                                                                                                                    text =
                                                                                                                        ''
                                                                                                                            export GNUPGHOME=/var/lib/workspaces/dot-gnupg
                                                                                                                            git init 2>&1
                                                                                                                            git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F /var/lib/workspaces/dot-ssh/config"
                                                                                                                            git config user.email ${ config.personal.email }
                                                                                                                            git config user.name "${ config.personal.description }"
                                                                                                                            ln --symbolic ${ post-commit } .git/hooks/post-commit
                                                                                                                            git remote add origin ${ config.personal.chromium.remote }
                                                                                                                            if git fetch origin ${ config.personal.chromium.branch } 2>&1
                                                                                                                            then
                                                                                                                                git checkout ${ config.personal.chromium.branch } 2>&1
                                                                                                                                git-crypt unlock
                                                                                                                            else
                                                                                                                                git checkout -b ${ config.personal.chromium.branch } 2>&1
                                                                                                                                git-crypt init 2>&1
                                                                                                                                echo git-crypt add-gpg-user ${ config.personal.chromium.recipient } 2>&1
                                                                                                                                git-crypt add-gpg-user ${ config.personal.chromium.recipient } 2>&1
                                                                                                                                cat > .gitattributes <<EOF
                                                                                                                            config/** filter=git-crypt diff=git-crypt
                                                                                                                            data/** filter=git-crypt diff=git-crypt
                                                                                                                            EOF
                                                                                                                                git-crypt unlock
                                                                                                                                mkdir config
                                                                                                                                touch config/.gitkeep
                                                                                                                                mkdir data
                                                                                                                                git add .gitattributes config/.gitkeep data/.gitkeep journal.txt
                                                                                                                                git commit -m "Initialize git-crypt with .gitattributes" 2>&1
                                                                                                                                git push origin HEAD 2>&1
                                                                                                                            fi
                                                                                                                        '' ;
                                                                                                                } ;
                                                                                                        in "${ application }/bin/application" ;
                                                                                                StateDirectory = "workspaces/chromium" ;
                                                                                                User = config.personal.name ;
                                                                                                WorkingDirectory = "/var/lib/workspaces/chromium" ;
                                                                                            } ;
                                                                                        unitConfig =
                                                                                            {
                                                                                                ConditionPathExists = "!/var/lib/workspaces/chromium" ;
                                                                                            } ;
                                                                                        wants = [ "network-online.target" ] ;
                                                                                        wantedBy = [ "multi-user.target" ] ;
                                                                                    } ;
                                                                                dot-gnupg =
                                                                                    {
                                                                                        after = [ "network.target" "secrets.service" ] ;
                                                                                        requires = [ "secrets.service" ] ;
                                                                                        serviceConfig =
                                                                                            {
                                                                                                ConditionPathExists = "!/var/lib/workspaces/dot-gnupg" ;
                                                                                                ExecStart =
                                                                                                    let
                                                                                                        application =
                                                                                                            pkgs.writeShellApplication
                                                                                                                {
                                                                                                                    name = "application" ;
                                                                                                                    runtimeInputs = [ pkgs.coreutils pkgs.gnupg ] ;
                                                                                                                    text =
                                                                                                                        ''
                                                                                                                            GNUPGHOME=$( pwd )
                                                                                                                            export GNUPGHOME
                                                                                                                            mkdir --parents "$GNUPGHOME"
                                                                                                                            chmod 0700 "$GNUPGHOME"
                                                                                                                            gpg --batch --yes --homedir "$GNUPGHOME" --import /var/lib/workspaces/secrets/secret-keys.asc 2>&1
                                                                                                                            gpg --batch --yes --homedir "$GNUPGHOME" --import-ownertrust /var/lib/workspaces/secrets/ownertrust.asc 2>&1
                                                                                                                            gpg --batch --yes --homedir "$GNUPGHOME" --update-trustdb 2>&1
                                                                                                                        '' ;
                                                                                                                } ;
                                                                                                        in "${ application }/bin/application" ;
                                                                                                StateDirectory = "workspaces/dot-gnupg" ;
                                                                                                User = config.personal.name ;
                                                                                                WorkingDirectory = "/var/lib/workspaces/dot-gnupg" ;
                                                                                            } ;
                                                                                        unitConfig =
                                                                                            {
                                                                                                ConditionPathExists = "!/var/lib/workspaces/dot-gnupg" ;
                                                                                            } ;
                                                                                        wantedBy = [ "multi-user.target" ] ;
                                                                                    } ;
                                                                                dot-password-store =
                                                                                    {
                                                                                        after = [ "network.target" "network-online.target" "dot-gnupg.service" "dot-ssh.service" ] ;
                                                                                        requires = [ "dot-gnupg.service" "dot-ssh.service" ] ;
                                                                                        serviceConfig =
                                                                                            {
                                                                                                ExecStart =
                                                                                                    let
                                                                                                        application =
                                                                                                            pkgs.writeShellApplication
                                                                                                                {
                                                                                                                    name = "application" ;
                                                                                                                    runtimeInputs = [ pkgs.coreutils pkgs.git ] ;
                                                                                                                    text =
                                                                                                                        ''
                                                                                                                            git init
                                                                                                                            git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F /var/lib/workspaces/dot-ssh/config"
                                                                                                                            git config user.email ${ config.personal.email }
                                                                                                                            git config user.name "${ config.personal.name }"
                                                                                                                            ln --symbolic ${ post-commit } .git/hooks
                                                                                                                            git remote add origin ${ config.personal.pass.remote }
                                                                                                                            git fetch origin ${ config.personal.pass.branch } 2>&1
                                                                                                                            git checkout ${ config.personal.pass.branch } 2>&1
                                                                                                                        '' ;
                                                                                                                } ;
                                                                                                        in "${ application }/bin/application" ;
                                                                                                StateDirectory = "workspaces/dot-password-store" ;
                                                                                                User = config.personal.name ;
                                                                                                WorkingDirectory = "/var/lib/workspaces/dot-password-store" ;
                                                                                            } ;
                                                                                        unitConfig =
                                                                                            {
                                                                                                ConditionPathExists = "!/var/lib/workspaces/dot-password-store" ;
                                                                                            } ;
                                                                                        wants = [ "network-online.target" ] ;
                                                                                        wantedBy = [ "multi-user.target" ] ;
                                                                                    } ;
                                                                                dot-ssh =
                                                                                    {
                                                                                        after = [ "network.target" "secrets.service" ] ;
                                                                                        requires = [ "secrets.service" ] ;
                                                                                        serviceConfig =
                                                                                            {
                                                                                                ExecStart =
                                                                                                    let
                                                                                                        application =
                                                                                                            pkgs.writeShellApplication
                                                                                                                {
                                                                                                                    name = "application" ;
                                                                                                                    runtimeInputs = [ pkgs.age pkgs.coreutils pkgs.gnupg ] ;
                                                                                                                    text =
                                                                                                                        ''
                                                                                                                            cat > config <<EOF
                                                                                                                            HostName github.com
                                                                                                                            Host github.com
                                                                                                                            IdentityFile /var/lib/workspaces/secrets/dot-ssh/boot/identity.asc
                                                                                                                            UserKnownHostsFile /var/lib/workspaces/secrets/dot-ssh/boot/known-hosts.asc
                                                                                                                            StrictHostKeyChecking true

                                                                                                                            HostName 192.168.1.202
                                                                                                                            Host mobile
                                                                                                                            IdentityFile /var/lib/workspaces/secrets/dot-ssh/boot/identity.asc
                                                                                                                            UserKnownHostsFile /var/lib/workspaces/secrets/dot-ssh/boot/known-hosts.asc
                                                                                                                            StrictHostKeyChecking true
                                                                                                                            Port 202
                                                                                                                            EOF
                                                                                                                            chmod 0400 config
                                                                                                                        '' ;
                                                                                                                } ;
                                                                                                        in "${ application }/bin/application" ;
                                                                                                StateDirectory = "workspaces/dot-ssh" ;
                                                                                                User = config.personal.name ;
                                                                                                WorkingDirectory = "/var/lib/workspaces/dot-ssh" ;
                                                                                            } ;
                                                                                        unitConfig =
                                                                                            {
                                                                                                ConditionPathExists = "!/var/lib/workspaces/dot-ssh" ;
                                                                                            } ;
                                                                                        wantedBy = [ "multi-user.target" ] ;
                                                                                    } ;
                                                                                jrnl =
                                                                                    {
                                                                                        after = [ "network.target" "network-online.target" "dot-gnupg.service" "dot-ssh.service" ] ;
                                                                                        requires = [ "dot-ssh.service" ] ;
                                                                                        serviceConfig =
                                                                                            {
                                                                                                ExecStart =
                                                                                                    let
                                                                                                        application =
                                                                                                            pkgs.writeShellApplication
                                                                                                                {
                                                                                                                    name = "application" ;
                                                                                                                    runtimeInputs = [ pkgs.age pkgs.coreutils pkgs.git pkgs.git-crypt pkgs.gnupg ] ;
                                                                                                                    text =
                                                                                                                        ''
                                                                                                                            export GNUPGHOME=/var/lib/workspaces/dot-gnupg
                                                                                                                            git init 2>&1
                                                                                                                            git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F /var/lib/workspaces/dot-ssh/config"
                                                                                                                            git config user.email ${ config.personal.email }
                                                                                                                            git config user.name "${ config.personal.description }"
                                                                                                                            ln --symbolic ${ post-commit } .git/hooks/post-commit
                                                                                                                            git remote add origin ${ config.personal.jrnl.remote }
                                                                                                                            if git fetch origin ${ config.personal.jrnl.branch } 2>&1
                                                                                                                            then
                                                                                                                                git checkout ${ config.personal.jrnl.branch } 2>&1
                                                                                                                                git-crypt unlock
                                                                                                                            else
                                                                                                                                git checkout -b ${ config.personal.jrnl.branch } 2>&1
                                                                                                                                git-crypt init 2>&1
                                                                                                                                echo git-crypt add-gpg-user ${ config.personal.jrnl.recipient } 2>&1
                                                                                                                                git-crypt add-gpg-user ${ config.personal.jrnl.recipient } 2>&1
                                                                                                                                cat > .gitattributes <<EOF
                                                                                                                            config/** filter=git-crypt diff=git-crypt
                                                                                                                            data/** filter=git-crypt diff=git-crypt
                                                                                                                            EOF
                                                                                                                                git-crypt unlock
                                                                                                                                mkdir config
                                                                                                                                touch config/.gitkeep
                                                                                                                                mkdir data
                                                                                                                                git add .gitattributes config/.gitkeep data/.gitkeep journal.txt
                                                                                                                                git commit -m "Initialize git-crypt with .gitattributes" 2>&1
                                                                                                                                git push origin HEAD 2>&1
                                                                                                                            fi
                                                                                                                        '' ;
                                                                                                                } ;
                                                                                                        in "${ application }/bin/application" ;
                                                                                                StateDirectory = "workspaces/jrnl" ;
                                                                                                User = config.personal.name ;
                                                                                                WorkingDirectory = "/var/lib/workspaces/jrnl" ;
                                                                                            } ;
                                                                                        unitConfig =
                                                                                            {
                                                                                                ConditionPathExists = "!/var/lib/workspaces/jrnl" ;
                                                                                            } ;
                                                                                        wants = [ "network-online.target" ] ;
                                                                                        wantedBy = [ "multi-user.target" ] ;
                                                                                    } ;
                                                                                ledger =
                                                                                    {
                                                                                        after = [ "network.target" "network-online.target" "dot-gnupg.service" "dot-ssh.service" ] ;
                                                                                        requires = [ "dot-ssh.service" ] ;
                                                                                        serviceConfig =
                                                                                            {
                                                                                                ExecStart =
                                                                                                    let
                                                                                                        application =
                                                                                                            pkgs.writeShellApplication
                                                                                                                {
                                                                                                                    name = "application" ;
                                                                                                                    runtimeInputs = [ pkgs.age pkgs.coreutils pkgs.git pkgs.git-crypt pkgs.gnupg ] ;
                                                                                                                    text =
                                                                                                                        ''
                                                                                                                            export GNUPGHOME=/var/lib/workspaces/dot-gnupg
                                                                                                                            git init 2>&1
                                                                                                                            git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F /var/lib/workspaces/dot-ssh/config"
                                                                                                                            git config user.email ${ config.personal.email }
                                                                                                                            git config user.name "${ config.personal.description }"
                                                                                                                            ln --symbolic ${ post-commit } .git/hooks/post-commit
                                                                                                                            git remote add origin ${ config.personal.ledger.remote }
                                                                                                                            if git fetch origin ${ config.personal.ledger.branch } 2>&1
                                                                                                                            then
                                                                                                                                git checkout ${ config.personal.ledger.branch } 2>&1
                                                                                                                                git-crypt unlock
                                                                                                                            else
                                                                                                                                git checkout -b ${ config.personal.ledger.branch } 2>&1
                                                                                                                                git-crypt init 2>&1
                                                                                                                                echo git-crypt add-gpg-user ${ config.personal.ledger.recipient } 2>&1
                                                                                                                                git-crypt add-gpg-user ${ config.personal.ledger.recipient } 2>&1
                                                                                                                                cat > .gitattributes <<EOF
                                                                                                                            config/** filter=git-crypt diff=git-crypt
                                                                                                                            data/** filter=git-crypt diff=git-crypt
                                                                                                                            EOF
                                                                                                                                git-crypt unlock
                                                                                                                                mkdir config
                                                                                                                                touch config/.gitkeep
                                                                                                                                mkdir data
                                                                                                                                touch data/.gitkeep
                                                                                                                                git add config data
                                                                                                                                git commit -m "Initialize git-crypt with .gitattributes" 2>&1
                                                                                                                                git push origin HEAD 2>&1
                                                                                                                            fi
                                                                                                                        '' ;
                                                                                                                } ;
                                                                                                        in "${ application }/bin/application" ;
                                                                                                StateDirectory = "workspaces/ledger" ;
                                                                                                User = config.personal.name ;
                                                                                                WorkingDirectory = "/var/lib/workspaces/ledger" ;
                                                                                            } ;
                                                                                        unitConfig =
                                                                                            {
                                                                                                ConditionPathExists = "!/var/lib/workspaces/ledger" ;
                                                                                            } ;
                                                                                        wants = [ "network-online.target" ] ;
                                                                                        wantedBy = [ "multi-user.target" ] ;
                                                                                    } ;
                                                                                repository-private =
                                                                                    {
                                                                                        after = [ "network.target" "dot-ssh.service" ] ;
                                                                                        requires = [ "dot-ssh.service" ] ;
                                                                                        serviceConfig =
                                                                                            {
                                                                                                ExecStart =
                                                                                                    let
                                                                                                        application =
                                                                                                            pkgs.writeShellApplication
                                                                                                                {
                                                                                                                    name = "application" ;
                                                                                                                    runtimeInputs = [ pkgs.coreutils pkgs.git pkgs.libuuid ] ;
                                                                                                                    text =
                                                                                                                        ''
                                                                                                                            git init
                                                                                                                            git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F /var/lib/workspaces/dot-ssh/config"
                                                                                                                            git config user.email ${ config.personal.name }
                                                                                                                            git config user.name ${ config.personal.email }
                                                                                                                            ln --symbolic ${ post-commit } .git/hooks/post-commit
                                                                                                                            git remote add origin ${ config.personal.repository.private.remote }
                                                                                                                            git fetch origin ${ config.personal.repository.private.branch }
                                                                                                                            git checkout origin/${ config.personal.repository.private.branch }
                                                                                                                            git checkout -b scratch/$( uuidgen )
                                                                                                                        '' ;
                                                                                                                } ;
                                                                                                        in "${ application }/bin/application" ;
                                                                                                StateDirectory = "workspaces/repository/private" ;
                                                                                                User = config.personal.name ;
                                                                                                WorkingDirectory = "/var/lib/workspaces/repository/private" ;
                                                                                            } ;
                                                                                        unitConfig =
                                                                                            {
                                                                                                ConditionPathExists = "!/var/lib/workspaces/repository/private" ;
                                                                                            } ;
                                                                                        wants = [ "network-online.target" ] ;
                                                                                        wantedBy = [ "multi-user.target" ] ;
                                                                                    } ;
                                                                                secrets =
                                                                                    {
                                                                                        after = [ "network.target" ] ;
                                                                                        serviceConfig =
                                                                                            {
                                                                                                ExecStart =
                                                                                                    let
                                                                                                        derivation =
                                                                                                            pkgs.stdenv.mkDerivation
                                                                                                                {
                                                                                                                    installPhase =
                                                                                                                        ''
                                                                                                                            mkdir --parents $out/scripts $out/bin
                                                                                                                            find ${ secrets } -type f -name "*.age" | while read -r FILE
                                                                                                                            do
                                                                                                                                RELATIVE_PATH="${ builtins.concatStringsSep "" [ "$" "{" "FILE#${ secrets }/" "}" ] }"
                                                                                                                                RELATIVE_DIRECTORY=$( dirname "$RELATIVE_PATH" )
                                                                                                                                STRIPPED=${ builtins.concatStringsSep "" [ "$" "{" "RELATIVE_PATH%.*" "}" ] }
                                                                                                                                cat >> $out/scripts/application <<EOF
                                                                                                                                mkdir --parents "$RELATIVE_DIRECTORY"
                                                                                                                                age --decrypt --identity "${ config.personal.agenix }" --output "$STRIPPED" "$FILE"
                                                                                                                                chmod 0400 "$STRIPPED"
                                                                                                                            EOF
                                                                                                                            done
                                                                                                                            chmod 0500 $out/scripts/application
                                                                                                                            makeWrapper $out/scripts/application $out/bin/application --set PATH ${ pkgs.lib.makeBinPath [ pkgs.age pkgs.coreutils ] }
                                                                                                                        ''  ;
                                                                                                                    name = "derivation" ;
                                                                                                                    nativeBuildInputs = [ pkgs.coreutils pkgs.findutils pkgs.makeWrapper ] ;
                                                                                                                    src = ./. ;
                                                                                                                } ;
                                                                                                        in "${ derivation }/bin/application" ;
                                                                                                StateDirectory = "workspaces/secrets" ;
                                                                                                User = config.personal.name ;
                                                                                                WorkingDirectory = "/var/lib/workspaces/secrets" ;
                                                                                            } ;
                                                                                        unitConfig =
                                                                                            {
                                                                                                ConditionPathExists = "!/var/lib/workspaces/secrets" ;
                                                                                            } ;
                                                                                        wantedBy = [ "multi-user.target" ] ;
                                                                                    } ;
                                                                                setup =
                                                                                    {
                                                                                        after = [ "network.target" "secrets.service" "dot-gnupg.service" ] ;
                                                                                        serviceConfig =
                                                                                            {
                                                                                            } ;
                                                                                        wants = [ "secrets.service" "dot-gnupg.service" ] ;
                                                                                        wantedBy = [ "multi-user.target" ] ;
                                                                                    } ;
                                                                                teardown =
                                                                                    {
                                                                                        after = [ "network.target" ] ;
                                                                                        serviceConfig =
                                                                                            {
                                                                                                ExecStart =
                                                                                                    let
                                                                                                        application =
                                                                                                            pkgs.writeShellApplication
                                                                                                                {
                                                                                                                    name = "application" ;
                                                                                                                    runtimeInputs = [ pkgs.gnutar pkgs.zstd ] ;
                                                                                                                    text =
                                                                                                                        ''
                                                                                                                            tar --create --file=- . | zstd --long=19 --threads=1 --output="$( mktemp --suffix=.tar.zstd )"
                                                                                                                        '' ;
                                                                                                                } ;
                                                                                                        in "${ application }/bin/application" ;
                                                                                                User = config.personal.name ;
                                                                                                WorkingDirectory = "/home/${ config.personal.name }/workspaces" ;
                                                                                            } ;
                                                                                        wantedBy = [ "multi-user.target" ] ;
                                                                                    } ;
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
                                                                                                                                find /home/${ config.personal.name }/${ config.personal.stash }/direct -mindepth 1 -maxdepth 1 -type d ! -name ${ builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString current-time ) ) } | while read -r DIRECTORY
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
                                                                        setup =
                                                                            {
                                                                                timerConfig =
                                                                                    {
                                                                                        OnCalendar = "hourly" ;
                                                                                    } ;
                                                                            } ;
                                                                        teardown =
                                                                            {
                                                                                timerConfig =
                                                                                    {
                                                                                        OnCalendar = "daily" ;
                                                                                    } ;
                                                                            } ;
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
                                                                        pkgs.jetbrains.idea-community
                                                                        ( ledger "my-ledger" "my-ledger-git" ( foobar [ "personal" "ledger" ] "git" ) ( foobar [ "personal" "ledger" ] "work-tree" ) ( foobar [ "personal" "dot-gnupg" ] "config" ) "calcurse ${ builtins.toString current-time }" )
                                                                        ( gnucash "my-gnucash" ( foobar [ "personal" "gnucash" ] "git" ) ( foobar [ "personal" "gnucash" ] "work-tree" ) ( foobar [ "personal" "dot-gnupg" ] "config" ) "gnucash ${ builtins.toString current-time }" )
                                                                        (
                                                                            pkgs.writeShellApplication
                                                                                {
                                                                                    name = "artifact" ;
                                                                                    runtimeInputs = [ pkgs.coreutils pkgs.libuuid ] ;
                                                                                    text =
                                                                                        ''
                                                                                            echo "$( cat )/$( uuidgen | sha512sum | cut --bytes -128 )" | cut --bytes -64
                                                                                        '' ;
                                                                                }
                                                                        )
                                                                        ( repository "my-private-studio" ( foobar [ "personal" "repository" "private" ] "workspace" ) )
                                                                        ( repository "my-personal-studio" ( foobar [ "personal" "repository" "personal" ] "workspace" ) )
                                                                        ( repository "my-secrets-studio" ( foobar [ "personal" "repository" "secrets" ] "workspace" ) )
                                                                        ( repository "my-stash-studio" ( foobar [ "personal" "repository" "stash" ] "workspace" ) )
                                                                        ( repository "my-visitor-studio" ( foobar [ "personal" "repository" "visitor" ] "workspace" ) )
                                                                        (
                                                                            pkgs.writeShellApplication
                                                                                {
                                                                                    name = "current-time" ;
                                                                                    runtimeInputs = [ pkgs.coreutils ] ;
                                                                                    text =
                                                                                        ''
                                                                                            exec date --date @${ builtins.toString current-time } "$@"
                                                                                        '' ;
                                                                                }
                                                                        )
                                                                        (
                                                                            pkgs.stdenv.mkDerivation
                                                                                {
                                                                                    installPhase =
                                                                                        let
                                                                                            expiry =
                                                                                                ''
                                                                                                    TIMESTAMP=$(date +%s)
                                                                                                    pass git ls-tree -r --name-only HEAD | while IFS= read -r file; do
                                                                                                      [[ "$file" != *.gpg ]] && continue
                                                                                                      last_commit_ts=$( pass git log -1 --format="%at" -- "$file" || echo 0)
                                                                                                      age=$((TIMESTAMP - last_commit_ts))
                                                                                                      if (( age >= DEADLINE )); then
                                                                                                        key="${ builtins.concatStringsSep "" [ "$" "{" "file%.gpg" "}" ] }"
                                                                                                        echo "$key"
                                                                                                      fi
                                                                                                    done
                                                                                                '' ;
                                                                                            phonetic =
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
                                                                                        warn =
                                                                                            ''
                                                                                                ENTRY=${ builtins.concatStringsSep "" [ "$" "{" "1:-" "}" ] }
                                                                                                FILE="$PASSWORD_STORE_DIR/$ENTRY.gpg"
                                                                                                if [[ -z "$ENTRY" || ! -f "$FILE" ]]; then
                                                                                                  echo "Usage: pass warn <entry>" >&2
                                                                                                  exit 1
                                                                                                fi
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
                                                                                                mapfile -t ENCRYPTION_FPRS < <(
                                                                                                  for longid in "${ builtins.concatStringsSep "" [ "$" "{" "LONG_KEY_IDS[@]" "}" ] }"; do
                                                                                                    gpg --with-colons --fingerprint "$longid" 2>/dev/null \
                                                                                                    | awk -F: '/^fpr:/ { print $10; exit }'
                                                                                                  done
                                                                                                )
                                                                                                echo "Corresponding full fingerprints:" >&2
                                                                                                printf '  %s\n' "${ builtins.concatStringsSep "" [ "$" "{" "ENCRYPTION_FPRS[@]" "}" ] }" >&2
                                                                                                mapfile -t CURRENT_FPRS < $PASSWORD_STORE_DIR/.gpg-id
                                                                                                echo "Current trusted key fingerprints:" >&2
                                                                                                printf '  %s\n' "${ builtins.concatStringsSep "" [ "$" "{" "CURRENT_FPRS[@]" "}" ] }" >&2
                                                                                                WARNING=0
                                                                                                for fpr in "${ builtins.concatStringsSep "" [ "$" "{" "ENCRYPTION_FPRS[@]" "}" ] }"; do
                                                                                                  if ! printf '%s\n' "${ builtins.concatStringsSep "" [ "$" "{" "CURRENT_FPRS[@]" "}" ] }" | grep -qx "$fpr"; then
                                                                                                    echo "⚠️  Warning: $ENTRY was encrypted with an unknown or old GPG key fingerprint:" >&2
                                                                                                    echo "   $fpr" >&2
                                                                                                    WARNING=1
                                                                                                  fi
                                                                                                done
                                                                                                pass show "$ENTRY"
                                                                                                exit $WARNING
                                                                                            '' ;
                                                                                            in
                                                                                                ''
                                                                                                    GNUPGHOME=/var/lib/workspaces/dot-gnupg
                                                                                                    PASSWORD_STORE_DIR=/var/lib/workspaces/dot-password-store
                                                                                                    PASSWORD_STORE_GPG_OPTS="--homedir $GNUPGHOME"
                                                                                                    mkdir --parents $out/bin
                                                                                                    makeWrapper \
                                                                                                        ${ pkgs.pass }/bin/pass \
                                                                                                        $out/bin/pass \
                                                                                                        --set PASSWORD_STORE_DIR "$PASSWORD_STORE_DIR" \
                                                                                                        --set PASSWORD_STORE_GPG_OPTS "$PASSWORD_STORE_GPG_OPTS" \
                                                                                                        --set PASSWORD_STORE_GENERATED_LENGTH ${ builtins.toString config.personal.pass.generated-length } \
                                                                                                        --set PASSWORD_STORE_CHARACTER_SET ${ config.personal.pass.character-set } \
                                                                                                        --set PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS ${ config.personal.pass.character-set-no-symbols } \
                                                                                                        --set PASSWORD_STORE_ENABLE_EXTENSIONS true \
                                                                                                        --set PASSWORD_STORE_EXTENSIONS_DIR $out/extensions
                                                                                                    mkdir --parents $out/share/bash-completion/completions
                                                                                                    # ln --symbolic ${ pkgs.pass }/share/bash-completion/completions/pass $out/share/bash-completion/completions
                                                                                                    cat > $out/share/bash-completion/completions/pass <<EOF
                                                                                                      export PASSWORD_STORE_DIR=$PASSWORD_STORE_DIR
                                                                                                      # Set up custom subcommands (they're no-arg extensions)
                                                                                                      _pass_custom_subcommands+=" phonetic expiry warn"

                                                                                                      # Source the original completion logic
                                                                                                      source ${pkgs.pass}/share/bash-completion/completions/pass

                                                                                                      # Patch completion
                                                                                                      __pass_ext_completion() {

                                                                                                        local subcommand="${builtins.concatStringsSep "" [ "\\" "$" "{" "COMP_WORDS[1]" "}" ]}"
                                                                                                        if [[ "${builtins.concatStringsSep "" [ "\\" "$" "{" "subcommand" "}" ]}" == "phonetic" ]] || [[ "${builtins.concatStringsSep "" [ "\\" "$" "{" "subcommand" "}" ]}" == "warn" ]] ; then
                                                                                                          COMP_WORDS[1]="show"
                                                                                                          COMP_LINE="${builtins.concatStringsSep "" [ "\\" "$" "{" "COMP_LINE/phonetic/show" "}" ]}"
                                                                                                          COMP_POINT=${builtins.concatStringsSep "" [ "\\" "$" "{" "#COMP_LINE" "}" ]}
                                                                                                        fi
                                                                                                        local cur prev words cword
                                                                                                        _init_completion || return

                                                                                                        _pass
                                                                                                      }
                                                                                                        # Patch top-level subcommand completion
                                                                                                        __pass_top_level_completion() {
                                                                                                          local cur prev words cword
                                                                                                          _init_completion || return

                                                                                                          local commands="init insert edit generate show rm grep find cp mv git push pull sync otp import ls help version phonetic expiry warn"
                                                                                                          COMPREPLY=( \$( compgen -W "\$commands" -- "\$cur" ) )
                                                                                                        }

                                                                                                        # Remove existing completion
                                                                                                        complete -r pass 2>/dev/null || true

                                                                                                        # Register patched completion for pass:
                                                                                                        # If first word after 'pass', do top-level completion
                                                                                                        # Otherwise, use __pass_ext_completion for subcommand completion
                                                                                                        _pass_combined_completion() {
                                                                                                          local cword
                                                                                                          _get_comp_words_by_ref -n =: cur prev words cword

                                                                                                          if (( cword == 1 )); then
                                                                                                            __pass_top_level_completion
                                                                                                          else
                                                                                                            __pass_ext_completion
                                                                                                          fi
                                                                                                        }

                                                                                                        complete -F _pass_combined_completion pass
                                                                                                    EOF
                                                                                                    mkdir --parents $out/share/man/man1
                                                                                                    gunzip --stdout ${ pkgs.pass }/share/man/man1/pass.1.gz > $out/pass.1
                                                                                                    k=$(grep -n '^\.SH SIMPLE EXAMPLES' $out/pass.1 | cut -d: -f1)
                                                                                                    head --lines $(( $k - 1 )) $out/pass.1 > $out/pass.2
                                                                                                    cat >> $out/pass.2 <<EOF

                                                                                                    .SH EXTENSIONS
                                                                                                    The following custom subcommands are added:

                                                                                                    .TP
                                                                                                    .B phonetic
                                                                                                    Show passwords with phonetic spelling for easier communication.

                                                                                                    .TP
                                                                                                    .B expiry
                                                                                                    Manage password expiration dates and notifications.

                                                                                                    .TP
                                                                                                    .B warn
                                                                                                    Display warnings about password store status.

                                                                                                    EOF
                                                                                                    tail --lines +$k $out/pass.1 >> $out/pass.2
                                                                                                    gzip --to-stdout $out/pass.2 > $out/share/man/man1/pass.1.gz
                                                                                                    # rm $out/pass
                                                                                                    mkdir $out/extensions
                                                                                                    makeWrapper \
                                                                                                        ${ pkgs.writeShellScript "expiry" expiry } \
                                                                                                        $out/extensions/expiry.bash \
                                                                                                        --set PASSWORD_STORE_DIR "$PASSWORD_STORE_DIR" \
                                                                                                        --set DEADLINE ${ builtins.toString config.personal.pass.deadline } \
                                                                                                        --set PATH ${ pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.pass ] }
                                                                                                    makeWrapper \
                                                                                                        ${ pkgs.writeShellScript "phonetic" phonetic } \
                                                                                                        $out/extensions/phonetic.bash \
                                                                                                        --set PASSWORD_STORE_DIR "$PASSWORD_STORE_DIR" \
                                                                                                        --set PASSWORD_STORE_GPG_OPTS "$PASSWORD_STORE_GPG_OPTS" \
                                                                                                        --set PATH ${ pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.pass ] }
                                                                                                    makeWrapper \
                                                                                                        ${ pkgs.writeShellScript "warn" warn } \
                                                                                                        $out/extensions/warn.bash \
                                                                                                        --set PASSWORD_STORE_DIR "$PASSWORD_STORE_DIR" \
                                                                                                        --set GNUPGHOME "$GNUPGHOME" \
                                                                                                        --set PATH ${ pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.gawk pkgs.gnupg pkgs.pass ] }
                                                                                                '' ;
                                                                                    name = "pass" ;
                                                                                    nativeBuildInputs = [ pkgs.coreutils pkgs.gnugrep pkgs.makeWrapper pkgs.gnused pkgs.gzip ] ;
                                                                                    src = ./. ;
                                                                                }
                                                                        )
                                                                        (
                                                                            pkgs.stdenv.mkDerivation
                                                                                {
                                                                                    installPhase =
                                                                                        let
                                                                                            script =
                                                                                                ''
                                                                                                    cleanup ( )
                                                                                                        {
                                                                                                            git -C /var/lib/workspaces/calcurse add config data
                                                                                                            git -C /var/lib/workspaces/calcurse commit -am "" --allow-empty --allow-empty-message
                                                                                                        }
                                                                                                    trap cleanup EXIT
                                                                                                    calcurse -C "$XDG_CONFIG_HOME" -D "$XDG_DATA_HOME" "$@"
                                                                                                '' ;
                                                                                        in
                                                                                            ''
                                                                                                mkdir --parents $out/bin
                                                                                                makeWrapper \
                                                                                                    ${ pkgs.writeShellScript "script" script } \
                                                                                                    $out/bin/calcurse \
                                                                                                    --set CALCURSE_EDITOR ${ pkgs.micro }/bin/micro \
                                                                                                    --set XDG_CONFIG_HOME /var/lib/workspaces/calcurse/config \
                                                                                                    --set XDG_DATA_HOME /var/lib/workspaces/calcurse/data \
                                                                                                    --set PATH ${ pkgs.lib.makeBinPath [ pkgs.git pkgs.git-crypt pkgs.calcurse ] }
                                                                                            '' ;
                                                                                    name = "calcurse" ;
                                                                                    nativeBuildInputs = [ pkgs.coreutils pkgs.makeWrapper ] ;
                                                                                    src = ./. ;
                                                                                }
                                                                        )                                                                        (
                                                                            pkgs.stdenv.mkDerivation
                                                                                {
                                                                                    installPhase =
                                                                                        let
                                                                                            script =
                                                                                                ''
                                                                                                    cleanup ( )
                                                                                                        {
                                                                                                            git -C /var/lib/workspaces/calcurse add config data
                                                                                                            git -C /var/lib/workspaces/calcurse commit -am "" --allow-empty --allow-empty-message
                                                                                                        }
                                                                                                    trap cleanup EXIT
                                                                                                    calcurse -C "$XDG_CONFIG_HOME" -D "$XDG_DATA_HOME" "$@"
                                                                                                '' ;
                                                                                        in
                                                                                            ''
                                                                                                mkdir --parents $out/bin
                                                                                                makeWrapper \
                                                                                                    ${ pkgs.writeShellScript "script" script } \
                                                                                                    $out/bin/calcurse \
                                                                                                    --set CALCURSE_EDITOR ${ pkgs.micro }/bin/micro \
                                                                                                    --set XDG_CONFIG_HOME /var/lib/workspaces/calcurse/config \
                                                                                                    --set XDG_DATA_HOME /var/lib/workspaces/calcurse/data \
                                                                                                    --set PATH ${ pkgs.lib.makeBinPath [ pkgs.git pkgs.git-crypt pkgs.calcurse ] }
                                                                                            '' ;
                                                                                    name = "calcurse" ;
                                                                                    nativeBuildInputs = [ pkgs.coreutils pkgs.makeWrapper ] ;
                                                                                    src = ./. ;
                                                                                }
                                                                        )
                                                                        (
                                                                            pkgs.stdenv.mkDerivation
                                                                                {
                                                                                    installPhase =
                                                                                        let
                                                                                            script =
                                                                                                ''
                                                                                                    cleanup ( )
                                                                                                        {
                                                                                                            git -C /var/lib/workspaces/chromium add config data
                                                                                                            git -C /var/lib/workspaces/chromium commit -am "" --allow-empty --allow-empty-message
                                                                                                        }
                                                                                                    trap cleanup EXIT
                                                                                                    chromium "$@"
                                                                                                '' ;
                                                                                        in
                                                                                            ''
                                                                                                mkdir --parents $out/bin
                                                                                                makeWrapper \
                                                                                                    ${ pkgs.writeShellScript "script" script } \
                                                                                                    $out/bin/chromium \
                                                                                                    --set XDG_CONFIG_HOME /var/lib/workspaces/chromium/config \
                                                                                                    --set XDG_DATA_HOME /var/lib/workspaces/chromium/data \
                                                                                                    --set PATH ${ pkgs.lib.makeBinPath [ pkgs.git pkgs.git-crypt pkgs.chromium ] }
                                                                                            '' ;
                                                                                    name = "chromium" ;
                                                                                    nativeBuildInputs = [ pkgs.coreutils pkgs.makeWrapper ] ;
                                                                                    src = ./. ;
                                                                                }
                                                                        )
                                                                        (
                                                                            pkgs.stdenv.mkDerivation
                                                                                {
                                                                                    installPhase =
                                                                                        let
                                                                                            script =
                                                                                                ''
                                                                                                    cleanup ( )
                                                                                                        {
                                                                                                            git -C /var/lib/workspaces/jrnl add config data
                                                                                                            git -C /var/lib/workspaces/jrnl commit -am "" --allow-empty --allow-empty-message
                                                                                                        }
                                                                                                    trap cleanup EXIT
                                                                                                    jrnl "$@"
                                                                                                '' ;
                                                                                        in
                                                                                            ''
                                                                                                mkdir --parents $out/bin
                                                                                                makeWrapper \
                                                                                                    ${ pkgs.writeShellScript "script" script } \
                                                                                                    $out/bin/jrnl \
                                                                                                    --set XDG_CONFIG_HOME /var/lib/workspaces/jrnl/config \
                                                                                                    --set XDG_DATA_HOME /var/lib/workspaces/jrnl/data \
                                                                                                    --set PATH ${ pkgs.lib.makeBinPath [ pkgs.git pkgs.git-crypt pkgs.jrnl pkgs.micro ] }
                                                                                            '' ;
                                                                                    name = "jrnl" ;
                                                                                    nativeBuildInputs = [ pkgs.coreutils pkgs.makeWrapper ] ;
                                                                                    src = ./. ;
                                                                                }
                                                                        )                                                                        (
                                                                            pkgs.stdenv.mkDerivation
                                                                                {
                                                                                    installPhase =
                                                                                        let
                                                                                            script =
                                                                                                ''
                                                                                                    cleanup ( )
                                                                                                        {
                                                                                                            git -C /var/lib/workspaces/chromium add config data
                                                                                                            git -C /var/lib/workspaces/chromium commit -am "" --allow-empty --allow-empty-message
                                                                                                        }
                                                                                                    trap cleanup EXIT
                                                                                                    chromium "$@"
                                                                                                '' ;
                                                                                        in
                                                                                            ''
                                                                                                mkdir --parents $out/bin
                                                                                                makeWrapper \
                                                                                                    ${ pkgs.writeShellScript "script" script } \
                                                                                                    $out/bin/chromium \
                                                                                                    --set XDG_CONFIG_HOME /var/lib/workspaces/chromium/config \
                                                                                                    --set XDG_DATA_HOME /var/lib/workspaces/chromium/data \
                                                                                                    --set PATH ${ pkgs.lib.makeBinPath [ pkgs.git pkgs.git-crypt pkgs.chromium ] }
                                                                                            '' ;
                                                                                    name = "chromium" ;
                                                                                    nativeBuildInputs = [ pkgs.coreutils pkgs.makeWrapper ] ;
                                                                                    src = ./. ;
                                                                                }
                                                                        )
                                                                        (
                                                                            pkgs.stdenv.mkDerivation
                                                                                {
                                                                                    installPhase =
                                                                                        let
                                                                                            open =
                                                                                                ''
                                                                                                    cleanup ( )
                                                                                                        {
                                                                                                            git -C /var/lib/workspaces/ledger add config data
                                                                                                            git -C /var/lib/workspaces/ledger commit -am "" --allow-empty --allow-empty-message
                                                                                                        }
                                                                                                    trap cleanup EXIT
                                                                                                    touch "$LEDGER_FILE"
                                                                                                    ACCOUNT="$1"  # Default account name
                                                                                                    EQUITY_ACCOUNT="$2"
                                                                                                    AMOUNT="$3"  # Default amount
                                                                                                    DATE="${ builtins.concatStringsSep "" [ "$" "{" "4:-$( date +%Y/%m/%d)" "}" ] }"
                                                                                                    cat > "$LEDGER_FILE" <<EOF
                                                                                                    $DATE Opening Balances
                                                                                                        $ACCOUNT         \$${AMOUNT}
                                                                                                        $EQUITY_ACCOUNT
                                                                                                    EOF
                                                                                                    ledger balance
                                                                                                '' ;
                                                                                            payment =
                                                                                                ''
                                                                                                    cleanup ( )
                                                                                                        {
                                                                                                            git -C /var/lib/workspaces/ledger add config data
                                                                                                            git -C /var/lib/workspaces/ledger commit -am "" --allow-empty --allow-empty-message
                                                                                                        }
                                                                                                    trap cleanup EXIT
                                                                                                    touch "$LEDGER_FILE"
                                                                                                    ACCOUNT="$1"  # Default account name
                                                                                                    EQUITY_ACCOUNT="$2"
                                                                                                    AMOUNT="$3"  # Default amount
                                                                                                    DATE="${ builtins.concatStringsSep "" [ "$" "{" "4:-$( date +%Y/%m/%d)" "}" ] }"
                                                                                                    cat > "$LEDGER_FILE" <<EOF
                                                                                                    $DATE Opening Balances
                                                                                                        $ACCOUNT         \$${AMOUNT}
                                                                                                        $EQUITY_ACCOUNT
                                                                                                    EOF
                                                                                                    ledger balance
                                                                                                '' ;
                                                                                            script =
                                                                                                ''
                                                                                                    touch "$LEDGER_FILE"
                                                                                                    ledger "$@"
                                                                                                '' ;
                                                                                        in
                                                                                            ''
                                                                                                mkdir --parents $out/bin
                                                                                                makeWrapper \
                                                                                                    ${ pkgs.writeShellScript "script" script } \
                                                                                                    $out/bin/ledger \
                                                                                                    --set XDG_CONFIG_HOME /var/lib/workspaces/ledger/config \
                                                                                                    --set XDG_DATA_HOME /var/lib/workspaces/ledger/data \
                                                                                                    --set LEDGER_FILE /var/lib/workspaces/ledger/data/${ config.personal.ledger.file } \
                                                                                                    --set PATH ${ pkgs.lib.makeBinPath [ pkgs.bashInteractive pkgs.coreutils pkgs.git pkgs.git-crypt pkgs.glibcLocales pkgs.gnumake pkgs.ledger pkgs.less ] }
                                                                                                makeWrapper \
                                                                                                    ${ pkgs.writeShellScript "open" open } \
                                                                                                    $out/bin/open-account \
                                                                                                    --set XDG_CONFIG_HOME /var/lib/workspaces/ledger/config \
                                                                                                    --set XDG_DATA_HOME /var/lib/workspaces/ledger/data \
                                                                                                    --set LEDGER_FILE /var/lib/workspaces/ledger/data/${ config.personal.ledger.file } \
                                                                                                    --set PATH ${ pkgs.lib.makeBinPath [ pkgs.bashInteractive pkgs.coreutils pkgs.git pkgs.git-crypt pkgs.glibcLocales pkgs.gnumake pkgs.ledger pkgs.less ] }
                                                                                            '' ;
                                                                                    name = "ledger" ;
                                                                                    nativeBuildInputs = [ pkgs.coreutils pkgs.makeWrapper ] ;
                                                                                    src = ./. ;
                                                                                }
                                                                        )
                                                                        (
                                                                            pkgs.stdenv.mkDerivation
                                                                                {
                                                                                    installPhase =
                                                                                        let
                                                                                            promote =
                                                                                                pkgs.writeShellApplication
                                                                                                    {
                                                                                                        name = "promote" ;
                                                                                                        runtimeInputs = [ pkgs.coreutils pkgs.nix pkgs.nixos-rebuild ] ;
                                                                                                        text =
                                                                                                            ''
                                                                                                                CURRENT_TIME="$( date %s )"
                                                                                                                echo "$CURRENT_TIME" > /var/lib/workspaces/repository/private/current-time.nix
                                                                                                                git -C /var/lib/workspaces/repository/personal commit -am "$CURRENT_TIME" --allow-empty
                                                                                                                git -C /var/lib/workspaces/repository/personal rev-parse HEAD > /var/lib/workspaces/repository/private/personal.hash
                                                                                                                git -C /var/lib/workspace/repository/secrets commit -am "$CURRENT_TIME" --allow-empty
                                                                                                                git -C /var/lib/workspaces/repository/secrets rev-parse HEAD > /var/lib/workspaces/repository/secrets.hash
                                                                                                                if ! nix flake check --override-input personal /var/lib/workspaces/repository/personal --override-input secrets /var/lib/workspaces/repository/secrets /var/lib/workspaces/repository/private
                                                                                                                then
                                                                                                                    MESSAGE="The private repository failed checks at $TIMESTAMP"
                                                                                                                    git -C /var/lib/workspaces/repository/private commit -am "$MESSAGE"
                                                                                                                    echo "$MESSAGE"
                                                                                                                    exit 64
                                                                                                                fi
                                                                                                                rm --force nixos.qcow2 result
                                                                                                                if nixos-rebuild build-vm --override-input personal /var/lib/workspaces/repository/personal --override-input secrets /var/lib/workspaces/repository/secrets --flake /var/lib/workspaces/repository/private
                                                                                                                then
                                                                                                                    if result/bin/run-nixos-vm
                                                                                                                    then
                                                                                                                        SATISFACTORY=""
                                                                                                                        while [[ "$SATISFACTORY" != "y" ]] && [[ "$SATISFACTORY" != "n" ]]
                                                                                                                        do
                                                                                                                            read -p "Was the run satisfactory? y/n " SATISFACTORY
                                                                                                                        done
                                                                                                                        if [[ "$SATISFACTORY" == "y" ]]
                                                                                                                        then
                                                                                                                            git -C /var/lib/workspaces/repository/personal checkout -b scratch/$( uuidgen )
                                                                                                                            git -C /var/lib/workspaces/repository/personal fetch origin main
                                                                                                                            if [[ ! -z "$( git -C /var/lib/workspaces/repository/personal diff origin/main )" ]]
                                                                                                                            then
                                                                                                                                git -C /var/lib/workspaces/repository/personal diff origin/main
                                                                                                                                read -p "Describe the changes in personal:  " CHANGES
                                                                                                                                git -C /var/lib/workspaces/repository/personal reset --soft origin/main
                                                                                                                                git -C /var/lib/workspaces/repository/personal commit -am "$CHANGES"
                                                                                                                                gh pr create --title "Add feature X" --body "This adds feature X to fix issue Y." --base main --head my-feature-branch
                                                                                                                            git -C /var/lib/workspaces/repository/secrets checkout -b scratch/$( uuidgen )
                                                                                                                            git -C /var/lib/workspaces/repository/secrets fetch origin main
                                                                                                                            if [[ ! -z "$( git -C /var/lib/workspaces/repository/personal diff origin/main )" ]]
                                                                                                                            then
                                                                                                                                git -C /var/lib/workspaces/repository/secrets diff origin/main
                                                                                                                                read -p "Describe the changes in personal:  " CHANGES
                                                                                                                                git -C /var/lib/workspaces/repository/secrets reset --soft origin/main
                                                                                                                                git -C /var/lib/workspaces/repository/secrets commit -am "$CHANGES"
                                                                                                                                gh pr create --title "Add feature X" --body "This adds feature X to fix issue Y." --base main --head my-feature-branch
                                                                                                                                rm result
                                                                                                                                while [[ ! -z "$( git -C /var/lib/workspaces/repository/personal diff origin/main )" ]] && [[ ! -z "$( git -C /var/lib/workspaces/repository/secrets diff origin/main )" ]]
                                                                                                                                do
                                                                                                                                    sleep 1s
                                                                                                                                done
                                                                                                                                if ! nixos-rebuild build-vm-with-bootloader --update-vm personal --update-vm secrets --flake /var/lib/workspaces/repository/private
                                                                                                                                then
                                                                                                                                    MESSAGE="The private repository failed to build the vm with bootloader from github sources at $TIMESTAMP"
                                                                                                                                    git -C /var/lib/workspaces/repository/private commit -am "$MESSAGE"
                                                                                                                                    echo "$MESSAGE"
                                                                                                                                    exit 64
                                                                                                                                fi
                                                                                                                                if result/bin/run-nixos-vm
                                                                                                                                then
                                                                                                                                    SATISFACTORY=""
                                                                                                                                    while [[ "$SATISFACTORY" != "y" ]] && [[ "$SATISFACTORY" != "n" ]]
                                                                                                                                    do
                                                                                                                                        read -p "Was the run satisfactory? y/n " SATISFACTORY
                                                                                                                                    done
                                                                                                                                    if [[ "$SATISFACTORY" != "y" ]]
                                                                                                                                    then
                                                                                                                                        git -C /var/lib/workspaces/repository/private fetch origin development
                                                                                                                                        git -C /var/lib/workspaces/repository/private diff origin/development
                                                                                                                                        read -p "Success Message:  " MESSAGE
                                                                                                                                        git -C /var/lib/workspaces/repository/private commit -am "DEVELOPMENT SUCCESS AT $TIMESTAMP:  $SUCCESS_MESSAGE"
                                                                                                                                        SCRATCH="scratch/$( uuidgen )"
                                                                                                                                        git -C /var/lib/workspaces/repository/private checkout -b "$SCRATCH}"
                                                                                                                                        git -C /var/lib/workspaces/repository/private reset origin/development
                                                                                                                                        git -C /var/lib/workspaces/repository/private checkout development
                                                                                                                                        git -C /var/lib/workspaces/repository/private rebase origin/development
                                                                                                                                        git -C /var/lib/workspaces/repository/private rebase "$SCRATCH"
                                                                                                                                        git -C /var/lib/workspacews
                                                                                                                                        if sudo nixos-rebuild test --flake /var/lib/workspaces/repository/private
                                                                                                                                        then
                                                                                                                                            SATISFACTORY=""
                                                                                                                                            while [[ "$SATISFACTORY" != "y" ]] && [[ "$SATISFACTORY" != "n" ]]
                                                                                                                                            do
                                                                                                                                                read -p "Was the run satisfactory? y/n " SATISFACTORY
                                                                                                                                            done
                                                                                                                                            if [[ "$SATISFACTORY" == "y" ]]
                                                                                                                                            then
                                                                                                                                                git -C /var/lib/repository/private fetch origin main
                                                                                                                                                SCRATCH="scratch/$( uuidgen )
                                                                                                                                                git -C /var/lib/repository/private fetch origin development
                                                                                                                                                git -C /var/lib/repository/private checkout -b "$SCRATCH"
                                                                                                                                                git -C /var/lib/repository/private reset --soft origin/development
                                                                                                                                                git -C /var/lib/repository/private commit -am "$MESSAGE"
                                                                                                                                                git -C /var/lib/repository/private checkout origin/development
                                                                                                                                                git -C /var/lib/repository/private rebase "$SCRATCH"
                                                                                                                                                git -C /var/lib/repository/private checkout -b scratch/$( uuidgen )
                                                                                                                                                if sudo nixos-rebuild switch --flake /var/lib/workspaces/repository/private
                                                                                                                                                then
                                                                                                                                                    SATISFACTORY=""
                                                                                                                                                    while [[ "$SATISFACTORY" != "y" ]] && [[ "$SATISFACTORY" != "n" ]]
                                                                                                                                                    do
                                                                                                                                                        read -p "Was the switch satisfactory? y/n " SATISFACTORY
                                                                                                                                                    done
                                                                                                                                                    if [[ "$SATISFACTORY" == "y" ]]
                                                                                                                                                    then
                                                                                                                                                        read -p "Details:  " DETAILS
                                                                                                                                                        MESSAGE="The promotion was successful on switch at $TIMESTAMP:  $DETAILS"
                                                                                                                                                        git -C /var/lib/repository/private commit -am "$MESSAGE"
                                                                                                                                                        git -C /var/lib/repository/private fetch origin main
                                                                                                                                                        git -C /var/lib/repository/private reset --soft origin/main
                                                                                                                                                        git -C /var/lib/repository/private commit -am "$MESSAGE"
                                                                                                                                                        git -C /var/lib/repository/private checkout main
                                                                                                                                                        git -C /var/lib/repository/private rebase origin/main
                                                                                                                                                        git -C /var/lib/repository/private rebase "$SCRATCH"
                                                                                                                                                        exit 0
                                                                                                                                                    elif [[ "$SATISFACTORY" == "n" ]]
                                                                                                                                                    then
                                                                                                                                                        read -p "Details:  " DETAILS
                                                                                                                                                        MESSAGE="The private repository ran unsatisfactory on switch at $TIMESTAMP:  $DETAILS:"
                                                                                                                                                        echo "$MESSAGE"
                                                                                                                                                        exit 64
                                                                                                                                                    fi
                                                                                                                                                else
                                                                                                                                                    MESSAGE="The private repository failed to build switch at $TIMESTAMP"
                                                                                                                                                    git -C /var/lib/repository/private commit -am "$MESSAGE"
                                                                                                                                                    echo "$MESSAGE"
                                                                                                                                                    exit 64
                                                                                                                                                fi
                                                                                                                                            else
                                                                                                                                                read -p "Details:  " DETAILS
                                                                                                                                                MESSAGE="The private repository ran unsatisfactory on development at $TIMSTAMP:  $DETAILS"
                                                                                                                                                git -C /var/lib/workspaces/repository/private commit -am "$MESSAGE"
                                                                                                                                                echo "$MESSAGE"
                                                                                                                                                exit 64
                                                                                                                                            fi
                                                                                                                                        else
                                                                                                                                            MESSAGE="The private repository failed to build development at $TIMESTAMP"
                                                                                                                                            git -C /var/lib/workspaces/repository/private commit -am "$MESSAGE"
                                                                                                                                            echo "$MESSAGE"
                                                                                                                                            exit 64
                                                                                                                                        fi
                                                                                                                                    elif [[ "$SATISFACTORY" != "n" ]]
                                                                                                                                        read -p "Details:  " DETAILS
                                                                                                                                        MESSAGE="The private repository ran unsatisfactory from github at $TIMESTAMP: $DETAILS"
                                                                                                                                        git -C /var/lib/workspaces/repository/private commit -am "$MESSAGE"
                                                                                                                                        echo "$MESSAGE"
                                                                                                                                        exit 64
                                                                                                                                    fi
                                                                                                                                else
                                                                                                                                    MESSAGE="The private repository failed to run the vm with bootloader from github sources at $TIMESTAMP"
                                                                                                                                    git -C /var/lib/workspaces/repository/private commit -am "$MESSAGE"
                                                                                                                                    echo "$MESSAGE"
                                                                                                                                    exit 64
                                                                                                                                fi

                                                                                                                            fi
                                                                                                                        elif [[ "$SATISFACTORY" == "n" ]]
                                                                                                                        then
                                                                                                                            read -p "Details:  " DETAILS
                                                                                                                            MESSAGE="The private repository ran unsatisfactory from local sources at $TIMESTAMP:  $DETAILS"
                                                                                                                            git -C /var/lib/workspaces/repository/private commit -am "MESSAGE"
                                                                                                                            echo "$MESSAGE"
                                                                                                                            exit 64
                                                                                                                        fi
                                                                                                                    else
                                                                                                                        MESSAGE="The private repository failed to run the vm from local sources at $TIMESTAMP"
                                                                                                                        git -C /var/lib/workspaces/repository/private commit -am "$MESSAGE"
                                                                                                                        echo "$MESSAGE"
                                                                                                                        exit 64
                                                                                                                    fi
                                                                                                                else
                                                                                                                    MESSAGE="The private repository failed to build the vm from local sources at $TIMESTAMP"
                                                                                                                    git -C /var/lib/workspaces/repository/private commit -am "$MESSAGE"
                                                                                                                    echo "$MESSAGE"
                                                                                                                    exit 64
                                                                                                                fi
                                                                                                            '' ;
                                                                                                    } ;
                                                                                            in
                                                                                                ''
                                                                                                    makeWrapper \
                                                                                                        ${ pkgs.jetbrains.idea-community }/bin/idea-community \
                                                                                                        $out/bin/idea-community \
                                                                                                        --add-flags /var/lib/workspaces/repository/private \
                                                                                                        --set LD_LIBRARY_PATH pkgs.e2fsprogs \
                                                                                                        --set PATH ${ pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.git promote ] }
                                                                                                '' ;
                                                                                    name = "private" ;
                                                                                    nativeBuildInputs = [ pkgs.coreutils pkgs.makeWrapper ] ;
                                                                                    src = ./. ;
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
                                                                calcurse =
                                                                    {
                                                                        branch = lib.mkOption { default = "artifact/b4cd8c0c6133a53020e6125e4162332e5fdb99902d3b53240045d0a" ; type = lib.types.str ; } ;
                                                                        recipient = lib.mkOption { default = "688A5A79ED45AED4D010D56452EDF74F9A9A6E20" ; type = lib.types.str ; } ;
                                                                        remote = lib.mkOption { default = "git@github.com:AFnRFCb7/artifacts.git" ; type = lib.types.str ; } ;
                                                                    } ;
                                                                chromium =
                                                                    {
                                                                        branch = lib.mkOption { default = "artifact/eb5e3536f8f42f3e6d42d135cc85c4e0df4b955faaf7d221a0ed5ef" ; type = lib.types.str ; } ;
                                                                        recipient = lib.mkOption { default = "688A5A79ED45AED4D010D56452EDF74F9A9A6E20" ; type = lib.types.str ; } ;
                                                                        remote = lib.mkOption { default = "git@github.com:AFnRFCb7/artifacts.git" ; type = lib.types.str ; } ;
                                                                    } ;
                                                                current-time = lib.mkOption { type = lib.types.path ; } ;
                                                                description = lib.mkOption { type = lib.types.str ; } ;
                                                                email = lib.mkOption { type = lib.types.str ; } ;
                                                                git-crypt = lib.mkOption { default = "" ; type = lib.types.str ; } ;
                                                                gnucash =
                                                                    {
                                                                        branch = lib.mkOption { default = "artifact/021fcf9e3792326d96e0610ef0aaa60036d230fa3e18a2a3fffab22" ; type = lib.types.str ; } ;
                                                                        recipient = lib.mkOption { default = "688A5A79ED45AED4D010D56452EDF74F9A9A6E20" ; type = lib.types.str ; } ;
                                                                        remote = lib.mkOption { default = "git@github.com:AFnRFCb7/artifacts.git" ; type = lib.types.str ; } ;
                                                                    } ;
                                                                jrnl =
                                                                    {
                                                                        branch = lib.mkOption { default = "artifact/26cd15c3965a659263334b9ffc8b01020a1e5b6fe84fddc66c98b51" ; type = lib.types.str ; } ;
                                                                        recipient = lib.mkOption { default = "688A5A79ED45AED4D010D56452EDF74F9A9A6E20" ; type = lib.types.str ; } ;
                                                                        remote = lib.mkOption { default = "git@github.com:AFnRFCb7/artifacts.git" ; type = lib.types.str ; } ;
                                                                    } ;
                                                                hash-length = lib.mkOption { default = 16 ; type = lib.types.int ; } ;
                                                                ledger =
                                                                    {
                                                                        branch = lib.mkOption { default = "artifact/32c193fb3a5310462e48a7c5174d9c3110f83077d13de52a9a80a40" ; type = lib.types.str ; } ;
                                                                        file = lib.mkOption { default = "ledger.txt" ; type = lib.types.str ; } ;
                                                                        recipient = lib.mkOption { default = "688A5A79ED45AED4D010D56452EDF74F9A9A6E20" ; type = lib.types.str ; } ;
                                                                        remote = lib.mkOption { default = "git@github.com:AFnRFCb7/artifacts.git" ; type = lib.types.str ; } ;
                                                                    } ;
                                                                name = lib.mkOption { type = lib.types.str ; } ;
                                                                pass =
                                                                    {
                                                                        branch = lib.mkOption { default = "scratch/8060776f-fa8d-443e-9902-118cf4634d9e" ; type = lib.types.str ; } ;
                                                                        character-set = lib.mkOption { default = ".,_=2345ABCDEFGHJKLMabcdefghjkmn" ; type = lib.types.str ; } ;
                                                                        character-set-no-symbols = lib.mkOption { default = "6789NPQRSTUVWXYZpqrstuvwxyz" ; type = lib.types.str ; } ;
                                                                        deadline = lib.mkOption { default = 60 * 60 * 24 * 366 ; type = lib.types.int ; } ;
                                                                        generated-length = lib.mkOption { default = 25 ; type = lib.types.int ; } ;
                                                                        remote = lib.mkOption { default = "git@github.com:nextmoose/secrets.git" ; type = lib.types.str ; } ;
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
                            in
                                {
                                    module = module ;
                                    tests.${ system } =
                                        let
                                            pkgs = builtins.getAttr system nixpkgs.legacyPackages ;
                                            visitors =
                                                {
                                                    lambda = path : value : "103a798535e88ad24601208d72f211c8fee7decc327a92eaaa20a1734491cc3b43457a7656217632c22264b35d9dc558ee5663870936ac1cbabd2b16154df853" ;
                                                    null = path : value : "283b18f4ec295dd925b61a760258a3bda187b170b92ccd75158f603b78181ff9f6bf4e216e09c74ee9a811af7aeb2b7abed9d4610eec0c899dd3f87d387d8c0a" ;
                                                } ;
                                            in
                                                {
                                                    visitor-bool = visitor.lib.test pkgs false false visitors true ;
                                                    visitor-float = visitor.lib.test pkgs false false visitors 0.0 ;
                                                    visitor-int = visitor.lib.test pkgs false false visitors 0 ;
                                                    visitor-list = visitor.lib.test pkgs [ "103a798535e88ad24601208d72f211c8fee7decc327a92eaaa20a1734491cc3b43457a7656217632c22264b35d9dc558ee5663870936ac1cbabd2b16154df853" [ ] "283b18f4ec295dd925b61a760258a3bda187b170b92ccd75158f603b78181ff9f6bf4e216e09c74ee9a811af7aeb2b7abed9d4610eec0c899dd3f87d387d8c0a" { } ] true visitors [ ( x : x ) [ ] null { } ] ;
                                                    visitor-lambda = visitor.lib.test pkgs "103a798535e88ad24601208d72f211c8fee7decc327a92eaaa20a1734491cc3b43457a7656217632c22264b35d9dc558ee5663870936ac1cbabd2b16154df853" true visitors ( x : x ) ;
                                                    visitor-null = visitor.lib.test pkgs "283b18f4ec295dd925b61a760258a3bda187b170b92ccd75158f603b78181ff9f6bf4e216e09c74ee9a811af7aeb2b7abed9d4610eec0c899dd3f87d387d8c0a" true visitors null ;
                                                    visitor-path = visitor.lib.test pkgs false false visitors ./. ;
                                                    visitor-set = visitor.lib.test pkgs { lambda = "103a798535e88ad24601208d72f211c8fee7decc327a92eaaa20a1734491cc3b43457a7656217632c22264b35d9dc558ee5663870936ac1cbabd2b16154df853" ; list = [ ] ; null = "283b18f4ec295dd925b61a760258a3bda187b170b92ccd75158f603b78181ff9f6bf4e216e09c74ee9a811af7aeb2b7abed9d4610eec0c899dd3f87d387d8c0a" ; set = { } ; } true visitors { lambda = x : x ; list = [ ] ; null = null ; set = { } ; } ;
                                                    visitor-string = visitor.lib.test pkgs false false visitors "" ;
                                                } ;
                                } ;
            } ;
}
