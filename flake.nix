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
                                        password-store-extensions-dir =
                                            pkgs :
                                                pkgs.stdenv.mkDerivation
                                                    {
                                                        name = "password-store-extensions-dir" ;
                                                        src = ./. ;
                                                        installPhase =
                                                            ''
                                                                ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                    ${ pkgs.coreutils }/bin/ln --symbolic ${ resources }/scripts/util/pass/expiry $out/expiry.bash
                                                            '' ;
                                                    } ;
                                        resources =
                                            temporary
                                                {
                                                    out = out ;
                                                    scripts =
                                                        {
                                                            init =
                                                                {
                                                                    foobar =
                                                                        { pkgs , ... } : target :
                                                                            ''
                                                                                ${ pkgs.coreutils }/bin/mkdir ${ environment-variable target }
                                                                            '' ;
                                                                    gnucash =
                                                                        { config , pkgs , ... } : target :
                                                                            ''
                                                                                ${ pkgs.coreutils }/bin/mkdir ${ environment-variable target } &&
                                                                                    cd ${ environment-variable target } &&
                                                                                    ${ pkgs.git }/bin/git init &&
                                                                                    ${ pkgs.git }/bin/git config user.name "${ config.personal.user.description }" &&
                                                                                    ${ pkgs.git }/bin/git config user.email "${ config.personal.user.email }" &&
                                                                                    ${ pkgs.git }/bin/git config core.sshCommand "${ pkgs.openssh }/bin/ssh -i ${ config.personal.user.ssh-key } -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" &&
                                                                                    ${ pkgs.git }/bin/git remote add origin ${ config.personal.gnucash.remote } &&
                                                                                    ${ pkgs.coreutils }/bin/ln --symbolic ${ environment-variable out }/scripts/util/git/post-commit .git/hooks/post-commit &&
                                                                                    ${ pkgs.git }/bin/git fetch origin ${ config.personal.gnucash.branch } &&
                                                                                    ${ pkgs.git }/bin/git checkout ${ config.personal.gnucash.branch }
                                                                            '' ;
                                                                    gnupg =
                                                                        { config , pkgs , ... } : target :
                                                                            ''
                                                                                ${ pkgs.coreutils }/bin/mkdir ${ environment-variable target } &&
                                                                                    ${ pkgs.coreutils }/bin/chmod 0700 ${ environment-variable target }
                                                                                    export GNUPGHOME=${ environment-variable target } &&
                                                                                    ${ pkgs.gnupg }/bin/gpg --batch --yes --import ${ config.personal.gnupg.gpg.secret-keys } &&
                                                                                    ${ pkgs.gnupg }/bin/gpg --import-ownertrust ${ config.personal.gnupg.gpg.ownertrust } &&
                                                                                    ${ pkgs.gnupg }/bin/gpg --batch --yes --import ${ config.personal.gnupg.gpg2.secret-keys } &&
                                                                                    ${ pkgs.gnupg }/bin/gpg --import-ownertrust ${ config.personal.gnupg.gpg2.ownertrust }
                                                                            '' ;
                                                                    paperless =
                                                                        { config , pkgs , ... } : target :
                                                                            ''
                                                                                ${ pkgs.coreutils }/bin/mkdir ${ environment-variable target } &&
                                                                                    cd ${ environment-variable target } &&
                                                                                    ${ pkgs.git }/bin/git init &&
                                                                                    ${ pkgs.git }/bin/git config user.name "${ config.personal.user.description }" &&
                                                                                    ${ pkgs.git }/bin/git config user.email "${ config.personal.user.email }" &&
                                                                                    ${ pkgs.git }/bin/git config core.sshCommand "${ pkgs.openssh }/bin/ssh -i ${ config.personal.user.ssh-key } -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" &&
                                                                                    ${ pkgs.git }/bin/git remote add origin ${ config.personal.paperless.remote } &&
                                                                                    ${ pkgs.coreutils }/bin/ln --symbolic ${ environment-variable out }/scripts/util/git/post-commit .git/hooks/post-commit &&
                                                                                    ${ pkgs.git }/bin/git fetch origin ${ config.personal.paperless.branch } &&
                                                                                    ${ pkgs.git }/bin/git checkout ${ config.personal.paperless.branch }
                                                                            '' ;
                                                                    pass =
                                                                        { config , pkgs , ... } : target :
                                                                            ''
                                                                                ${ pkgs.coreutils }/bin/mkdir ${ environment-variable target } &&
                                                                                    cd ${ environment-variable target } &&
                                                                                    ${ pkgs.git }/bin/git init &&
                                                                                    ${ pkgs.git }/bin/git config user.name "${ config.personal.user.description }" &&
                                                                                    ${ pkgs.git }/bin/git config user.email "${ config.personal.user.email }" &&
                                                                                    ${ pkgs.git }/bin/git config core.sshCommand "${ pkgs.openssh }/bin/ssh -i ${ config.personal.user.ssh-key } -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" &&
                                                                                    ${ pkgs.git }/bin/git remote add origin ${ config.personal.pass.remote } &&
                                                                                    ${ pkgs.coreutils }/bin/ln --symbolic ${ environment-variable out }/scripts/util/git/post-commit .git/hooks/post-commit &&
                                                                                    ${ pkgs.git }/bin/git fetch origin ${ config.personal.pass.branch } &&
                                                                                    ${ pkgs.git }/bin/git checkout ${ config.personal.pass.branch }
                                                                            '' ;
                                                                } ;
                                                            util =
                                                                {
                                                                    git =
                                                                        {
                                                                            post-commit =
                                                                                { pkgs , ... } : target :
                                                                                    ''
                                                                                        while ! ${ pkgs.git }/bin/git push origin HEAD
                                                                                        do
                                                                                            ${ pkgs.coreutils }/bin/sleep 1s
                                                                                        done
                                                                                    '' ;
                                                                        } ;
                                                                    pass =
                                                                        {
                                                                            expiry =
                                                                                { config , pkgs , ... } : target :
                                                                                    ''
                                                                                        ARG1=${ environment-variable 1 } &&
                                                                                            THRESHOLD=${ environment-variable "ARG1:=${ builtins.toString config.personal.pass.threshold }" } &&
                                                                                            NOW=$( ${ pkgs.coreutils }/bin/date +%s ) &&
                                                                                            ${ pkgs.pass }/bin/pass git ls-tree -r HEAD --name-only | ${ pkgs.gnugrep }/bin/grep ".gpg\$" | ${ pkgs.gnugrep }/bin/grep --invert "/\$" | ${ pkgs.gnugrep }/bin/grep --invert "^[.].*\$" | ${ pkgs.gnused }/bin/sed "s#\.gpg\$##" | while read PASS
                                                                                            do
                                                                                                THEN=$( ${ pkgs.pass }/bin/pass git log -1 --format="%ct" -- ${ environment-variable "PASS" }.gpg ) &&
                                                                                                    AGE=$(( ${ environment-variable "NOW" } - ${ environment-variable "THEN" } )) &&
                                                                                                    if [ ${ environment-variable "AGE" } -gt ${ environment-variable "THRESHOLD" } ]
                                                                                                    then
                                                                                                        ${ pkgs.coreutils }/bin/echo ${ environment-variable "AGE" } ${ environment-variable "PASS" }
                                                                                                    fi
                                                                                            done | ${ pkgs.coreutils }/bin/sort --key 1 --numeric-sort | ${ pkgs.coreutils }/bin/cut --delimiter " " --fields 2

                                                                                    '' ;
                                                                        } ;
                                                                } ;
                                                        } ;
                                                    secondary = secondary ;
                                                    temporary =
                                                        {
                                                            foobar = scripts : { init = scripts.init.foobar ; } ;
                                                            gnupg = scripts : { init = scripts.init.gnupg ; } ;
                                                            gnucash = scripts : { init = scripts.init.gnucash ; } ;
                                                            paperless = scripts : { init = scripts.init.paperless ; } ;
                                                            pass = scripts : { init = scripts.init.pass ; } ;
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
                                                                # This is not doing exactly what I want.
                                                                # I want it to provide the home variable.
                                                                # But it does not.
                                                                # So we must do `gnucash ${ environment-variable "GNCHOME" }/gnucash.xml.gnucash`
                                                                GNCHOME="$( ${ resources }/temporary/gnucash )" ;
                                                                GNUPGHOME= "$( ${ resources }/temporary/gnupg )" ;
                                                                PASSWORD_STORE_DIR = "$( ${ resources }/temporary/pass )" ;
                                                                PASSWORD_STORE_GENERATED_LENGTH="$( ${ pkgs.coreutils }/bin/date +%y )" ;
                                                                PASSWORD_STORE_CHARACTER_SET="abCD23" ;
                                                                PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS = "PTxy45-=" ;
                                                                PASSWORD_STORE_ENABLE_EXTENSIONS = "true" ;
                                                                PASSWORD_STORE_EXTENSIONS_DIR = "${ password-store-extensions-dir pkgs }" ;
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
                                                                paperless =
                                                                    {
                                                                        enable = true ;
                                                                        mediaDir = "$( ${ resources }/temporary/paperless )" ;  
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
                                                        systemd.user.services.resource =
                                                            {
                                                                serviceConfig =
                                                                    {
                                                                        ExecStart = "${ resources }/service" ;
                                                                    } ;
                                                                wantedBy = [ "default.target" ] ;
                                                            } ;
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
                                                                        pkgs.firefox
                                                                        pkgs.gnucash
                                                                        pkgs.jrnl
                                                                        pkgs.paperless-ngx
                                                                        pkgs.pass
                                                                        pkgs.git
                                                                        pkgs.pinentry
                                                                    ] ;
                                                                password = config.personal.user.password ;
                                                            } ;
                                                    } ;
                                                options =
                                                    {
                                                        personal =
                                                            {
                                                                gnucash =
                                                                    {
                                                                        branch = lib.mkOption { type = lib.types.str ; } ;
                                                                        name = lib.mkOption { type = lib.types.str ; } ;
                                                                        remote = lib.mkOption { type = lib.types.str ; } ;
                                                                    } ;
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
                                                                paperless =
                                                                    {
                                                                        branch = lib.mkOption { type = lib.types.str ; } ;
                                                                        name = lib.mkOption { type = lib.types.str ; } ;
                                                                        remote = lib.mkOption { type = lib.types.str ; } ;
                                                                    } ;
                                                                pass =
                                                                    {
                                                                        branch = lib.mkOption { type = lib.types.str ; } ;
                                                                        remote = lib.mkOption { type = lib.types.str ; } ;
                                                                        threshold = lib.mkOption { type = lib.types.int ; default = 60 * 60 * 24 * 365 ; } ;
                                                                    } ;
                                                                repository = lib.mkOption { default = "repository.git" ; type = lib.types.str ; } ;
                                                                user =
                                                                    {
                                                                        description = lib.mkOption { type = lib.types.str ; } ;
                                                                        email = lib.mkOption { type = lib.types.str ; } ;
                                                                        name = lib.mkOption { type = lib.types.str ; } ;
                                                                        password = lib.mkOption { type =  lib.types.str ; } ;
                                                                        picture = lib.mkOption { type = lib.types.path  ; } ;
                                                                        ssh-key = lib.mkOption { type = lib.types.path ; } ;
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
