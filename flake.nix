{
    inputs =
        {
            environment-variable-lib.url = "/tmp/tmp.cWQ1yyN0hn/environment-variable" ;
	        flake-utils.url = "github:numtide/flake-utils?rev=b1d9ab70662946ef0850d488da1c9019f3a9752a" ;
	        nixpkgs.url = "github:NixOS/nixpkgs?rev=8660d7b646b9c71496c3fb6f022b0f851204beee" ;
	        temporary-lib.url = "/tmp/tmp.cWQ1yyN0hn/temporary" ;
	        # temporary.url = "git+ssh://git@github.com/viktordanek/temporary?rev=6ea43277630b0722aea2f00ffd9fa8ebdc747cc6" ;
        } ;
    outputs =
        { environment-variable-lib , flake-utils , nixpkgs , self , temporary-lib } :
            let
                environment-variable = environment-variable-lib.lib ;
                fun =
                    system :
                        let
                            lib =
                                { config , lib , pkgs , ... } @secondary :
                                    let
                                        temporary = builtins.getAttr system temporary-lib.lib ;
                                        resources =
                                            temporary
                                                {
                                                    scripts =
                                                        {
                                                            foobar =
                                                                { pkgs , ... } : target :
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/mkdir ${ environment-variable target }
                                                                    '' ;
                                                            gnupg =
                                                                { config , pkgs , ... } : target :
                                                                    ''
                                                                        ${ pkgs.coreutils }/bin/mkdir ${ environment-variable target } &&
                                                                            export GNUPGHOME=${ environment-variable target } &&
                                                                            ${ pkgs.gnupg }/bin/gpg --batch --yes --import ${ config.personal.gnupg.gpg.secret-keys } &&
                                                                            ${ pkgs.gnupg }/bin/gpg --import-ownertrust ${ config.personal.gnupg.gpg.ownertrust }
                                                                    '' ;
                                                            virtual-machine =
                                                                { pkgs , ... } : target :
                                                                    ''
                                                                    '' ;
                                                        } ;
                                                    secondary = secondary ;
                                                    temporary =
                                                        {
                                                            foobar = scripts : { init = scripts.foobar ; } ;
                                                            gnupg = scripts : { init = scripts.gnupg ; } ;
                                                        } ;
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
                                                        environment.sessionVariables =
                                                            {
                                                                FOOBAR = "$( ${ resources }/temporary/foobar )" ;
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
                                                                        settings.X11Forwarding = true ;
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
                                                        sound.enable = true ;
                                                        system.stateVersion = "23.05" ;
                                                        time.timeZone = "America/New_York" ;
                                                        users.users.user =
                                                            {
                                                                description = config.personal.user.description ;
                                                                extraGroups = [ "wheel" ] ;
                                                                isNormalUser = true ;
                                                                linger = true ;
                                                                name = config.personal.user.name ;
                                                                packages =
                                                                    [
                                                                        pkgs.emacs
                                                                        pkgs.cowsay
                                                                    ] ;
                                                                password = config.personal.user.password ;
                                                            } ;
                                                    } ;
                                                options =
                                                    {
                                                        personal =
                                                            {
                                                                gnupg =
                                                                    {
                                                                        gpg =
                                                                            {
                                                                                secret-keys = lib.mkOption { type = lib.types.path ; } ;
                                                                                ownertrust = lib.mkOption { type = lib.types.path ; } ;
                                                                            } ;
                                                                        gpg2 =
                                                                            {
                                                                                secret-keys = lib.mkOption { type = lib.types.path ; } ;
                                                                                ownertrust = lib.mkOption { type = lib.types.path ; } ;
                                                                            } ;
                                                                    } ;
                                                                pass =
                                                                    {

                                                                    } ;
                                                                repository = lib.mkOption { default = "repository.git" ; type = lib.types.str ; } ;
                                                                user =
                                                                    {
                                                                        description = lib.mkOption { type = lib.types.str ; } ;
                                                                        email = lib.mkOption { type = lib.types.str ; } ;
                                                                        name = lib.mkOption { type = lib.types.str ; } ;
                                                                        password = lib.mkOption { type =  lib.types.str ; } ;
                                                                        picture = lib.mkOption { type = lib.types.path  ; } ;
                                                                    } ;
                                                                wifi =
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
                                    } ;
                            in
                                {
                                    lib = lib ;
                                } ;
                            in flake-utils.lib.eachDefaultSystem fun ;
}
