{
    inputs =
        {
            environment-variable-lib.url = "/tmp/tmp.cWQ1yyN0hn/environment-variable" ;
	        flake-utils.url = "github:numtide/flake-utils" ;
	        nixpkgs.url = "github:NixOS/nixpkgs" ;
	        temporary-lib.url = "github:viktordanek/temporary" ;
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
                                        out = "b1b107fe02af5425cf0f82c5552b73ac25904368f3b6454ebff1f815597b2281d0fd55a11f0a8d87e4615c62146f67c23b70e4d0b7a5a52d3a7b3267bd3597da" ;
                                        temporary = builtins.getAttr system temporary-lib.lib ;
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
                                                                        name = lib.mkOption { type = lib.types.str ; } ;
                                                                        password = lib.mkOption { type =  lib.types.str ; } ;
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
                            pkgs = import nixpkgs { inherit system; } ;
                            in
                                {
                                    checks =
                                        {
                                            has-pass =
                                                pkgs.runCommand "check-pass"
                                                    {}
                                                    (
                                                        let
                                                            module = lib secondary ;
                                                            secondary =
                                                                {
                                                                    config =
                                                                        {
                                                                            personal =
                                                                                {
                                                                                    user =
                                                                                        {
                                                                                            description = "Trevor C Bradford" ;
                                                                                            name = "trevor" ;
                                                                                            password = "wieJeech7L" ;
                                                                                        } ;
                                                                                    wifi =
                                                                                        {
                                                                                            "Trevor C Bradford's WIFI SSID" = "0ac26bc8-fdad-41c1-8728-724f28533ec9" ;
                                                                                            "GUEST WIFI SSID" = "b6fe8815-328a-41d1-93f5-e5dc759a0231" ;
                                                                                        } ;
                                                                                } ;
                                                                        } ;
                                                                    lib = lib ;
                                                                    pkgs = pkgs ;
                                                                } ;
                                                            test =
                                                                ''
                                                                    test_user ( )
                                                                        {
                                                                            assert_equals "Trevor C Bradford" "${ module.config.users.users.user.description }" "We can set the user's full name in options." &&
                                                                                assert_equals "trevor" "${ module.config.users.users.user.name }" "We can set the user's user name in options." &&
                                                                                assert_equals "wieJeech7L" "${ module.config.users.users.user.password }" "We can set the user's password in options."

                                                                        } &&
                                                                        test_wifi ( )
                                                                            {
                                                                                assert_equals "0ac26bc8-fdad-41c1-8728-724f28533ec9" "${ module.config.networking.wireless.networks."Trevor C Bradford's WIFI SSID" }" "We can set the wifi password in options." &&
                                                                                assert_equals "b6fe8815-328a-41d1-93f5-e5dc759a0231" "${ module.config.networking.wireless.networks."GUEST WIFI SSID" }" "We can set any arbitrary number of wifi passwords in options."
                                                                            }
                                                                '' ;
                                                        in
                                                            ''
                                                                ${ pkgs.bash_unit }/bin/bash_unit ${ pkgs.writeShellScript "test" test } > >( ${ pkgs.coreutils }/bin/tee $out ) 2>&1
                                                            ''
                                                    ) ;
                                        } ;
                                    lib = lib ;
                                } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
