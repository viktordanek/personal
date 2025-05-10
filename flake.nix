{
    inputs =
        {
            environment-variable.url = "github:viktordanek/environment-variable" ;
	        flake-utils.url = "github:numtide/flake-utils" ;
	        nixpkgs.url = "github:Nixos/nixpkgs/nixos-24.05" ;
        } ;
    outputs =
        { environment-variable , flake-utils , nixpkgs , self } :
            let
                fun =
                    system :
                        let
                            _environment-variable = builtins.getAttr system environment-variable.lib ;
                            lib =
                                { config , lib , pkgs , ... } :
                                    {
                                        config =
                                            {
                                                boot.loader =
                                                    {
                                                        efi.canTouchEfiVariables = true ;
                                                        systemd-boot.enable = true ;
                                                    } ;
                                                environment.sessionVariables =
                                                    {
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
                                                        github-runners = { } ;
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
                                                systemd.services =
                                                    {
                                                        commit =
                                                            {
                                                                after = [ "network.target" "redis.service" ] ;
                                                                serviceConfig =
                                                                    {
                                                                        ExecStart =
                                                                            let
                                                                                user-environment =
                                                                                    pkgs.buildFHSUserEnv
                                                                                        {
                                                                                            extraBwrapArgs =
                                                                                                [
                                                                                                    "--ro-bind ${ _environment-variable "TEMPORARY" } /work"
                                                                                                    "--bind ${ _environment-variable "OUTPUT" } /output"
                                                                                                ] ;
                                                                                            name  = "user-environment" ;
                                                                                            profile =
                                                                                                ''
                                                                                                    export GIT_DIR=/output/git &&
                                                                                                        export GIT_WORK_TREE=/output/tree
                                                                                                '' ;
                                                                                            runScript =
                                                                                                pkgs.writeShellScript
                                                                                                    "script"
                                                                                                    ''
                                                                                                        ${ pkgs.coreutils }/bin/echo -en "BRANCH=${ _environment-variable "BRANCH" } \nCOMMIT_HASH=${ _environment-variable "COMMIT_HASH" } \nORIGIN=${ _environment-variable "ORIGIN" } \nPAYLOAD=${ _environment-variable "PAYLOAD" } \nTEMPORARY=${ _environment-variable "TEMPORARY" } \nUSER=${ _environment-variable "USER" }" > /output/env &&
                                                                                                            ${ pkgs.coreutils }/bin/cp --recursive /work/${ _environment-variable "USER" }/.ssh /output/.ssh &&
                                                                                                            ${ pkgs.coreutils }/bin/mkdir ${ _environment-variable "GIT_DIR" } &&
                                                                                                            ${ pkgs.coreutils }/bin/mkdir ${ _environment-variable "GIT_WORK_TREE" } &&
                                                                                                            ${ pkgs.git }/bin/git init &&
                                                                                                            ${ pkgs.git }/bin/git remote add origin ${ _environment-variable "ORIGIN" } &&
                                                                                                            ${ pkgs.git }/bin/git remote add local /work/${ _environment-variable "USER" }/git &&
                                                                                                            ${ pkgs.git }/bin/git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F ${ _environment-variable "OUTPUT" }/.ssh/config" &&
                                                                                                            ${ pkgs.git }/bin/git fetch local ${ _environment-variable "BRANCH" } &&
                                                                                                            ${ pkgs.git }/bin/git remote remove local &&
                                                                                                            ${ pkgs.git }/bin/git checkout ${ _environment-variable "COMMIT_HASH" } &&
                                                                                                            ${ pkgs.coreutils }/bin/cp --recursive /work/${ _environment-variable "USER" }/signals /output/signals
                                                                                                    '' ;
                                                                                        } ;
                                                                                in
                                                                                    pkgs.writeShellScript
                                                                                        "commit"
                                                                                        ''
                                                                                            ${ pkgs.redis }/bin/redis-cli SUBSCRIBE commit | while read -r LINE
                                                                                            do
                                                                                                if [ "${ _environment-variable "LINE" }" == "message" ]
                                                                                                then
                                                                                                    read -r CHANNEL &&
                                                                                                        read -r PAYLOAD &&
                                                                                                        export PAYLOAD &&
                                                                                                        export BRANCH=$( ${ pkgs.coreutils }/bin/echo ${ _environment-variable "PAYLOAD" } | ${ pkgs.jq }/bin/jq --raw-output ".branch" ) &&
                                                                                                        export COMMIT_HASH=$( ${ pkgs.coreutils }/bin/echo ${ _environment-variable "PAYLOAD" } | ${ pkgs.jq }/bin/jq --raw-output ".commit_hash" ) &&
                                                                                                        export ORIGIN=$( ${ pkgs.coreutils }/bin/echo ${ _environment-variable "PAYLOAD" } | ${ pkgs.jq }/bin/jq --raw-output ".origin" ) &&
                                                                                                        export TEMPORARY=$( ${ pkgs.coreutils }/bin/echo ${ _environment-variable "PAYLOAD" } | ${ pkgs.jq }/bin/jq --raw-output ".temporary" ) &&
                                                                                                        export USER=$( ${ pkgs.coreutils }/bin/echo ${ _environment-variable "PAYLOAD" } | ${ pkgs.jq }/bin/jq --raw-output ".user" ) &&
                                                                                                        export OUTPUT=$( ${ pkgs.coreutils }/bin/mktemp --directory ) &&
                                                                                                        ${ user-environment }/bin/user-environment &&
                                                                                                        ${ pkgs.redis }/bin/redis-cli PUBLISH process ${ _environment-variable "OUTPUT" }
                                                                                                fi
                                                                                            done
                                                                                        '' ;
                                                                       User = config.personal.user.name ;
                                                                   } ;
                                                                requires = [ "redis.service" ] ;
                                                                wantedBy = [ "multi-user.target" ] ;
                                                            } ;
                                                        nix-flake =
                                                            {
                                                                after = [ "network.target" "redis.service" ] ;
                                                                serviceConfig =
                                                                    {
                                                                        ExecStart =
                                                                            pkgs.writeShellScript
                                                                                "nix-flake"
                                                                                ''
                                                                                    ${ pkgs.redis }/bin/redis-cli SUBSCRIBE nix-flake | while read -r LINE
                                                                                    do
                                                                                        if [ "${ _environment-variable "LINE" }" == "message" ]
                                                                                        then
                                                                                            read -r CHANNEL &&
                                                                                                read -r PAYLOAD &&
                                                                                                export PAYLOAD &&
                                                                                                cd ${ _environment-variable "PAYLOAD" }/tree &&
                                                                                                if ! ${ pkgs.nix }/bin/nix flake check > ${ _environment-variable "PAYLOAD" }/nix-flake.standard-output 2> ${ _environment-variable "PAYLOAD" }/nix-flake.standard-error
                                                                                                then
                                                                                                    ${ pkgs.coreutils }/bin/echo ${ _environment-variable "?" } > ${ _environment-variable "PAYLOAD" }/FAILURE
                                                                                                fi &&
                                                                                                ${ pkgs.redis }/bin/redis-cli PUBLISH process ${ _environment-variable "PAYLOAD" }
                                                                                        fi
                                                                                    done
                                                                                '' ;
                                                                        User = config.personal.user.name ;
                                                                    } ;
                                                                requires = [ "redis.service" ] ;
                                                                wantedBy = [ "multi-user.target" ] ;
                                                            } ;
                                                        nixos-rebuild =
                                                            {
                                                                after = [ "network.target" "redis.service" ] ;
                                                                serviceConfig =
                                                                    {
                                                                        Environment = "PATH=/run/wrappers/bin:/usr/bin:/bin" ;
                                                                        ExecStart =
                                                                            pkgs.writeShellScript
                                                                                "nixos-rebuild"
                                                                                ''
                                                                                    ${ pkgs.redis }/bin/redis-cli SUBSCRIBE nixos-rebuild | while read -r LINE
                                                                                    do
                                                                                        if [ ${ _environment-variable "LINE" } == "message" ]
                                                                                        then
                                                                                            read -r CHANNEL &&
                                                                                                read -r PAYLOAD &&
                                                                                                REPOSITORY=${ _environment-variable "PAYLOAD" } &&
                                                                                                cd ${ _environment-variable "REPOSITORY" } &&
                                                                                                source ./env &&
                                                                                                cd tree &&
                                                                                                if [ ${ _environment-variable "BRANCH" } == "main" ]
                                                                                                then
                                                                                                    if ! /run/wrappers/bin/sudo ${ pkgs.nixos-rebuild }/bin/nixos-rebuild switch --flake .#myhost > ${ _environment-variable "REPOSITORY" }/nixos-rebuild.standard-output 2> ${ _environment-variable "REPOSITORY" }/nixos-rebuild.standard-error
                                                                                                    then
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ _environment-variable "?" } > ${ _environment-variable "REPOSITORY" }/FAILURE
                                                                                                    fi
                                                                                                elif [ ${ _environment-variable "BRANCH" } == "development" ]
                                                                                                then
                                                                                                    if ! /run/wrappers/bin/sudo ${ pkgs.nixos-rebuild }/bin/nixos-rebuild test --flake .#myhost > ${ _environment-variable "REPOSITORY" }/nixos-rebuild.standard-output 2> ${ _environment-variable "REPOSITORY" }/nixos-rebuild.standard-error
                                                                                                    then
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ _environment-variable "?" } > ${ _environment-variable "REPOSITORY" }/FAILURE
                                                                                                    fi
                                                                                                else
                                                                                                    if ! ${ pkgs.nixos-rebuild }/bin/nixos-rebuild build-vm --flake .#myhost > ${ _environment-variable "REPOSITORY" }/nixos-rebuild.standard-output 2> ${ _environment-variable "REPOSITORY" }/nixos-rebuild.standard-error
                                                                                                    then
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ _environment-variable "?" } > ${ _environment-variable "REPOSITORY" }/FAILURE
                                                                                                    fi
                                                                                                fi &&
                                                                                                ${ pkgs.redis }/bin/redis-cli PUBLISH process ${ _environment-variable "REPOSITORY" }
                                                                                        fi
                                                                                    done
                                                                                '' ;
                                                                        User = config.personal.user.name ;
                                                                    } ;
                                                                requires = [ "redis.service" ] ;
                                                                wantedBy = [ "multi-user.target" ] ;
                                                            } ;
                                                        process =
                                                            {
                                                                after = [ "network.target" "redis.service" ] ;
                                                                serviceConfig =
                                                                    {
                                                                        ExecStart =
                                                                            pkgs.writeShellScript
                                                                                "process"
                                                                                ''
                                                                                    ${ pkgs.redis }/bin/redis-cli SUBSCRIBE process | while read -r LINE
                                                                                    do
                                                                                        if [ "${ _environment-variable "LINE" }" == "message" ]
                                                                                        then
                                                                                            read -r CHANNEL &&
                                                                                                read -r PAYLOAD &&
                                                                                                export PAYLOAD &&
                                                                                                if [ -e ${ _environment-variable "PAYLOAD" }/FAILURE ]
                                                                                                then
                                                                                                    ${ pkgs.redis }/bin/redis-cli PUBLISH failure ${ _environment-variable "PAYLOAD" }
                                                                                                else
                                                                                                    FILE=$( ${ pkgs.findutils }/bin/find ${ _environment-variable "PAYLOAD" }/signals -mindepth 1 -type f | ${ pkgs.coreutils }/bin/sort --numeric | ${ pkgs.coreutils }/bin/head --lines 1 ) &&
                                                                                                        if [ -z "${ _environment-variable "FILE" }" ]
                                                                                                        then
                                                                                                            ${ pkgs.redis }/bin/redis-cli PUBLISH success ${ _environment-variable "PAYLOAD" }
                                                                                                        else
                                                                                                            ${ pkgs.redis }/bin/redis-cli PUBLISH $( ${ pkgs.coreutils }/bin/cat ${ _environment-variable "FILE" } ) ${ _environment-variable "PAYLOAD" } &&
                                                                                                                ${ pkgs.coreutils }/bin/rm ${ _environment-variable "FILE" }
                                                                                                        fi
                                                                                                fi
                                                                                        fi
                                                                                    done
                                                                                '' ;
                                                                        User = config.personal.user.name ;
                                                                    } ;
                                                                requires = [ "redis.service" ] ;
                                                                wantedBy = [ "multi-user.target" ] ;
                                                            } ;
                                                        push =
                                                            {
                                                                after = [ "network.target" "redis.service" ] ;
                                                                serviceConfig =
                                                                    {
                                                                        ExecStart =
                                                                            pkgs.writeShellScript
                                                                                "push"
                                                                                ''
                                                                                    ${ pkgs.redis }/bin/redis-cli SUBSCRIBE push | while read -r LINE
                                                                                    do
                                                                                        if [ "${ _environment-variable "LINE" }" == "message" ]
                                                                                        then
                                                                                            read -r CHANNEL &&
                                                                                                read -r PAYLOAD &&
                                                                                                export PAYLOAD &&
                                                                                                export GIT_DIR=${ _environment-variable "PAYLOAD" }/git &&
                                                                                                export GIT_WORK_TREE=${ _environment-variable "PAYLOAD" }/tree &&
                                                                                                cd ${ _environment-variable "GIT_WORK_TREE" } &&
                                                                                                DIRECTORY=${ _environment-variable "PAYLOAD" } &&
                                                                                                source ${ _environment-variable "PAYLOAD" }/env &&
                                                                                                ${ pkgs.coreutils }/bin/echo ${ pkgs.git }/bin/git push origin HEAD:refs/heads/${ _environment-variable "BRANCH" } &&
                                                                                                if ${ pkgs.git }/bin/git push origin HEAD:refs/heads/${ _environment-variable "BRANCH" }
                                                                                                then
                                                                                                    ${ pkgs.redis }/bin/redis-cli PUBLISH process ${ _environment-variable "DIRECTORY" }
                                                                                                else
                                                                                                    ${ pkgs.coreutils }/bin/sleep 1m &&
                                                                                                        ${ pkgs.redis }/bin/redis-cli PUBLISH push ${ _environment-variable "DIRECTORY" }
                                                                                                fi
                                                                                        fi
                                                                                    done
                                                                                '' ;
                                                                        User = config.personal.user.name ;
                                                                    } ;
                                                                requires = [ "redis.service" ] ;
                                                                wantedBy = [ "multi-user.target" ] ;
                                                            } ;
                                                   } ;
                                                time.timeZone = "America/New_York" ;
                                                users.users.user =
                                                    {
                                                        description = config.personal.user.description ;
                                                        extraGroups = [ "wheel" ] ;
                                                        isNormalUser = true ;
                                                        name = config.personal.user.name ;
                                                        packages =
                                                            let
                                                                derivation =
                                                                    pkgs.stdenv.mkDerivation
                                                                        {
                                                                            installPhase =
                                                                                let
                                                                                    dot-gnupg =
                                                                                        name : value :
                                                                                            let
                                                                                                script =
                                                                                                    ''
                                                                                                        export GNUPGHOME=/tmp/$( ${ pkgs.coreutils }/bin/echo DOT_GNUPG ${ name } ${ _environment-variable "TIMESTAMP" } | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -128 ) &&
                                                                                                            if [ -d ${ _environment-variable "GNUPGHOME" } ]
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/mkdir ${ _environment-variable "GNUPGHOME" } &&
                                                                                                                    ${ pkgs.coreutils }/bin/chmod 0700 ${ _environment-variable "GNUPGHOME" } &&
                                                                                                                    ${ pkgs.gnupg }/bin/gpg --batch --homedir ${ _environment-variable "GNUPGHOME" } --import ${ value.gpg-secret-keys } &&
                                                                                                                    ${ pkgs.gnupg }/bin/gpg --homedir ${ _environment-variable "GNUPGHOME" } --import ${ value.gpg-ownertrust } &&
                                                                                                                    ${ pkgs.gnupg }/bin/gpg --homeidr ${ _environment-variable "GNUPHOME" } --update-trustdb &&
                                                                                                                    ${ pkgs.gnupg }/bin/gpg2 --homedir ${ _environment-variable "GNUPGHOME" } --import ${ value.gpg2-secret-keys } &&
                                                                                                                    ${ pkgs.gnupg }/bin/gpg2 --homedir ${ _environment-variable "GNUPGHOME" } --import ${ value.gpg2-ownertrust } &&
                                                                                                                    ${ pkgs.gnupg }/bin/gpg2 --homedir ${ _environment-variable "GNUPGHOME" } --update-trustdb
                                                                                                            fi &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ _environment-variable "GNUPHOME" }
                                                                                                    '' ;
                                                                                                in "makeWrapper ${ pkgs.writeShellScript "script" script } $out/scripts/dot-gnupg/${ name } --set OUT $out" ;
                                                                                    dot-ssh =
                                                                                        name : value :
                                                                                            let
                                                                                                script =
                                                                                                    pkgs.writeShellScript
                                                                                                        "dot-ssh"
                                                                                                        ''
                                                                                                            DOT_SSH=/tmp/$( ${ pkgs.coreutils }/bin/echo DOT_SSH ${ name } ${ _environment-variable "TIMESTAMP" } | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -128 ) &&
                                                                                                                if [ ! -d ${ _environment-variable "DOT_SSH" } ]
                                                                                                                then
                                                                                                                    ${ pkgs.coreutils }/bin/mkdir ${ _environment-variable "DOT_SSH" } &&
                                                                                                                        ${ pkgs.coreutils }/bin/cat ${ value.identity } > ${ _environment-variable "DOT_SSH" }/identity &&
                                                                                                                        ${ pkgs.coreutils }/bin/cat ${ value.known-hosts } > ${ _environment-variable "DOT_SSH" }/known-hosts &&
                                                                                                                        ( ${ pkgs.coreutils }/bin/cat > ${ _environment-variable "DOT_SSH" }/config <<EOF
                                                                                                            ${ if builtins.typeOf value.host == "null" then "#" else "HostName ${ value.host-name }" }
                                                                                                            ${ if builtins.typeOf value.host == "null" then "#" else "Host ${ value.host }" }
                                                                                                            User ${ value.user }
                                                                                                            IdentityFile ${ _environment-variable "DOT_SSH" }/identity
                                                                                                            UserKnownHostsFile ${ _environment-variable "DOT_SSH" }/known-hosts
                                                                                                            Port ${ builtins.toString value.port }
                                                                                                            StrictHostKeyChecking true
                                                                                                            EOF
                                                                                                                        ) &&
                                                                                                                        ${ pkgs.coreutils }/bin/chmod 0400 ${ _environment-variable "DOT_SSH" }/config ${ _environment-variable "DOT_SSH" }/identity ${ _environment-variable "DOT_SSH" }/known-hosts
                                                                                                                fi &&
                                                                                                                ${ pkgs.coreutils }/bin/echo ${ _environment-variable "DOT_SSH" }
                                                                                                        '' ;
                                                                                                in "makeWrapper ${ pkgs.writeShellScript "script" script } $out/scripts/dot-ssh/${ name } --set OUT $out" ;
                                                                                    portfolio =
                                                                                        let
                                                                                            script =
                                                                                                ''
                                                                                                    PORTFOLIO=/tmp/$( ${ pkgs.coreutils }/bin/echo PORTFOLIO ${ _environment-variable "TIMESTAMP" } | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -128 ) &&
                                                                                                    if [ ! -d ${ _environment-variable "PORTFOLIO" } ]
                                                                                                    then
                                                                                                        ${ pkgs.coreutils }/bin/mkdir ${ _environment-variable "PORTFOLIO" } &&
                                                                                                            ${ pkgs.coreutils }/bin/echo PORTFOLIO=${ _environment-variable "PORTFOLIO" } OUT=${ _environment-variable "OUT" } >&2 &&
                                                                                                            ${ if builtins.length ( builtins.attrNames config.personal.user.repository ) > 0 then builtins.concatStringsSep " &&\n\t" ( builtins.attrValues ( builtins.mapAttrs ( name : value : "${ pkgs.coreutils }/bin/ln --symbolic $( ${ _environment-variable "OUT" }/scripts/repository/${ name } ) ${ _environment-variable "PORTFOLIO" }/${ name }" ) config.personal.user.repository ) ) else "#" }
                                                                                                    fi &&
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ _environment-variable "PORTFOLIO" }
                                                                                                '' ;
                                                                                            in "makeWrapper ${ pkgs.writeShellScript "script" script } $out/scripts/portfolio --set OUT $out" ;
                                                                                    repository =
                                                                                        name : value :
                                                                                            let
                                                                                                script =
                                                                                                    ''
                                                                                                        REPOSITORY=/tmp/$( ${ pkgs.coreutils }/bin/echo REPOSITORY ${ name } ${ _environment-variable "TIMESTAMP" } | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -128 ) &&
                                                                                                            if [ ! -d ${ _environment-variable "REPOSITORY" } ]
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/mkdir ${ _environment-variable "REPOSITORY" } &&
                                                                                                                    cd ${ _environment-variable "REPOSITORY" } &&
                                                                                                                    ${ pkgs.git }/bin/git init &&
                                                                                                                    ${ if builtins.length ( builtins.attrNames value.remotes ) > 0 then builtins.concatStringsSep " &&\n\t" ( builtins.attrValues ( builtins.mapAttrs ( name : value : "${ pkgs.git }/bin/git remote add ${ name } ${ value }" ) value.remotes ) ) else "#" } &&
                                                                                                                    ${ if builtins.length ( builtins.attrNames value.config ) > 0 then builtins.concatStringsSep " &&\n\t" ( builtins.attrValues ( builtins.mapAttrs ( name : value : "${ pkgs.git }/bin/git config ${ name } \"${ value }\"" ) value.config ) ) else "#" } &&
                                                                                                                    ${ if builtins.length ( builtins.attrNames value.hooks ) > 0 then builtins.concatStringsSep " &&\n\t" ( builtins.attrValues ( builtins.mapAttrs ( name : value : "${ pkgs.coreutils }/bin/ln --symbolic ${ value } .git/hooks/${ name }" ) value.hooks ) ) else "#" } &&
                                                                                                                    ${ pkgs.writeShellScript "initial" value.initial }
                                                                                                            fi &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ _environment-variable "REPOSITORY" }
                                                                                                    '' ;
                                                                                                in "makeWrapper ${ pkgs.writeShellScript "script" script } $out/scripts/repository/${ name } --set OUT $out" ;
                                                                                    studio =
                                                                                        let
                                                                                            script =
                                                                                                ''
                                                                                                    export TIMESTAMP=$( ${ pkgs.coreutils }/bin/date +${ config.personal.user.time-mask } ) &&
                                                                                                        ${ pkgs.jetbrains.idea-community }/bin/idea-community $( ${ _environment-variable "OUT" }/scripts/portfolio )
                                                                                                '' ;
                                                                                            in "makeWrapper ${ pkgs.writeShellScript "script" script } $out/bin/studio --set OUT $out" ;
                                                                                    in
                                                                                        ''
                                                                                            ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                                                ${ pkgs.coreutils }/bin/mkdir $out/bin &&
                                                                                                ${ studio } &&
                                                                                                ${ pkgs.coreutils }/bin/mkdir $out/scripts &&
                                                                                                ${ pkgs.coreutils }/bin/mkdir $out/scripts/dot-gnupg &&
                                                                                                ${ if builtins.length ( builtins.attrNames config.personal.user.dot-gnupg ) > 0 then builtins.concatStringsSep " &&\n\t" ( builtins.attrValues ( builtins.mapAttrs dot-gnupg config.personal.user.dot-gnupg ) ) else "#" } &&
                                                                                                ${ pkgs.coreutils }/bin/mkdir $out/scripts/dot-ssh &&
                                                                                                ${ if builtins.length ( builtins.attrNames config.personal.user.dot-ssh ) > 0 then builtins.concatStringsSep " &&\n\t" ( builtins.attrValues ( builtins.mapAttrs dot-ssh config.personal.user.dot-ssh ) ) else "#" } &&
                                                                                                ${ portfolio } &&
                                                                                                ${ pkgs.coreutils }/bin/mkdir $out/scripts/repository &&
                                                                                                ${ if builtins.length ( builtins.attrNames config.personal.user.repository ) > 0 then builtins.concatStringsSep " &&\n\t" ( builtins.attrValues ( builtins.mapAttrs repository config.personal.user.repository ) ) else "#" } &&
                                                                                                ${ pkgs.coreutils }/bin/true
                                                                                        '' ;
                                                                             name = "derivation" ;
                                                                             nativeBuildInputs = [ pkgs.makeWrapper ] ;
                                                                            src = ./. ;
                                                                        } ;
                                                                in
                                                                    builtins.concatLists
                                                                        [
                                                                            [
                                                                                derivation
                                                                            ]
                                                                        ] ;
                                                        password = config.personal.user.password ;
                                                    } ;
                                            } ;
                                        options =
                                            {
                                                personal =
                                                    {
                                                        user =
                                                            {
                                                                description = lib.mkOption { type = lib.types.str ; } ;
                                                                dot-gnupg =
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
                                                                                                        gpg-ownertrust = lib.mkOption { type = lib.types.path ; } ;
                                                                                                        gpg2-ownertrust = lib.mkOption { type = lib.types.path ; } ;
                                                                                                        gpg-secret-keys = lib.mkOption { type = lib.types.path ; } ;
                                                                                                        gpg2-secret-keys = lib.mkOption { type = lib.types.path ; } ;
                                                                                                    } ;
                                                                                            } ;
                                                                                    in lib.types.attrsOf config ;
                                                                        } ;
                                                                dot-ssh =
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
                                                                                                        host = lib.mkOption { default = null ; type = lib.types.nullOr lib.types.str ; } ;
                                                                                                        host-name = lib.mkOption { default = null ; type = lib.types.nullOr lib.types.str ; } ;
                                                                                                        identity = lib.mkOption { type = lib.types.path ; } ;
                                                                                                        known-hosts = lib.mkOption { type = lib.types.path ; } ;
                                                                                                        port = lib.mkOption { default = 22 ; type = lib.types.int ; } ;
                                                                                                        user = lib.mkOption { default = "git" ; type = lib.types.str ; } ;
                                                                                                    } ;
                                                                                            } ;
                                                                                    in lib.types.attrsOf config ;
                                                                        } ;
                                                                name = lib.mkOption { type = lib.types.str ; } ;
                                                                pass =
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
                                                                                                        branch = lib.mkOption { type = lib.types.str ; } ;
                                                                                                        host = lib.mkOption { type = lib.types.str ; } ;
                                                                                                        known-hosts = lib.mkOption { type = lib.types.path ; } ;
                                                                                                        identity-file = lib.mkOption { type = lib.types.path ; } ;
                                                                                                        origin = lib.mkOption { type = lib.types.str ; } ;
                                                                                                        gpg-secret-keys = lib.mkOption { type = lib.types.path ; } ;
                                                                                                        gpg2-secret-keys = lib.mkOption { type = lib.types.path ; } ;
                                                                                                        gpg-ownertrust = lib.mkOption { type = lib.types.path ; } ;
                                                                                                        gpg2-ownertrust = lib.mkOption { type = lib.types.path ; } ;
                                                                                                        extensions = lib.mkOption { type = lib.types.bool ; } ;
                                                                                                        port = lib.mkOption { default = 22 ; type = lib.types.int ; } ;
                                                                                                        user = lib.mkOption { default = "git" ; type = lib.types.str ; } ;
                                                                                                        user-name = lib.mkOption { type = lib.types.str ; } ;
                                                                                                        user-email = lib.mkOption { type = lib.types.str ; } ;
                                                                                                    } ;
                                                                                            } ;
                                                                                    in lib.types.attrsOf config ;
                                                                        } ;
                                                                password = lib.mkOption { type = lib.types.str ; } ;
                                                                repository =
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
                                                                                                        config = lib.mkOption { default = { } ; type = lib.types.attrsOf lib.types.str ; } ;
                                                                                                        hooks = lib.mkOption { default = { } ; type = lib.types.attrsOf lib.types.path ; } ;
                                                                                                        initial = lib.mkOption { default = null ; type = lib.types.path ; } ;
                                                                                                        remotes = lib.mkOption { default = { } ; type = lib.types.attrsOf lib.types.str ; } ;
                                                                                                     } ;
                                                                                            } ;
                                                                                    in lib.types.attrsOf config ;
                                                                        } ;
                                                                time-mask = lib.mkOption { default = "%Y-%m-%d-%H-%M" ; type = lib.types.str ; } ;
                                                            } ;
                                                    } ;
                                                personal.wifi =
                                                    lib.mkOption
                                                        {
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
                    pkgs = import nixpkgs { inherit system; } ;
                    in
                        {
                            lib = lib ;
                        } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
