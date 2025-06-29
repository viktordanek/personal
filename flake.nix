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
                                                                                    dependencies = tree : { dot-ssh = tree.personal.dot-ssh.mobile ; personal = tree.personal.repository.personal ; secrets = tree.personal.repository.secrets ; visitor = tree.personal.repository.visitor ; } ;
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
                                                                                                                                            --override-input secrets ${ dependencies.personal.workspace }/work-tree \
                                                                                                                                            --override-input secrets ${ dependencies.personal.workspace }/worktree \
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
                                                                                                                                        nixos-rebuild build-vm --flake ${ outputs.workspace }/work-tree#myhost --update-input personal --update-input secrets --update-input visitor
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
                                                                                                if git getch origin main 2>&1
                                                                                                then
                                                                                                    git checkout origin/main 2>&1
                                                                                                else
                                                                                                    git checkout -b main 2>&1
                                                                                                    git commit -m "" --allow-empty --allow-empty-messageq
                                                                                                    git push origin HEAD
                                                                                                fi
                                                                                                git checkout -b "scratch/$( uuidgen )"
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
                                        foobar = path : output : builtins.concatStringsSep "/" ( builtins.concatLists [ [ "" "home" config.personal.name config.personal.stash "direct" ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString config.personal.current-time ) ) ) ] ( builtins.map builtins.toJSON path ) [ "mount" output ] ] ) ;
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
                                                                                                                                value = builtins.concatStringsSep "/" [ "" "home" config.personal.name config.personal.stash "direct" ( builtins.substring 0 config.personal.hash-length ( builtins.hashString "sha512" ( builtins.toString config.personal.current-time ) ) ) value "mount" output ] ;
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
                                        pass =
                                            password-store-dir : git-dir : dot-gnupg :
                                                pkgs.stdenv.mkDerivation
                                                    {
                                                        installPhase =
                                                            let
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
                                                                                                        export PASSWORD_STORE_DIR=${ password-store-dir }
                                                                                                        export GIT_WORK_TREE=${ password-store-dir }
                                                                                                        export GIT_DIR=${ git-dir }
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
                                                                                                    export GNUPGHOME=${ password-store-dir }
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

                                                                                                    mapfile -t CURRENT_FPRS < ${ password-store-dir }/.gpg-id


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
                                                                completion =
                                                                    # pkgs.writeShellApplication
                                                                    #     {
                                                                    #         name = "completion" ;
                                                                    #        text =
                                                                                ''
                                                                                    export PASSWORD_STORE_DIR=${ password-store-dir }
                                                                                    # shellcheck disable=SC1091
                                                                                    source ${ pkgs.pass }/share/bash-completion/completions/pass
                                                                                '' ;
                                                                    #    } ;
                                                                in
                                                                    ''
                                                                        mkdir --parents $out/bin
                                                                        GNUPGHOME=${ dot-gnupg }
                                                                        makeWrapper \
                                                                            ${ pkgs.pass }/bin/pass \
                                                                            $out/bin/pass \
                                                                            --set PASSWORD_STORE_DIR ${ password-store-dir } \
                                                                            --set PASSWORD_STORE_GPG_OPTS "--homedir $GNUPGHOME" \
                                                                            --set PASSWORD_STORE_ENABLE_EXTENSIONS true \
                                                                            --set PASSWORD_STORE_EXTENSIONS_DIR $extensions \
                                                                            --set PASSWORD_STORE_CHARACTER_SET ${ config.personal.pass.character-set } \
                                                                            --set PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS ${ config.personal.pass.character-set-no-symbols } \
                                                                            --set PASSWORD_STORE_GENERATED_LENGTH ${ builtins.toString config.personal.pass.generated-length }
                                                                        mkdir --parents $extensions
                                                                        ln --symbolic ${ password-store-extensions-dir }/* $extensions
                                                                        mkdir --parents $out/share/bash-completion/completions
                                                                        ln --symbolic ${ pkgs.writeShellScript "completion" completion } $out/share/bash-completion/completions/pass
                                                                        mkdir --parents $out/share/man/man1
                                                                        ln --symbolic ${ pkgs.pass }/share/man/man1/pass.1.gz $out/share/man/man1/pass.1.gz
                                                                    '' ;
                                                       name = "pass" ;
                                                       nativeBuildInputs = [ pkgs.coreutils pkgs.makeWrapper pkgs.pass ] ;
                                                       outputs = [ "out" "extensions" ] ;
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
                                                                bash.interactiveShellInit = ''eval "$( ${ pkgs.direnv }/bin/direnv hook bash )"'' ;
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
                                                                        setup
                                                                        teardown
                                                                        pkgs.jetbrains.idea-community
                                                                        ( pass ( foobar [ "personal" "pass" ] "work-tree" ) ( foobar [ "personal" "pass" ] "git" ) ( foobar [ "personal" "dot-gnupg" ] "config" ) )
                                                                        ( calcurse "my-calcurse" "my-calcurse-git" ( foobar [ "personal" "calcurse" ] "git" ) ( foobar [ "personal" "calcurse" ] "work-tree" ) ( foobar [ "personal" "dot-gnupg" ] "config" ) "calcurse ${ builtins.toString config.personal.current-time }" )
                                                                        ( chromium "my-chromium" ( foobar [ "personal" "chromium" ] "git" ) ( foobar [ "personal" "chromium" ] "work-tree" ) ( foobar [ "personal" "dot-gnupg" ] "config" ) "Chromium ${ builtins.toString config.personal.current-time }" )
                                                                        ( ledger "my-ledger" "my-ledger-git" ( foobar [ "personal" "ledger" ] "git" ) ( foobar [ "personal" "ledger" ] "work-tree" ) ( foobar [ "personal" "dot-gnupg" ] "config" ) "calcurse ${ builtins.toString config.personal.current-time }" )
                                                                        ( gnucash "my-gnucash" ( foobar [ "personal" "gnucash" ] "git" ) ( foobar [ "personal" "gnucash" ] "work-tree" ) ( foobar [ "personal" "dot-gnupg" ] "config" ) "gnucash ${ builtins.toString config.personal.current-time }" )
                                                                        ( jrnl "my-jrnl" "my-jrnl-git" ( foobar [ "personal" "jrnl" ] "git" ) ( foobar [ "personal" "jrnl" ] "work-tree" ) ( foobar [ "personal" "dot-gnupg" ] "config" ) "jrnl ${ builtins.toString config.personal.current-time }" )
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
                                                                        branch = lib.mkOption { default = "artifact/21c0167f9fc25f1c81ea166a7ea6e0171865527ef2df34ffc1931c6" ; type = lib.types.str ; } ;
                                                                        recipient = lib.mkOption { default = "688A5A79ED45AED4D010D56452EDF74F9A9A6E20" ; type = lib.types.str ; } ;
                                                                        remote = lib.mkOption { default = "git@github.com:AFnRFCb7/artifacts.git" ; type = lib.types.str ; } ;
                                                                    } ;
                                                                chromium =
                                                                    {
                                                                        branch = lib.mkOption { default = "artifact/b2a2033a2db62fc7171d9755573f34ef1f662922273aa0b642b80aa" ; type = lib.types.str ; } ;
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
                                                                        branch = lib.mkOption { default = "artifact/6787fa9629bad98dde0ad1a1ae5ee50f4dab6a81fa543ee68275307" ; type = lib.types.str ; } ;
                                                                        recipient = lib.mkOption { default = "688A5A79ED45AED4D010D56452EDF74F9A9A6E20" ; type = lib.types.str ; } ;
                                                                        remote = lib.mkOption { default = "git@github.com:AFnRFCb7/artifacts.git" ; type = lib.types.str ; } ;
                                                                    } ;
                                                                hash-length = lib.mkOption { default = 16 ; type = lib.types.int ; } ;
                                                                ledger =
                                                                    {
                                                                        branch = lib.mkOption { default = "artifact/0aa409110e55f05015414c3c8cbf05505392815bd992acb86958db8" ; type = lib.types.str ; } ;
                                                                        recipient = lib.mkOption { default = "688A5A79ED45AED4D010D56452EDF74F9A9A6E20" ; type = lib.types.str ; } ;
                                                                        remote = lib.mkOption { default = "git@github.com:AFnRFCb7/artifacts.git" ; type = lib.types.str ; } ;
                                                                    } ;
                                                                name = lib.mkOption { type = lib.types.str ; } ;
                                                                pass =
                                                                    {
                                                                        branch = lib.mkOption { default = "scratch/8060776f-fa8d-443e-9902-118cf4634d9e" ; type = lib.types.str ; } ;
                                                                        character-set = lib.mkOption { default = ".,_=2345ABCDEFGHJKLMabcdefghjkmn" ; type = lib.types.str ; } ;
                                                                        character-set-no-symbols = lib.mkOption { default = "6789NPQRSTUVWXYZpqrstuvwxyz" ; type = lib.types.str ; } ;
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
