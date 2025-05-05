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
                                                        git-remotes =
                                                            {
                                                                after = [ "network.target" "network-online.target" ] ;
                                                                serviceConfig =
                                                                    {
                                                                        ExecStart =
                                                                            let
                                                                                preamble =
                                                                                    [
                                                                                        "if [ ! -d /tmp/workspaces ] ; then ${ pkgs.coreutils }/bin/mkdir /tmp/workspaces ; fi"
                                                                                        "if [ ! -d /tmp/workspaces/checkouts ] ; then ${ pkgs.coreutils }/bin/mkdir /tmp/workspaces/checkouts ; fi"
                                                                                        "if [ ! -d /tmp/workspaces/internal ] ; then ${ pkgs.coreutils }/bin/mkdir /tmp/workspaces/internal ; fi"
                                                                                        "if [ ! -d /tmp/workspaces/ssh ] ; then ${ pkgs.coreutils }/bin/mkdir /tmp/workspaces/ssh ; fi"
                                                                                        "if [ ! -d /tmp/workspaces/temporary ] ; then ${ pkgs.coreutils }/bin/mkdir /tmp/workspaces/temporary ; fi"
                                                                                    ] ;
                                                                                mapper =
                                                                                    value :
                                                                                        [
                                                                                            "HASH=$( ${ pkgs.coreutils }/bin/echo $( ${ pkgs.coreutils }/bin/date +%Y-%m-%d-%H ) ${ builtins.hashString "sha512" ( builtins.toJSON value ) } | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -128 )"
                                                                                            "${ pkgs.coreutils }/bin/cat ${ value.identity-file } > /tmp/workspaces/ssh/${ _environment-variable "HASH" }"
                                                                                            "${ pkgs.coreutils }/bin/chmod 0400 /tmp/workspaces/ssh/${ _environment-variable "HASH" }"
                                                                                            (
                                                                                                let
                                                                                                    initial =
                                                                                                        ''
                                                                                                            if [ -e /tmp/workspaces/checkouts/${ _environment-variable "HASH" } ]
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/mv /tmp/workspaces/checkouts/${ _environment-variable "HASH" } $( ${ pkgs.coreutils }/bin/mktemp --dry-run /tmp/workspaces/temporary/XXXXXXXX )
                                                                                                            fi &&
                                                                                                                if [ -e /tmp/workspaces/internal/${ _environment-variable "HASH" } ]
                                                                                                                then
                                                                                                                    ${ pkgs.coreutils }/bin/mv /tmp/workspaces/internal/${ _environment-variable "HASH" } $( ${ pkgs.coreutils }/bin/mktemp --dry-run /tmp/workspaces/temporary/XXXXXXXX )
                                                                                                                fi &&
                                                                                                                ${ pkgs.coreutils }/bin/mkdir /tmp/workspaces/checkouts/${ _environment-variable "HASH" } &&
                                                                                                                ${ pkgs.coreutils }/bin/mkdir /tmp/workspaces/internal/${ _environment-variable "HASH" } &&
                                                                                                                ${ pkgs.git }/bin/git --separte-git-dir=/tmp/workspaces/internal/${ _environment-variable "HASH" } /tmp/workspaces/checkouts/${ _environment-variable "HASH" }
                                                                                                        '' ;
                                                                                                    in "if [ ! -d /tmp/workspaces/checkout/${ _environment-variable "HASH" } ] || [ ! -d /tmp/workspaces/internal/${ _environment-variable "HASH" } ] ; then ${ pkgs.writeShellScript "initial" initial } ; fi"
                                                                                            )
                                                                                        ] ;
                                                                                in pkgs.writeShellScript "ExecStart" ( builtins.concatStringsSep " &&\n\t" ( builtins.concatLists [ preamble ( builtins.concatLists ( builtins.map mapper config.personal.remotes ) ) ] ) ) ;
                                                                        User = config.personal.user.name ;
                                                                    } ;
                                                                wantedBy = [ "multi-user.target" ] ;
                                                            } ;
                                                        job-pick =
                                                            {
                                                                serviceConfig =
                                                                    {
                                                                        ExecStart =
                                                                            pkgs.writeShellScript
                                                                                "ExecStart"
                                                                                ''
                                                                                    exec 201> /tmp/remotes/jobs.lock &&
                                                                                        ${ pkgs.flock }/bin/flock 201 &&
                                                                                        if [ -s /tmp/remotes/jobs.yaml ]
                                                                                        then
                                                                                            WORK=$( ${ pkgs.coreutils }/bin/mkdir --directory /tmp/remotes/work/XXXXXXXX ) &&
                                                                                                cleanup ( )
                                                                                                    {
                                                                                                        ${ pkgs.coreutils }/bin/rm --recursive --force ${ _environment-variable "WORK" }
                                                                                                    } &&
                                                                                                trap cleanup EXIT &&
                                                                                                ${ pkgs.yq }/bin/yq 'sort_by ( .priority * -1 , .timestamp) ' > ${ _environment-variable "WORK" }/sorted.yaml
                                                                                        fi &&
                                                                                        ${ pkgs.coreutils }/bin/rm /tmp/remotes/jobs.lock
                                                                                '' ;
                                                                        User = config.personal.user.name ;
                                                                    } ;
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
                                                            [
                                                                pkgs.git
                                                            ] ;
                                                        password = config.personal.user.password ;
                                                    } ;
                                            } ;
                                        options =
                                            {
                                                personal.user.description = lib.mkOption { type = lib.types.str ; } ;
                                                personal.user.name = lib.mkOption { type = lib.types.str ; } ;
                                                personal.user.password = lib.mkOption { type = lib.types.str ; } ;
                                                personal.user.token = lib.mkOption { type = lib.types.str ; } ;
                                                personal.remotes =
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
                                                                                        identity-file = lib.mkOption { type = lib.types.path ; } ;
                                                                                        remote = lib.mkOption { type = lib.types.str ; } ;
                                                                                        seed = lib.mkOption { default = "ae1628b4bbdc08b4d74673410a12b6245d930ed68d3d72791263c64606a883fcbad4aca08e4de72b8aa7cbb73073fabeff1f85fa0e921cadfdbbb7e4fc36cb6b" ; type = lib.types.str ; } ;
                                                                                        user = lib.mkOption { default = "git" ; type = lib.types.str ; } ;
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
