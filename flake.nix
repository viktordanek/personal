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
                                                assertions =
                                                    [
                                                        {
                                                            assertion = builtins.all ( pass : builtins.hasAttr pass.dot-gnupg config.personal.user.dot-gnupg ) ( builtins.attrValues config.personal.user.pass ) ;
                                                            message = "All the pass must have defined dot-gnupg" ;
                                                        }
                                                        {
                                                           assertion = builtins.all ( pass : builtins.hasAttr pass.repository config.personal.user.repository ) ( builtins.attrValues config.personal.user.pass ) ;
                                                           message = "All the pass must have defined repository" ;
                                                        }
                                                    ] ;
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
                                                systemd =
                                                    {
                                                        services =
                                                            {
                                                                simple-backend =
                                                                    {
                                                                        after = [ "network.target" ] ;
                                                                        serviceConfig =
                                                                            {
                                                                                ExecStartPre =
                                                                                    let
                                                                                        script =
                                                                                            ''
                                                                                                if [ ! -d ${ _environment-variable "HOME" }/.local/share/google-photograph-scraper ]
                                                                                                then
                                                                                                    ${ pkgs.coreutils }/bin/echo HOME=${ _environment-variable "HOME" } >&2 &&
                                                                                                    ${ pkgs.coreutils }/bin/mkdir --parents ${ _environment-variable "HOME" }/.local/share/google-photograph-scraper &&
                                                                                                        ${ pkgs.coreutils }/bin/cp ${ config.personal.user.services.google-photograph-scraper.credentials } ${ _environment-variable "HOME" }/.local/share/google-photograph-scraper/credentials.json &&
                                                                                                        ${ pkgs.coreutils }/bin/mkdir ${ _environment-variable "HOME" }/.local/share/google-photograph-scraper/repository &&
                                                                                                        cd ${ _environment-variable "HOME" }/.local/share/google-photograph-scraper/repository &&
                                                                                                        ${ pkgs.git }/bin/git init &&
                                                                                                        ${ pkgs.git }/bin/git config user.name "Google Photograph Scraper" &&
                                                                                                        ${ pkgs.git }/bin/git config user.email "Google Photograph Scraper" &&
                                                                                                        ${ pkgs.git }/bin/git remote add origin ${ config.personal.user.services.google-photograph-scraper.origin } &&
                                                                                                        ${ pkgs.coreutils }/bin/cat ${ config.personal.user.services.google-photograph-scraper.identity } > ${ _environment-variable "HOME" }/.local/share/google-photograph-scraper/identity &&
                                                                                                        ${ pkgs.coreutils }/bin/cat ${ config.personal.user.services.google-photograph-scraper.known-hosts } > ${ _environment-variable "HOME" }/.local/share/google-photograph-scraper/known-hosts &&
                                                                                                        ${ pkgs.coreutils }/bin/chmod 0400 ${ _environment-variable "HOME" }/.local/share/google-photograph-scraper/identity ${ config.personal.user.services.google-photograph-scraper.known-hosts } > ${ _environment-variable "HOME" }/.local/share/google-photograph-scraper/known-hosts &&
                                                                                                        ${ pkgs.git }/bin/git config core.sshCommand "${ pkgs.openssh }/bin/ssh -i ${ _environment-variable "HOME" }/.local/share/google-photograph-scraper/identity -o StrictHostKeyChecking=true -o UserKnownHostsFile=${ config.personal.user.services.google-photograph-scraper.known-hosts } > ${ _environment-variable "HOME" }/.local/share/google-photograph-scraper/known-hosts" &&
                                                                                                        if ${ pkgs.git }/bin/git fetch origin main
                                                                                                        then
                                                                                                            ${ pkgs.git }/bin/git checkout main
                                                                                                        else
                                                                                                            ${ pkgs.git }/bin/checkout -b main
                                                                                                        fi
                                                                                                fi
                                                                                            '' ;
                                                                                            in pkgs.writeShellScript "script" script ;
                                                                                ExecStart =
                                                                                    let
                                                                                        pythonEnv =
                                                                                            pkgs.python3.buildPythonApplication
                                                                                                {
                                                                                                    pname = "google-photograph-scraper" ;
                                                                                                    version = "1.0" ;
                                                                                                    src = ./. ;
                                                                                                    entryPoints = [ "scrape_google_photos.py" ] ;
                                                                                                    propogateBuildInputs =
                                                                                                        [
                                                                                                            pkgs.python3Packages.google-auth
                                                                                                            pkgs.python3Packages.google-api-python-client
                                                                                                        ] ;
                                                                                                } ;
                                                                                        in "${ pythonEnv }/bin/google-photograph-scraper" ;
                                                                                DynamicUser = true ;
                                                                                Environment =
                                                                                    [
                                                                                        "HOME=/var/lib/google-photograph-scraper"
                                                                                        "XDG_DATA_HOME=/var/lib/google-photograph-scraper"
                                                                                    ] ;
                                                                                Restart = "on-failure" ;
                                                                                StateDirectory = "google-photograph-scraper" ;
                                                                            } ;
                                                                        wantedBy = [ "multi-user.target" ] ;
                                                                    } ;
                                                            } ;
                                                        timers =
                                                            {
                                                                simple-backend =
                                                                    {
                                                                        timerConfig =
                                                                            {
                                                                                OnBootSec = "5min" ;
                                                                                OnUnitActiveSec = "24h" ;
                                                                                Persistent = true ;
                                                                            } ;
                                                                        wantedBy = [ "timers.target" ] ;
                                                                    } ;
                                                            } ;
                                                    } ;
                                                system.stateVersion = "23.05" ;
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
                                                                                                        export GNUPGHOME=/tmp/$( ${ pkgs.coreutils }/bin/echo DOT_GNUPG ${ name } ${ _environment-variable "TIMESTAMP" } | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -${ builtins.toString config.personal.user.hash-length } ) &&
                                                                                                            if [ ! -d ${ _environment-variable "GNUPGHOME" } ]
                                                                                                            then
                                                                                                                ${ if builtins.substring 0 1 value.gpg-secret-keys == "/" && builtins.pathExists value.gpg-secret-keys then "SECRET_KEYS=${ value.gpg-secret-keys }" else "SECRET_KEYS=$( ${ pkgs.coreutils }/bin/mktemp ) && ${ value.gpg-secret-keys } > ${ _environment-variable "SECRET_KEYS" }" } &&
                                                                                                                    ${ if builtins.substring 0 1 value.gpg-ownertrust == "/" && builtins.pathExists value.gpg-ownertrust then "OWNERTRUST=${ value.gpg-ownertrust }" else "OWNERTRUST=$( ${ pkgs.coreutils }/bin/mktemp ) && ${ value.gpg-ownertrust } > ${ _environment-variable "OWNERTRUST" }" } &&
                                                                                                                    ${ pkgs.coreutils }/bin/mkdir ${ _environment-variable "GNUPGHOME" } &&
                                                                                                                    ${ pkgs.coreutils }/bin/chmod 0700 ${ _environment-variable "GNUPGHOME" } &&
                                                                                                                    ${ pkgs.gnupg }/bin/gpgconf --homedir ${ _environment-variable "GNUPGHOME" } --create-socketdir &&
                                                                                                                    ${ pkgs.gnupg }/bin/gpgconf --homedir ${ _environment-variable "GNUPGHOME" } --launch gpg-agent &&
                                                                                                                    while [ ! -f ${ _environment-variable "SECRET_KEYS" } ]
                                                                                                                    do
                                                                                                                        ${ pkgs.coreutils }/bin/sleep 1
                                                                                                                    done &&
                                                                                                                    while [ ! -f ${ _environment-variable "OWNERTRUST" } ]
                                                                                                                    do
                                                                                                                        ${ pkgs.coreutils }/bin/sleep 1
                                                                                                                    done &&
                                                                                                                    while [ ! -S "$( ${ pkgs.gnupg }/bin/gpgconf --homedir ${ _environment-variable "GNUPGHOME" } --list-dir agent-socket )" ]
                                                                                                                    do
                                                                                                                        ${ pkgs.coreutils }/bin/sleep 1
                                                                                                                    done &&
                                                                                                                    ${ pkgs.gnupg }/bin/gpg --batch --yes --homedir ${ _environment-variable "GNUPGHOME" } --import ${ _environment-variable "SECRET_KEYS" } &&
                                                                                                                    ${ pkgs.gnupg }/bin/gpg --batch --yes --homedir ${ _environment-variable "GNUPGHOME" } --import-ownertrust ${ _environment-variable "OWNERTRUST" } &&
                                                                                                                    ${ pkgs.gnupg }/bin/gpg --batch --yes --homedir ${ _environment-variable "GNUPHOME" } --update-trustdb
                                                                                                            fi &&
                                                                                                            ${ pkgs.coreutils }/bin/echo ${ _environment-variable "GNUPGHOME" }
                                                                                                    '' ;
                                                                                                in "makeWrapper ${ pkgs.writeShellScript "script" script } $out/scripts/dot-gnupg/${ name } --set OUT $out" ;
                                                                                    dot-ssh =
                                                                                        name : value :
                                                                                            let
                                                                                                script =
                                                                                                    pkgs.writeShellScript
                                                                                                        "dot-ssh"
                                                                                                        ''
                                                                                                            DOT_SSH=/tmp/$( ${ pkgs.coreutils }/bin/echo DOT_SSH ${ name } ${ _environment-variable "TIMESTAMP" } | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -${ builtins.toString config.personal.user.hash-length } ) &&
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
                                                                                    files = name : value : "${ value } > $out/files/${ name }" ;
                                                                                    pass =
                                                                                        name : value :
                                                                                            let
                                                                                                script =
                                                                                                    ''
                                                                                                        export TIMESTAMP=${ _environment-variable "TIMESTAMP:$( ${ pkgs.coreutils }/bin/date +${ config.personal.user.time-mask } )" } &&
                                                                                                            export PASSWORD_STORE_DIR=$( ${ _environment-variable "OUT" }/scripts/repository/${ value.repository } ) &&
                                                                                                            export PASSWORD_STORE_GPG_OPTS="--homedir $( ${ _environment-variable "OUT" }/scripts/dot-gnupg/${value.dot-gnupg } )" &&
                                                                                                            export PASSWORD_STORE_ENABLE_EXTENSIONS=${ if builtins.typeOf value.extensions == "null" then "false" else "true" } &&
                                                                                                            export PASSWORD_STORE_EXTENSIONS_DIR=${ if builtins.typeOf value.extensions == "null" then "" else builtins.toString value.extensions } &&
                                                                                                            export PASSWORD_STORE_GENERATED_LENGTH=${ if builtins.typeOf value.generated-length == null then "$( ${ pkgs.coreutils }/bin/date +%Y )" else builtins.toString value.generated-length } &&
                                                                                                            export PASSWORD_STORE_CHARACTER_SET=${ value.character-set } &&
                                                                                                            export PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS=${ value.character-set-no-symbols } &&
                                                                                                            exec ${ pkgs.pass }/bin/pass ${ _environment-variable "@" }
                                                                                                    '' ;
                                                                                                in
                                                                                                    [
                                                                                                        "makeWrapper ${ pkgs.writeShellScript "script" script } $out/bin/${ name } --set OUT $out"
                                                                                                        ''${ pkgs.gnused }/bin/sed -e "s#^complete -o filenames -F _pass pass\$#complete -o filenames -F _pass ${ name }#" -e "s#${ builtins.concatStringsSep "" [ "\\" "$" "HOME" "/" ".password-store" "/" ] }#\$( TIMESTAMP=\$( ${ pkgs.coreutils }/bin/date +${ config.personal.user.time-mask } ) $out/scripts/repository/${ value.repository } )#" -e "w$out/share/bash-completion/completions/${ name }" ${ pkgs.pass }/share/bash-completion/completions/pass''
                                                                                                        "${ pkgs.coreutils }/bin/ln --symbolic ${ pkgs.pass }/share/man/man1/pass.1.gz $out/share/man/man1/${ name }.1.gz"
                                                                                                    ] ;
                                                                                    portfolio =
                                                                                        let
                                                                                            script =
                                                                                                ''
                                                                                                    PORTFOLIO=/tmp/$( ${ pkgs.coreutils }/bin/echo PORTFOLIO ${ _environment-variable "TIMESTAMP" } | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -${ builtins.toString config.personal.user.hash-length } ) &&
                                                                                                    if [ ! -d ${ _environment-variable "PORTFOLIO" } ]
                                                                                                    then
                                                                                                        ${ pkgs.coreutils }/bin/mkdir ${ _environment-variable "PORTFOLIO" } &&
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
                                                                                                        REPOSITORY=/tmp/$( ${ pkgs.coreutils }/bin/echo REPOSITORY ${ name } ${ _environment-variable "TIMESTAMP" } | ${ pkgs.coreutils }/bin/sha512sum | ${ pkgs.coreutils }/bin/cut --bytes -${ builtins.toString config.personal.user.hash-length } ) &&
                                                                                                            if [ ! -d ${ _environment-variable "REPOSITORY" } ]
                                                                                                            then
                                                                                                                ${ pkgs.coreutils }/bin/mkdir ${ _environment-variable "REPOSITORY" } &&
                                                                                                                    cd ${ _environment-variable "REPOSITORY" } &&
                                                                                                                    ${ pkgs.git }/bin/git init 1>&2 &&
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
                                                                                                    export TIMESTAMP=${ _environment-variable "TIMESTAMP:$( ${ pkgs.coreutils }/bin/date +${ config.personal.user.time-mask } )" } &&
                                                                                                        ${ pkgs.jetbrains.idea-community }/bin/idea-community $( ${ _environment-variable "OUT" }/scripts/portfolio )
                                                                                                '' ;
                                                                                            in "makeWrapper ${ pkgs.writeShellScript "script" script } $out/bin/studio --set OUT $out" ;
                                                                                    in
                                                                                        ''
                                                                                            ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                                                export TIMESTAMP=$( ${ pkgs.coreutils }/bin/date +${ config.personal.user.time-mask } ) &&
                                                                                                ${ pkgs.coreutils }/bin/mkdir $out/bin &&
                                                                                                ${ pkgs.coreutils }/bin/mkdir $out/share &&
                                                                                                ${ pkgs.coreutils }/bin/mkdir $out/share/bash-completion &&
                                                                                                ${ pkgs.coreutils }/bin/mkdir $out/share/bash-completion/completions &&
                                                                                                ${ pkgs.coreutils }/bin/mkdir $out/share/man &&
                                                                                                ${ pkgs.coreutils }/bin/mkdir $out/share/man/man1 &&
                                                                                                ${ if builtins.length ( builtins.attrNames config.personal.user.pass ) > 0 then builtins.concatStringsSep " &&\n\t" ( builtins.concatLists (  builtins.attrValues ( builtins.mapAttrs pass config.personal.user.pass ) ) ) else "#" } &&
                                                                                                ${ studio } &&
                                                                                                ${ pkgs.coreutils }/bin/mkdir $out/scripts &&
                                                                                                ${ pkgs.coreutils }/bin/mkdir $out/scripts/dot-gnupg &&
                                                                                                ${ if builtins.length ( builtins.attrNames config.personal.user.dot-gnupg ) > 0 then builtins.concatStringsSep " &&\n\t" ( builtins.attrValues ( builtins.mapAttrs dot-gnupg config.personal.user.dot-gnupg ) ) else "#" } &&
                                                                                                ${ pkgs.coreutils }/bin/mkdir $out/scripts/dot-ssh &&
                                                                                                ${ if builtins.length ( builtins.attrNames config.personal.user.dot-ssh ) > 0 then builtins.concatStringsSep " &&\n\t" ( builtins.attrValues ( builtins.mapAttrs dot-ssh config.personal.user.dot-ssh ) ) else "#" } &&
                                                                                                ${ portfolio } &&
                                                                                                ${ pkgs.coreutils }/bin/mkdir $out/scripts/repository &&
                                                                                                ${ if builtins.length ( builtins.attrNames config.personal.user.repository ) > 0 then builtins.concatStringsSep " &&\n\t" ( builtins.attrValues ( builtins.mapAttrs repository config.personal.user.repository ) ) else "#" } &&
                                                                                                ${ pkgs.coreutils }/bin/mkdir $out/files &&
                                                                                                ${ if builtins.length ( builtins.attrNames config.personal.user.files ) > 0 then let x = builtins.concatStringsSep " &&\n\t" ( builtins.attrValues ( builtins.mapAttrs files config.personal.user.files ) ) ; in builtins.trace x x else "#" }
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
                                                                                                        gpg-ownertrust = lib.mkOption { type = lib.types.either lib.types.str lib.types.path ; } ;
                                                                                                        gpg2-ownertrust = lib.mkOption { type = lib.types.either lib.types.str lib.types.path ; } ;
                                                                                                        gpg-secret-keys = lib.mkOption { type = lib.types.either lib.types.str lib.types.path ; } ;
                                                                                                        gpg2-secret-keys = lib.mkOption { type = lib.types.either lib.types.str lib.types.path ; } ;
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
                                                                files = lib.mkOption { default = { } ; type = lib.types.attrsOf lib.types.str ; } ;
                                                                hash-length = lib.mkOption { default = 64 ; type = lib.types.int ; } ;
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
                                                                                                        dot-gnupg = lib.mkOption { type = lib.types.str ; } ;
                                                                                                        extensions = lib.mkOption { default = null ; type = lib.types.nullOr lib.types.package ; } ;
                                                                                                        repository = lib.mkOption { type = lib.types.str ; } ;
                                                                                                        generated-length = lib.mkOption { default = null ; type = lib.types.nullOr lib.types.int ; } ;
                                                                                                        character-set = lib.mkOption { default = "a-bd-hm-nq-rt-yA-BD-HM-NQ-RT-Y3-9@#%^*" ; type = lib.types.str ; } ;
                                                                                                        character-set-no-symbols = lib.mkOption { default = "a-bd-hm-nq-rt-yA-BD-HM-NQ-RT-Y3-9" ; type = lib.types.str ; } ;
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
                                                                                                        initial = lib.mkOption { default = null ; type = lib.types.str ; } ;
                                                                                                        remotes = lib.mkOption { default = { } ; type = lib.types.attrsOf lib.types.str ; } ;
                                                                                                     } ;
                                                                                            } ;
                                                                                    in lib.types.attrsOf config ;
                                                                        } ;
                                                                services =
                                                                    {
                                                                        google-photograph-scraper =
                                                                            {
                                                                                credentials = lib.mkOption { type = lib.types.path ; } ;
                                                                                known-hosts = lib.mkOption { type = lib.types.path ; } ;
                                                                                identity = lib.mkOption { type = lib.types.path ; } ;
                                                                                origin = lib.mkOption { type = lib.types.str ; } ;
                                                                                repository = lib.mkOption { type = lib.types.str ; } ;
                                                                            } ;
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
