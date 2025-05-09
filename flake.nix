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
                                                        redis.enable = true ;
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
                                                                mapper =
                                                                    name : value :
                                                                        let
                                                                            user-environment =
                                                                                pkgs.buildFHSUserEnv
                                                                                    {
                                                                                        extraBwrapArgs =
                                                                                            [
                                                                                                "--bind ${ _environment-variable "TEMPORARY" } /work"
                                                                                            ] ;
                                                                                        name = "user-environment" ;
                                                                                        profile =
                                                                                            builtins.concatStringsSep
                                                                                                " &&\n\t"
                                                                                                [
                                                                                                    "export GIT_DIR=/work/${ value.user-name }/git"
                                                                                                    "export GIT_WORK_TREE=/work/${ value.user-name }/tree"
                                                                                                ] ;
                                                                                        runScript =
                                                                                            builtins.toString
                                                                                                (
                                                                                                    let
                                                                                                        post-commit =
                                                                                                            pkgs.writeShellScript
                                                                                                                "post-commit"
                                                                                                                ''
                                                                                                                    BRANCH="$( ${ pkgs.git }/bin/git rev-parse --abbrev-ref HEAD )" &&
                                                                                                                        if [ -z "${ _environment-variable "BRANCH" }" ]
                                                                                                                        then
                                                                                                                            ${ pkgs.coreutils }/bin/echo We can not commit to a detached head. >&2 &&
                                                                                                                                exit 64
                                                                                                                        fi &&
                                                                                                                        ${ pkgs.redis }/bin/redis-cli PUBLISH commit "$( ${ pkgs.jq }/bin/jq --null-input --arg BRANCH ${ _environment-variable "BRANCH" } --arg COMMIT_HASH "$( ${ pkgs.git }/bin/git rev-parse HEAD )" --arg ORIGIN "${ value.origin }"  --arg TEMPORARY "${ _environment-variable "TEMPORARY" }" --arg USER "${ value.user-name }" --compact-output '{ branch : $BRANCH , commit_hash : $COMMIT_HASH , origin : $ORIGIN , temporary : $TEMPORARY , user : $USER }' )"
                                                                                                                '' ;
                                                                                                        in
                                                                                                            pkgs.writeShellScript
                                                                                                                "script"
                                                                                                                ''
                                                                                                                    ${ pkgs.coreutils }/bin/mkdir /work/${ value.user-name } &&
                                                                                                                        ${ pkgs.coreutils }/bin/mkdir /work/${ value.user-name }/.ssh &&
                                                                                                                        ${ pkgs.coreutils }/bin/cat ${ value.identity-file } > /work/${ value.user-name }/.ssh/id-rsa &&
                                                                                                                        ${ pkgs.coreutils }/bin/cat ${ value.known-hosts } > /work/${ value.user-name }/.ssh/known-hosts &&
                                                                                                                        ( ${ pkgs.coreutils }/bin/cat > /work/${ value.user-name }/.ssh/config <<EOF
                                                                                                                            Host ${ value.host }
                                                                                                                            Port ${ builtins.toString value.port }
                                                                                                                            IdentityFile ${ _environment-variable "TEMPORARY" }/${ value.user-name }/.ssh/id-rsa
                                                                                                                            User ${ value.user }
                                                                                                                            UserKnownHostsFile ${ _environment-variable "TEMPORARY" }/${ value.user-name }/.ssh/known-hosts &&
                                                                                                                            StrictHostKeyChecking true
                                                                                                                    EOF
                                                                                                                        ) &&
                                                                                                                        ${ pkgs.coreutils }/bin/chmod 0400 /work/${ value.user-name }/.ssh/config /work/${ value.user-name }/.ssh/id-rsa /work/${ value.user-name }/.ssh/known-hosts &&
                                                                                                                        ${ pkgs.coreutils }/bin/mkdir /work/${ value.user-name }/signals &&
                                                                                                                        ${ if value.emit-nix-flake then "${ pkgs.coreutils }/bin/echo -n nix-flake > /work/${ value.user-name }/signals/5000" else "#" } &&
                                                                                                                        ${ if value.emit-nixos-rebuild then "${ pkgs.coreutils }/bin/echo -n nixos-rebuild > /work/${ value.user-name }/signals/6000" else "#" } &&
                                                                                                                        ${ if value.emit-push then "${ pkgs.coreutils }/bin/echo -n push > /work/${ value.user-name }/signals/7000" else "#" } &&
                                                                                                                        ${ pkgs.coreutils }/bin/mkdir /work/${ value.user-name }/.idea &&
                                                                                                                        ( ${ pkgs.coreutils }/bin/cat > /work/${ value.user-name }/.idea/misc.xml <<EOF
                                                                                                                    <?xml version="1.0" encoding="UTF-8"?>
                                                                                                                    <project version="4">
                                                                                                                      <component name="ProjectRootManager" version="2" />
                                                                                                                    </project>
                                                                                                                    EOF
                                                                                                                        ) &&
                                                                                                                        ${ pkgs.coreutils }/bin/mkdir /work/${ value.user-name }/git &&
                                                                                                                        ${ pkgs.coreutils }/bin/mkdir /work/${ value.user-name }/tree &&
                                                                                                                        cd /work/${ value.user-name }/tree &&
                                                                                                                        ${ pkgs.git }/bin/git init &&
                                                                                                                        ${ pkgs.git }/bin/git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F ${ _environment-variable "TEMPORARY" }/${ value.user-name }/.ssh/config" &&
                                                                                                                        ${ pkgs.git }/bin/git config user.email ${ value.user-email } &&
                                                                                                                        ${ pkgs.git }/bin/git config user.name ${ value.user-name } &&
                                                                                                                        ${ pkgs.git }/bin/git config alias.check !${ pkgs.writeShellScript "check" "unset LD_LIBRARY_PATH && ${ pkgs.nix }/bin/nix-collect-garbage && ${ pkgs.nix }/bin/nix flake check" } &&
                                                                                                                        ${ pkgs.git }/bin/git config alias.subscribe !${ pkgs.writeShellScript "subscribe" ''${ pkgs.redis }/bin/redis-cli SUBSCRIBE commit process nix-flake nixos-rebuild push success failure | while read -r LINE ; do read CHANNEL && read PAYLOAD && ${ pkgs.coreutils }/bin/echo -e "\nLINE=${ _environment-variable "LINE" }\nCHANNEL=${ _environment-variable "CHANNEL" }\nPAYLOAD=${ _environment-variable "PAYLOAD" }"; done'' } &&
                                                                                                                        ${ pkgs.git }/bin/git config alias.ping !${ pkgs.writeShellScript "ping" ''${ pkgs.git }/bin/git commit --allow-empty --allow-empty-message ${ _environment-variable "@" }'' } &&
                                                                                                                        ${ pkgs.git }/bin/git remote add origin ${ value.origin } &&
                                                                                                                        ${ pkgs.coreutils }/bin/ln --symbolic ${ post-commit } /work/${ value.user-name }/git/hooks/post-commit &&
                                                                                                                        ${ pkgs.git }/bin/git fetch &&
                                                                                                                        ${ pkgs.git }/bin/git checkout origin/main &&
                                                                                                                        ${ pkgs.git }/bin/git checkout -b scratch/$( ${ pkgs.libuuid }/bin/uuidgen ) &&
                                                                                                                        ${ pkgs.jetbrains.idea-community }/bin/idea-community /work/${ value.user-name }
                                                                                                                ''
                                                                                                ) ;
                                                                                    } ;
                                                                            in
                                                                                pkgs.writeShellScriptBin
                                                                                    name
                                                                                    ''
                                                                                        export TEMPORARY=$( ${ pkgs.coreutils }/bin/mktemp --directory ) &&
                                                                                            ${ user-environment }/bin/user-environment
                                                                                     '';
                                                                in builtins.attrValues ( builtins.mapAttrs mapper config.personal.workspaces ) ;
                                                        password = config.personal.user.password ;
                                                    } ;
                                            } ;
                                        options =
                                            {
                                                personal.user.description = lib.mkOption { type = lib.types.str ; } ;
                                                personal.user.name = lib.mkOption { type = lib.types.str ; } ;
                                                personal.user.password = lib.mkOption { type = lib.types.str ; } ;
                                                personal.user.token = lib.mkOption { type = lib.types.str ; } ;
                                                personal.workspaces =
                                                    lib.mkOption
                                                        {
                                                            default = [ ] ;
                                                            type =
                                                                let
                                                                    config =
                                                                        lib.types.submodule
                                                                            {
                                                                                options =
                                                                                    {
                                                                                        emit-nix-flake = lib.mkOption { default = false ; type = lib.types.bool ; } ;
                                                                                        emit-nixos-rebuild = lib.mkOption { default = false ; type = lib.types.bool ; } ;
                                                                                        emit-push = lib.mkOption { default = false ; type = lib.types.bool ; } ;
                                                                                        host = lib.mkOption { default = "github.com" ; type = lib.types.str ; } ;
                                                                                        identity-file = lib.mkOption { type = lib.types.path ; } ;
                                                                                        known-hosts = lib.mkOption { type = lib.types.path ; } ;
                                                                                        origin = lib.mkOption { type = lib.types.str ; } ;
                                                                                        port = lib.mkOption { default = 22 ; type = lib.types.int ; } ;
                                                                                        user = lib.mkOption { default = "git" ; type = lib.types.str ; } ;
                                                                                        user-email = lib.mkOption { type = lib.types.str ; } ;
                                                                                        user-name = lib.mkOption { type = lib.types.str ; } ;
                                                                                    } ;
                                                                            } ;
                                                                    in lib.types.attrsOf config ;
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
