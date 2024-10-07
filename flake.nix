{
    inputs =
        {
	        flake-utils.url = "github:numtide/flake-utils?rev=b1d9ab70662946ef0850d488da1c9019f3a9752a" ;
	        nixpkgs.url = "github:NixOS/nixpkgs?rev=8660d7b646b9c71496c3fb6f022b0f851204beee" ;
	        temporary.url = "git+ssh://git@github.com/viktordanek/temporary?rev=6ea43277630b0722aea2f00ffd9fa8ebdc747cc6" ;
        } ;
    outputs =
        { flake-utils , nixpkgs , self , temporary } :
            let
                fun =
                    system :
                        let
                            lib =
                                { config , lib , pkgs , ... } @secondary :
                                    let
                                        t = builtins.getAttr system temporary.lib ;
                                        custom-shell = pkgs.stdenv.mkDerivation
                                            {
                                                name = "custom-shell" ;
                                                src = ./. ;
                                                installPhase =
                                                    ''
                                                        ${ pkgs.coreutils }/bin/mkdir $out &&
                                                            ${ pkgs.coreutils }/bin/mkdir $out/bin &&
                                                            ${ pkgs.coreutils }/bin/ln --symbolic ${ temporary-scripts }/scripts/custom-shel $out/bin/custom-shell
                                                    '' ;
                                            } ;
                                        temporary-scripts =
                                            t
                                                {
                                                    scripts =
                                                        {
                                                            custom-shell =
                                                                { pkgs , ... } : target :
                                                                    ''
                                                                        export FOOBAR=fb4ec09c-4512-4e2d-aae1-47e00ba6c4a1
                                                                    '' ;
                                                        } ;
                                                    secondary = secondary ;
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
                                                                        custom-shell
                                                                    ] ;
                                                                password = config.personal.user.password ;
                                                            } ;
                                                    } ;
                                                options =
                                                    {
                                                        personal =
                                                            {
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
                                                                                    credentials =
                                                                                        lib.types.submodule
                                                                                            {
                                                                                                options =
                                                                                                    {
                                                                                                        ssid = lib.mkOption { type = lib.types.str ; } ;
                                                                                                        psk = lib.mkOption { type = lib.types.str ; } ;
                                                                                                    } ;
                                                                                            } ;
                                                                                    in lib.types.listOf credentials ;
                                                                        } ;
                                                             } ;
                                                    } ;
                                    } ;
                            in
                                {
                                    checks =
                                        {
                                            simple =
                                                let
                                                    pkgs = import nixpkgs { system = system ; } ;
                                                    in
                                                        pkgs.nixosTest
                                                            {
                                                                name = "simple" ;
                                                                skipTypeCheck = true ;
                                                                nodes =
                                                                    {
                                                                        machine =
                                                                            { config , ... } :
                                                                                {
                                                                                    config =
                                                                                        {
                                                                                            boot.kernelModules = [ "mac80211_hwsim" ] ;
                                                                                            personal =
                                                                                                {
                                                                                                    user =
                                                                                                        {
                                                                                                            description = "Frederick G. Brown" ;
                                                                                                            name = "brown" ;
                                                                                                            password = "6d180183-dab9-4f04-9f40-dd8ce6d48c4e" ;
                                                                                                        } ;
                                                                                                } ;
                                                                                        } ;
                                                                                    imports = [ lib ] ;
                                                                                } ;
                                                                    } ;
                                                                testScript =
                                                                    ''
                                                                        machine.start() ;
                                                                        machine.wait_for_unit("multi-user.target");
                                                                        machine.succeed("su --login brown -c 'whoami'");
                                                                        machine.succeed("su --login brown -c 'cowsay hi'");
                                                                        machine.succeed("ip link | grep -E 'wlan|wlp|wl'");
                                                                    '' ;
                                                            } ;
                                        } ;
                                    lib = lib ;
                                } ;
                            in flake-utils.lib.eachDefaultSystem fun ;
}
