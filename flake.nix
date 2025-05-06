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
                                                systemd.services.job-queue =
                                                    {
                                                        enable = true ;
                                                        serviceConfig =
                                                            {
                                                                ExecStart =
                                                                    pkgs.writeShellScript
                                                                        "ExecStart"
                                                                        ''
                                                                            while [ -d /tmp/queue/future ]
                                                                            do
                                                                                exec 201> /tmp/queue/present.lock &&
                                                                                    ${ pkgs.flock }/bin/flock 201 &&
                                                                                    exec 202> /tmp/queue/future.lock &&
                                                                                    ${ pkgs.flock }/bin/flock 202 &&
                                                                                    JOB=$( ${ pkgs.findutils }/bin/find /tmp/queue/future | ${ pkgs.coreutils }/bin/sort | ${ pkgs.coreutils }/bin/head --limit 1 ) &&
                                                                                    ${ pkgs.coreutils }/bin/mv ${ _environment-variable "JOB" } /tmp/queue/present &&
                                                                                    if [ $( ${ pkgs.findutils }/bin/find /tmp/queue/future | ${ pkgs.coreutils }/bin/wc --lines ) == 0 ]
                                                                                    then
                                                                                        ${ pkgs.coreutils }/bin/rm /tmp/queue/future
                                                                                    fi &&
                                                                                    ${ pkgs.flock }/bin/flock -u 202 &&
                                                                                    if [ ! -d /tmp/queue/past ]
                                                                                    then
                                                                                        ${ pkgs.coreutils }/bin/mkdir /tmp/queue/past
                                                                                    fi &&
                                                                                    PAST=$( ${ pkgs.coreutils }/bin/mkdir /tmp/queue/past/XXXXXXXX ) &&
                                                                                    ${ pkgs.coreutils }/bin/cp /tmp/queue/present > ${ _environment-variable "PAST" }/script &&
                                                                                    ${ pkgs.coreutils }/bin/echo ${ _environment-variable "JOB" } > ${ _environment-variable "PAST" }/script &&
                                                                                    if /tmp/queue/present > ${ _environment-variable "PAST" }/standard-output 2> ${ _environment-variable "PAST" }/standard-error
                                                                                    then
                                                                                        ${ pkgs.coreutils }/bin/echo ${ _environment-variable "?" } > ${ _environment-variable "PAST" }/status
                                                                                    else
                                                                                        ${ pkgs.coreutils }/bin/echo ${ _environment-variable "?" } > ${ _environment-variable "PAST" }/status
                                                                                    fi &&
                                                                                    ${ pkgs.coreutils }/bin/mv /tmp/queue/present ${ _environment-variable "PAST" }/script
                                                                            done
                                                                        '' ;
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
                                                                                                    pkgs.writeShellScript
                                                                                                        "script"
                                                                                                        ''
                                                                                                            ${ pkgs.coreutils }/bin/mkdir /work/${ value.user-name } &&
                                                                                                                ${ pkgs.coreutils }/bin/mkdir /work/${ value.user-name }/.ssh &&
                                                                                                                ${ pkgs.coreutils }/bin/mkdir /work/${ value.user-name }/git &&
                                                                                                                ${ pkgs.coreutils }/bin/mkdir /work/${ value.user-name }/tree &&
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
                                                                                                                cd /work/${ value.user-name }/tree &&
                                                                                                                ${ pkgs.git }/bin/git init &&
                                                                                                                ${ pkgs.git }/bin/git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F ${ _environment-variable "TEMPORARY" }/${ value.user-name }/.ssh/config" &&
                                                                                                                ${ pkgs.git }/bin/git config user.email ${ value.user-email } &&
                                                                                                                ${ pkgs.git }/bin/git config user.name ${ value.user-name } &&
                                                                                                                ${ pkgs.git }/bin/git config alias.check !${ pkgs.writeShellScript "check" "unset LD_LIBRARY_PATH && ${ pkgs.nix }/bin/nix-collect-garbage && ${ pkgs.nix }/bin/nix flake check" } &&
                                                                                                                ${ pkgs.git }/bin/git remote add origin ${ value.origin } &&
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
