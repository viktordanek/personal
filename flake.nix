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
                                                systemd.services =
                                                    {
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
                                                                                                "--bind ${ _environment-variable "TEMPORARY" } /home"
                                                                                            ] ;
                                                                                        name = "user-environment" ;
                                                                                        profile =
                                                                                            builtins.concatStringsSep
                                                                                                " &&\n\t"
                                                                                                [
                                                                                                    "export GIT_WORK_TREE=/home/${ value.user-name }/work"
                                                                                                    "export GIT_DIR=/home/${ value.user-name }/git"
                                                                                                ] ;
                                                                                        runScript =
                                                                                            builtins.toString
                                                                                                (
                                                                                                    pkgs.writeShellScript
                                                                                                        "script"
                                                                                                        ''
                                                                                                            ${ pkgs.coreutils }/bin/cat ${ value.identity-file } > /home/${ value.user-name }/.ssh/id-rsa &&
                                                                                                                ${ pkgs.coreutils }/bin/cat ${ value.known-hosts } > /home/${ value.user-name }/.ssh/known-hosts &&
                                                                                                                ( ${ pkgs.coreutils }/bin/cat > /home/${ value.user-name }/.ssh/config <<EOF
                                                                                                                    Host ${ value.host }
                                                                                                                    IdentityFile /home/${ value.user-name }/.ssh/id-rsa
                                                                                                                    User ${ value.user }
                                                                                                                    UserKnownHostsFile /home/${ value.user-name }/.ssh/known-hosts &&
                                                                                                                    UseStrictHostKeyChecking true
                                                                                                            EOF
                                                                                                                ) &&
                                                                                                                ${ pkgs.coreutils }/bin/chmod 0400 ${ _environment-variable "HOMEY" }/.ssh/config ${ _environment-variable "HOMEY" }/.ssh/id-rsa ${ _environment-variable "HOMEY" }/.ssh/known-hosts &&
                                                                                                                ${ pkgs.git }/bin/git init --separate-git-dir=${ _environment-variable "GIT_DIR" } ${ _environment-variable "GIT_WORK_TREE" } &&
                                                                                                                ${ pkgs.git }/bin/git config core.sshCommand "${ pkgs.openssh }/bin/ssh -F ${ _environment-variable "HOMEY" }/.ssh/config" &&
                                                                                                                ${ pkgs.git }/bin/git config user.email ${ value.user-email } &&
                                                                                                                ${ pkgs.git }/bin/git config user.name ${ value.user-name } &&
                                                                                                                ${ pkgs.git }/bin/git remote add origin ${ value.origin } &&
                                                                                                                ${ pkgs.jetbrains.idea-community }/bin/idea /home/${ value.user-name }
                                                                                                        ''
                                                                                                ) ;
                                                                                    } ;
                                                                            in
                                                                                pkgs.writeShellScriptBin
                                                                                    value.workspace-name
                                                                                    ''
                                                                                        export TEMPORARY=$( ${ pkgs.coreutils }/bin/mktemp --directory ) &&
                                                                                            ${ pkgs.coreutils }/bin/mkdir ${ _environment-variable "TEMPORARY" }/${ value.user-name } &&
                                                                                            ${ pkgs.coreutils }/bin/mkdir ${ _environment-variable "TEMPORARY" }/${ value.user-name }/.ssh &&
                                                                                            ${ pkgs.coreutils }/bin/mkdir ${ _environment-variable "TEMPORARY" }/${ value.user-name }/git &&
                                                                                            ${ pkgs.coreutils }/bin/mkdir ${ _environment-variable "TEMPORARY" }/${ value.user-name }/work &&
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
