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
                                                        cron =
                                                            {
                                                                enable = true ;
                                                                systemCronJobs =
                                                                    [
                                                                        (
                                                                            let
                                                                                script =

                                                                                in "@reboot root ${ script } > /tmp/cron.out 2> /tmp/cron.err"
                                                                        )
                                                                    ] ;
                                                            } ;
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
                                                systemd.services.git-commit-subscriber =
                                                    {
                                                        after = [ "network.target" ] ;
                                                        serviceConfig =
                                                            {
                                                                ExecStart =
                                                                    let
                                                                        iteration =
                                                                            pkgs.buildFHSUserEnv
                                                                                {
                                                                                    extraBwrapArgs =
                                                                                        [
                                                                                            "--ro-bind ${ _environment-variable "TEMPORARY" } /work"
                                                                                            "--bind ${ _environment-variable "OUTPUT" } /output"
                                                                                        ] ;
                                                                                    name  = "iteration" ;
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
                                                                                                    ${ pkgs.coreutils }/bin/cp --recursive /work/${ _environment-variable "USER" }/bin /output/bin &&
                                                                                                    ${ pkgs.coreutils }/bin/mkdir ${ _environment-variable "GIT_DIR" } &&
                                                                                                    ${ pkgs.coreutils }/bin/mkdir ${ _environment-variable "GIT_WORK_TREE" } &&
                                                                                                    ${ pkgs.git }/bin/git init &&
                                                                                                    ${ pkgs.git }/bin/git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F /output/.ssh/config" &&
                                                                                                    ${ pkgs.git }/bin/git remote add local /work/${ _environment-variable "USER" }/git &&
                                                                                                    ${ pkgs.git }/bin/git fetch local ${ _environment-variable "COMMIT_HASH" } &&
                                                                                                    ${ pkgs.git }/bin/git checkout --detach FETCH_HEAD
                                                                                            '' ;
                                                                                } ;
                                                                        in
                                                                            pkgs.writeShellScript
                                                                                "ExecStart"
                                                                                ''
                                                                                    ${ pkgs.redis }/bin/redis-cli SUBSCRIBE git-commit-received | while read -r LINE
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
                                                                                                ${ iteration }/bin/iteration &&
                                                                                                cd ${ _environment-variable "OUTPUT" }/tree &&
                                                                                                # if [ -L ${ _environment-variable "OUTPUT" }/bin/process ]
                                                                                                # then
                                                                                                #     ${ pkgs.coreutils }/bin/cat ${ _environment-variable "OUTPUT" }/bin/process &&
                                                                                                #    if ${ _environment-variable "OUTPUT" }/bin/process > ${ _environment-variable "OUTPUT" }/standard-output 2> ${ _environment-variable "OUTPUT" }/standard-error
                                                                                                #    then
                                                                                                #        ${ pkgs.coreutils }/bin/echo ${ _environment-variable "?" } > ${ _environment-variable "OUTPUT" }/status
                                                                                                #    else
                                                                                                #         ${ pkgs.coreutils }/bin/echo ${ _environment-variable "?" } > ${ _environment-variable "OUTPUT" }/status
                                                                                                #     fi
                                                                                                # fi &&
                                                                                                ${ pkgs.redis }/bin/redis-cli PUBLISH git-commit-ready "${ _environment-variable "OUTPUT" }"
                                                                                        fi
                                                                                    done
                                                                                '' ;
                                                               User = config.personal.user.name ;
                                                           } ;
                                                       wantedBy = [ "multi-user.target" ] ;
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
                                                                    value :
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
                                                                                                                        if [ -z ${ _environment-variable "BRANCH" } ]
                                                                                                                        then
                                                                                                                            BRANCH=scratch/$( ${ pkgs.libuuid }/bin/uuidgen | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -64 )
                                                                                                                        fi &&
                                                                                                                        ${ pkgs.redis }/bin/redis-cli PUBLISH git-commit-received "$( ${ pkgs.jq }/bin/jq --null-input --arg BRANCH ${ _environment-variable "BRANCH" } --arg COMMIT_HASH "$( ${ pkgs.git }/bin/git rev-parse --abbrev-ref HEAD )" --arg ORIGIN "${ value.origin }"  --arg TEMPORARY "${ _environment-variable "TEMPORARY" }" --arg USER "${ value.user-name }" --compact-output '{ branch : $BRANCH , commit_hash : $COMMIT_HASH , origin : $ORIGIN , temporary : $TEMPORARY , user : $USER }' )"
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
                                                                                                                            IdentityFile ${ _environment-variable "TEMPORARY" }/${ value.user-name }/.ssh/id-rsa
                                                                                                                            User ${ value.user }
                                                                                                                            UserKnownHostsFile ${ _environment-variable "TEMPORARY" }/${ value.user-name }/.ssh/known-hosts &&
                                                                                                                            StrictHostKeyChecking true
                                                                                                                    EOF
                                                                                                                        ) &&
                                                                                                                        ${ pkgs.coreutils }/bin/chmod 0400 /work/${ value.user-name }/.ssh/config /work/${ value.user-name }/.ssh/id-rsa /work/${ value.user-name }/.ssh/known-hosts &&
                                                                                                                        ${ pkgs.coreutils }/bin/mkdir /work/${ value.user-name }/bin &&
                                                                                                                        ${ if builtins.typeOf value.process == "string" then "${ pkgs.coreutils }/bin/ln --symbolic ${ pkgs.writeShellScript "process" value.process } /work/${ value.user-name }/bin/process" else "# NO PROCESS" } &&
                                                                                                                        ${ pkgs.coreutils }/bin/mkdir /work/${ value.user-name }/git &&
                                                                                                                        ${ pkgs.coreutils }/bin/mkdir /work/${ value.user-name }/tree &&
                                                                                                                        cd /work/${ value.user-name }/tree &&
                                                                                                                        ${ pkgs.git }/bin/git init &&
                                                                                                                        ${ pkgs.git }/bin/git config core.sshCommand "${ pkgs.openssh }/bin/ssh -p ${ builtins.toString value.port } -F ${ _environment-variable "TEMPORARY" }/${ value.user-name }/.ssh/config" &&
                                                                                                                        ${ pkgs.git }/bin/git config user.email ${ value.user-email } &&
                                                                                                                        ${ pkgs.git }/bin/git config user.name ${ value.user-name } &&
                                                                                                                        ${ pkgs.git }/bin/git config alias.check !${ pkgs.writeShellScript "check" "unset LD_LIBRARY_PATH && ${ pkgs.nix }/bin/nix-collect-garbage && ${ pkgs.nix }/bin/nix flake check" } &&
                                                                                                                        ${ pkgs.git }/bin/git config alias.subscribe !${ pkgs.writeShellScript "subscribe" ''${ pkgs.redis }/bin/redis-cli SUBSCRIBE git-commit-received git-commit-ready | while read -r line ; do ${ pkgs.coreutils }/bin/echo "${ _environment-variable "line" }"; done'' } &&
                                                                                                                        ${ pkgs.git }/bin/git config alias.ping !${ pkgs.writeShellScript "ping" ''${ pkgs.git }/bin/git commit --allow-empty --allow-empty-message ${ _environment-variable "@" }'' } &&
                                                                                                                        ${ pkgs.git }/bin/git remote add origin ${ value.origin } &&
                                                                                                                        ${ pkgs.coreutils }/bin/ln --symbolic ${ post-commit } /work/${ value.user-name }/git/hooks/post-commit &&
                                                                                                                        ${ pkgs.git }/bin/git fetch &&
                                                                                                                        ${ pkgs.jetbrains.idea-community }/bin/idea-community .
                                                                                                                ''
                                                                                                ) ;
                                                                                    } ;
                                                                            in
                                                                                pkgs.writeShellScriptBin
                                                                                    value.workspace-name
                                                                                    ''
                                                                                        export TEMPORARY=$( ${ pkgs.coreutils }/bin/mktemp --directory ) &&
                                                                                            ${ user-environment }/bin/user-environment
                                                                                     '';
                                                                in builtins.map mapper config.personal.workspaces ;
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
                                                                                        host = lib.mkOption { default = "github.com" ; type = lib.types.str ; } ;
                                                                                        identity-file = lib.mkOption { type = lib.types.path ; } ;
                                                                                        known-hosts = lib.mkOption { type = lib.types.path ; } ;
                                                                                        origin = lib.mkOption { type = lib.types.str ; } ;
                                                                                        port = lib.mkOption { default = 22 ; type = lib.types.int ; } ;
                                                                                        process = lib.mkOption { default = null ; type = lib.types.nullOr lib.types.str ; } ;
                                                                                        user = lib.mkOption { default = "git" ; type = lib.types.str ; } ;
                                                                                        user-email = lib.mkOption { type = lib.types.str ; } ;
                                                                                        user-name = lib.mkOption { type = lib.types.str ; } ;
                                                                                        workspace-name = lib.mkOption { type = lib.types.str ; } ;
                                                                                    } ;
                                                                            } ;
                                                                    in lib.types.listOf config ;
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
