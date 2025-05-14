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
                                    let
                                        timestamp = ''export TIMESTAMP=$( ${ pkgs.coreutils }/bin/date +${ config.personal.user.time-mask } )'' ;
                                        in
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
                                                        environment.systemPackages = [ pkgs.firefox ] ;
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
                                                                        trashy =
                                                                            {
                                                                                after = [ "network.target" ] ;
                                                                                serviceConfig =
                                                                                    {
                                                                                        ExecScript = "${ pkgs.trashy }/bin/trashy remove" ;
                                                                                        User = config.personal.user.name ;
                                                                                    } ;
                                                                                wantedBy = [ "multi-user.target" ] ;
                                                                            } ;
                                                                    } ;
                                                                timers =
                                                                    {
                                                                        trashy =
                                                                            {
                                                                                timerConfig =
                                                                                    {
                                                                                        OnBootSec = "5min" ;
                                                                                        OnUnitActiveSec = "1w" ;
                                                                                        Persistent = true ;
                                                                                    } ;
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
                                                                                            application =
                                                                                                name : value :
                                                                                                    let
                                                                                                        contact =
                                                                                                            {
                                                                                                                name = config.personal.user.description ;
                                                                                                                phone-number = config.personal.user.phone-number ;
                                                                                                                email = config.personal.user.email ;
                                                                                                            } ;
                                                                                                        experience =
                                                                                                            let
                                                                                                                mapper =
                                                                                                                    experience :
                                                                                                                        {
                                                                                                                            title = experience.title ;
                                                                                                                            company = experience.company ;
                                                                                                                            from = ''$( ${ pkgs.coreutils }/bin/date "+${ value.date-mask }" --date @${ builtins.toString experience.from } )'' ;
                                                                                                                            to = if experience.to >= value.current-time then "present" else ''$( ${ pkgs.coreutils }/bin/date "+${ value.date-mask }" --date @${ builtins.toString experience.to } )'' ;
                                                                                                                            achievements = experience.achievements ;
                                                                                                                            separation-reason = experience.separation-reason ;
                                                                                                                        } ;
                                                                                                                min = a : b : if a < b then a else b ;
                                                                                                                max = a : b : if a > b then b else a ;
                                                                                                                backward-reducer =
                                                                                                                    previous : current :
                                                                                                                        let
                                                                                                                            length = builtins.length previous ;
                                                                                                                            penultimate = builtins.elemAt previous ( length - 1 ) ;
                                                                                                                            ultimate =
                                                                                                                                {
                                                                                                                                    company = current.company ;
                                                                                                                                    title = current.title ;
                                                                                                                                    from = if length == 0 then current.from else max ( current.from - value.padding ) penultimate.to ;
                                                                                                                                    to = current.to ;
                                                                                                                                    achievements =
                                                                                                                                        builtins.filter
                                                                                                                                            (
                                                                                                                                                achievement :
                                                                                                                                                    builtins.any
                                                                                                                                                        ( achievementSkill : builtins.elem achievementSkill value.skills )
                                                                                                                                                        achievement.skills
                                                                                                                                            )
                                                                                                                                            current.achievements ;
                                                                                                                                    separation-reason = current.separation-reason ;
                                                                                                                                } ;
                                                                                                                            in builtins.concatLists [ previous [ ultimate ] ] ;
                                                                                                                forward-reducer =
                                                                                                                    previous : current :
                                                                                                                        let
                                                                                                                            length = builtins.length previous ;
                                                                                                                            penultimate = builtins.elemAt previous ( length - 1 ) ;
                                                                                                                            ultimate =
                                                                                                                                {
                                                                                                                                    company = current.company ;
                                                                                                                                    title = current.title ;
                                                                                                                                    from = current.from ;
                                                                                                                                    to = if builtins.typeOf current.to == "null" then config.personal.user.current.time else if length == 0 then min ( current.to + value.padding ) config.personal.user.current-time else min ( current.to + value.padding ) penultimate.from ;
                                                                                                                                    achievements = current.achievements ;
                                                                                                                                    separation-reason = current.separation-reason ;
                                                                                                                                } ;
                                                                                                                            in builtins.concatLists [ previous [ ultimate ] ] ;
                                                                                                                in builtins.map mapper ( builtins.foldl' forward-reducer [ ] ( builtins.sort ( a : b : a.to > b.to ) ( builtins.foldl' backward-reducer [ ] ( builtins.sort ( a : b : a.from < b.from ) ( builtins.filter ( experience : experience.to - experience.from > value.filter ) ( builtins.filter ( experience : builtins.typeOf experience.to == "null" || experience.to > value.current-time - value.experience-target ) config.personal.user.career.experience ) ) ) ) ) ) ;
                                                                                                        resume =
                                                                                                            experience-mapper : insights : file-name :
                                                                                                            ''${ pkgs.coreutils }/bin/echo -en "## Objective \n${ value.objective } \n##Experience \n${ builtins.concatStringsSep "\n" ( builtins.map experience-mapper experience ) } ${ if builtins.typeOf insights == "null" then "" else insights }" > $out/applications/${ name }/${ file-name }.md'' ;
                                                                                                        in
                                                                                                            [
                                                                                                                "${ pkgs.coreutils }/bin/mkdir $out/applications/${ name }"
                                                                                                                (
                                                                                                                    let
                                                                                                                        experience-mapper =
                                                                                                                            experience :
                                                                                                                                let
                                                                                                                                    title = experience.title ;
                                                                                                                                    company = experience.company ;
                                                                                                                                    from = ''$( ${ pkgs.coreutils }/bin/date "+${ value.date-mask }" --date @${ builtins.toString experience.from } )'' ;
                                                                                                                                    in
                                                                                                                                        ''
                                                                                                                                            ### ${ title } at ${ company } ${ from } – ${ if experience.to == config.personal.user.current-time then "present" else ''$( ${ pkgs.coreutils }/bin/date "+${ value.date-mask }" --date @${ builtins.toString experience.to } )'' }
                                                                                                                                            ${ builtins.concatStringsSep "\n" ( builtins.map ( achievement : "- ${ achievement.point }" ) experience.achievements ) }
                                                                                                                                        '' ;
                                                                                                                        in
                                                                                                                            resume experience-mapper null "resume"
                                                                                                                )
                                                                                                                (
                                                                                                                    let
                                                                                                                        insights =
                                                                                                                            let
                                                                                                                                date-of-birth =
                                                                                                                                    let
                                                                                                                                        age = 60 * 60 * 24 * 36525 / 100 * 30 + rand ;
                                                                                                                                        list =
                                                                                                                                            let
                                                                                                                                                generator = index : builtins.substring string index 1 ;
                                                                                                                                                in builtins.genList generator ( builtins.stringLength string );
                                                                                                                                        mod =
                                                                                                                                            A : B :
                                                                                                                                                let
                                                                                                                                                    a = if builtins.typeOf a == "string" then builtins.throw "A ${ a }" else A ;
                                                                                                                                                    b = if builtins.typeOf b == "string then builtins.throw "B ${ b }" else B ;
                                                                                                                                                    in b - ( b * ( a / b ) ) ;
                                                                                                                                        rand = builtins.foldl' reducer 0 list ;
                                                                                                                                        reducer = previous : current :
                                                                                                                                            let
                                                                                                                                                a = previous * 2 + ( builtins.fromJSON current ) ;
                                                                                                                                                b = 60 * 60 * 24 * 36525 / 100 * 10 ;
                                                                                                                                                in mod a b ;
                                                                                                                                        string = builtins.replaceStrings [ "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "a" "b" "c" "d" "e" "f" ] [ "0000" "0001" "0010" "0011" "0100" "0101" "0110" "0111" "1000" "1001" "1010" "1011" "1100" "1101" "1110" "1111" ] ( builtins.hashString "sha512" ( builtins.toString value.current-time ) ) ;
                                                                                                                                        in '''$( ${ pkgs.coreutils }/bin/date +%Y-%m-%d --date @${ builtins.toString ( value.current-time - age ) } )'' ;
                                                                                                                            in "## Insights \n ### DOB: ${ date-of-birth }" ;
                                                                                                                            # in "hello" ;
                                                                                                                        experience-mapper =
                                                                                                                            experience :
                                                                                                                                let
                                                                                                                                    split =
                                                                                                                                        label : string :
                                                                                                                                            if builtins.typeOf string == "null" then ""
                                                                                                                                            else
                                                                                                                                                ''


                                                                                                                                                    ** 📌 ${ label } **
                                                                                                                                                    ${ builtins.concatStringsSep "\n" ( builtins.map ( string : ">     ** ${ string } **" ) ( builtins.filter ( line : builtins.typeOf line == "string" ) ( builtins.split "\n" string ) ) ) }
                                                                                                                                                '' ;
                                                                                                                                    title = experience.title ;
                                                                                                                                    company = experience.company ;
                                                                                                                                    from = ''$( ${ pkgs.coreutils }/bin/date "+${ value.date-mask }" --date @${ builtins.toString experience.from } )'' ;
                                                                                                                                    in
                                                                                                                                        ''
                                                                                                                                            ### ${ title } at ${ company } ${ from } – ${ if experience.to == config.personal.user.current-time then "present" else ''$( ${ pkgs.coreutils }/bin/date "+${ value.date-mask }" --date @${ builtins.toString experience.to } )'' }
                                                                                                                                            ${ builtins.concatStringsSep "\n" ( builtins.map ( achievement : "- ${ achievement.point }${ split "Commentary" achievement.commentary }" ) experience.achievements ) }
                                                                                                                                            ${ split "Separation Reason" experience.separation-reason }
                                                                                                                                        '' ;
                                                                                                                        in
                                                                                                                            resume experience-mapper insights "annotated"
                                                                                                                )
                                                                                                            ] ;
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
                                                                                                                            ${ pkgs.gnupg }/bin/gpgconf --homedir ${ _environment-variable "GNUPGHOME" } --create-socketdir 1>&2 &&
                                                                                                                            ${ pkgs.gnupg }/bin/gpgconf --homedir ${ _environment-variable "GNUPGHOME" } --launch gpg-agent 1>&2 &&
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
                                                                                                                            ${ pkgs.gnupg }/bin/gpg --batch --yes --homedir ${ _environment-variable "GNUPGHOME" } --import ${ _environment-variable "SECRET_KEYS" } 1>&2 &&
                                                                                                                            ${ pkgs.gnupg }/bin/gpg --batch --yes --homedir ${ _environment-variable "GNUPGHOME" } --import-ownertrust ${ _environment-variable "OWNERTRUST" } 1>&2 &&
                                                                                                                            ${ pkgs.gnupg }/bin/gpg --batch --yes --homedir ${ _environment-variable "GNUPHOME" } --update-trustdb 1>&2
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
                                                                                            firefox =
                                                                                                name : value :
                                                                                                    let
                                                                                                        script =
                                                                                                            ''
                                                                                                                ${ timestamp } &&
                                                                                                                    REPOSITORY=$( ${ _environment-variable "OUT" }/scripts/repository/${ value.profile } ) &&
                                                                                                                    ( ${ pkgs.coreutils }/bin/nohup ${ watch } ${ _environment-variable "REPOSITORY" } > /dev/null 2>&1 < /dev/null & ) &&
                                                                                                                    exec ${ pkgs.firefox }/bin/firefox --profile ${ _environment-variable "REPOSITORY" } --no-remote ${ _environment-variable "@" }
                                                                                                            '' ;
                                                                                                        watch =
                                                                                                            pkgs.writeShellScript
                                                                                                                "commit"
                                                                                                                ''
                                                                                                                    WATCH_DIR=${ _environment-variable "1" }
                                                                                                                    BRANCH=main
                                                                                                                    cd ${ _environment-variable "WATCH_DIR" } &&
                                                                                                                    ${ pkgs.inotify-tools }/bin/inotifywait -m -r -e create -e modify -e delete --format '%w%f' "${ _environment-variable "WATCH_DIR" }" | \
                                                                                                                    while read path; do
                                                                                                                      # Exclude anything inside .git
                                                                                                                      case "${ _environment-variable "path" }" in
                                                                                                                        */.git/*) continue ;;
                                                                                                                      esac
                                                                                                                      echo "Detected change: $path"
                                                                                                                      git add -A
                                                                                                                      if [ -n "$(git status --porcelain)" ]; then
                                                                                                                          git commit -m "Auto-commit: $(date -Iseconds)"
                                                                                                                          git push origin "$BRANCH"
                                                                                                                      fi
                                                                                                                    done
                                                                                                                '' ;
                                                                                                        in "makeWrapper ${ pkgs.writeShellScript "script" script } $out/bin/${ name } --set OUT $out" ;
                                                                                            pass =
                                                                                                name : value :
                                                                                                    let
                                                                                                        script =
                                                                                                            let
                                                                                                                extensions =
                                                                                                                    pkgs.stdenv.mkDerivation
                                                                                                                        {
                                                                                                                            installPhase =
                                                                                                                                let
                                                                                                                                    expiry =
                                                                                                                                        ''
                                                                                                                                            CURRENT_DATE=$( ${ pkgs.coreutils }/bin/date +%s ) &&
                                                                                                                                                ${ pkgs.pass }/bin/pass git ls-files "*.gpg" | while read -r FILE
                                                                                                                                                do
                                                                                                                                                    LAST_COMMIT_DATE=$( ${ pkgs.pass }/bin/pass git log -1 --format="%ct" -- ${ _environment-variable "FILE" } ) &&
                                                                                                                                                    if [ $(( ${ _environment-variable "CURRENT_DATE" } - ${ _environment-variable "LAST_COMMIT_DATE" } )) -gt 365 ]
                                                                                                                                                    then
                                                                                                                                                        ${ pkgs.coreutils }/bin/echo ${ _environment-variable "FILE%.gpg" }
                                                                                                                                                    fi
                                                                                                                                                done
                                                                                                                                        '' ;
                                                                                                                                    file =
                                                                                                                                        ''
                                                                                                                                            FILE=$( ${ pkgs.coreutils }/bin/mktemp ) &&
                                                                                                                                                ${ pkgs.pass }/bin/pass ${ _environment-variable "@" } > ${ _environment-variable "FILE" } &&
                                                                                                                                                ${ pkgs.coreutils }/bin/echo ${ _environment-variable "FILE" }
                                                                                                                                        '' ;
                                                                                                                                    phonetic =
                                                                                                                                        ''
                                                                                                                                            declare -A nato=(
                                                                                                                                                [A]=ALPHA [B]=BRAVO [C]=CHARLIE [D]=DELTA [E]=ECHO [F]=FOXTROT
                                                                                                                                                [G]=GOLF [H]=HOTEL [I]=INDIA [J]=JULIETT [K]=KILO [L]=LIMA
                                                                                                                                                [M]=MIKE [N]=NOVEMBER [O]=OSCAR [P]=PAPA [Q]=QUEBEC [R]=ROMEO
                                                                                                                                                [S]=SIERRA [T]=TANGO [U]=UNIFORM [V]=VICTOR [W]=WHISKEY
                                                                                                                                                [X]=X-RAY [Y]=YANKEE [Z]=ZULU
                                                                                                                                            )
                                                                                                                                                declare -A alt=(
                                                                                                                                                    [a]=adam [b]=boston [c]=charlie [d]=david [e]=edward [f]=frank
                                                                                                                                                    [g]=george [h]=henry [i]=ida [j]=john [k]=king [l]=lincoln
                                                                                                                                                    [m]=mary [n]=nancy [o]=oscar [p]=paul [q]=queen [r]=robert
                                                                                                                                                    [s]=sam [t]=tom [u]=union [v]=victor [w]=william [x]=xray
                                                                                                                                                    [y]=young [z]=zebra
                                                                                                                                                )
                                                                                                                                                declare -A digits=(
                                                                                                                                                    [0]=Zero [1]=One [2]=Two [3]=Three [4]=Four
                                                                                                                                                    [5]=Five [6]=Six [7]=Seven [8]=Eight [9]=Nine
                                                                                                                                                )
                                                                                                                                                declare -A symbols=(
                                                                                                                                                    ["!"]="Exclamation" ["@"]="At" ["#"]="Hash" ["$"]="Dollar" ["%"]="Percent"
                                                                                                                                                    ["^"]="Caret" ["&"]="Ampersand" ["*"]="Asterisk" ["("]="LeftParen" [")"]="RightParen"
                                                                                                                                                    ["-"]="Dash" ["_"]="Underscore" ["="]="Equals" ["+"]="Plus" ["["]="LeftBracket"
                                                                                                                                                    ["]"]="RightBracket" ["{"]="LeftBrace" ["}"]="RightBrace" ["\\"]="Backslash"
                                                                                                                                                    ["|"]="Pipe" [";"]="Semicolon" [":"]="Colon" ["'"]="Apostrophe" ['"']="Quote"
                                                                                                                                                    [","]="Comma" ["."]="Period" ["/"]="Slash" ["<"]="LessThan" [">"]="GreaterThan"
                                                                                                                                                    ["?"]="Question" ["\`"]="Backtick" ["~"]="Tilde" [" "]="Space"
                                                                                                                                                )
                                                                                                                                                SECRET=$( ${ pkgs.pass }/bin/pass show ${ _environment-variable "@" } ) &&
                                                                                                                                                ${ pkgs.coreutils }/bin/echo -n ${ _environment-variable "SECRET" } | while IFS= read -r -n1 ch; do
                                                                                                                                                    if [[ -n ${ _environment-variable "nato[${ _environment-variable "ch" }]" } ]]; then
                                                                                                                                                        ${ pkgs.coreutils }/bin/echo -n ${ _environment-variable "nato[${ _environment-variable "ch" }]" }
                                                                                                                                                    elif [[ -n ${ _environment-variable "alt[${ _environment-variable "ch" }]" } ]]; then
                                                                                                                                                        ${ pkgs.coreutils }/bin/echo -n ${ _environment-variable "alt[${ _environment-variable "ch" }]" }
                                                                                                                                                    elif [[ -n ${ _environment-variable "digits[${ _environment-variable "ch" }]" } ]]; then
                                                                                                                                                        ${ pkgs.coreutils }/bin/echo -n ${ _environment-variable "digits[${ _environment-variable "ch" }]" }
                                                                                                                                                    elif [[ -n ${ _environment-variable "symbols[${ _environment-variable "ch" }]" } ]]; then
                                                                                                                                                        ${ pkgs.coreutils }/bin/echo -n ${ _environment-variable "symbols[${ _environment-variable "ch" }]" }
                                                                                                                                                    else
                                                                                                                                                        printf 'U+%04X' "'${ _environment-variable "ch" }"
                                                                                                                                                    fi &&
                                                                                                                                                    ${ pkgs.coreutils }/bin/echo -n " "
                                                                                                                                                done
                                                                                                                                            echo
                                                                                                                                        '' ;
                                                                                                                                    in
                                                                                                                                        ''
                                                                                                                                            ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                                                                                                makeWrapper ${ pkgs.writeShellScript "expiry" expiry } $out/expiry.bash &&
                                                                                                                                                makeWrapper ${ pkgs.writeShellScript "file" file } $out/file.bash &&
                                                                                                                                                makeWrapper ${ pkgs.writeShellScript "phonetic" phonetic } $out/phonetic.bash
                                                                                                                                        '' ;
                                                                                                                            name = "extensions" ;
                                                                                                                            nativeBuildInputs = [ pkgs.makeWrapper ] ;
                                                                                                                            src = ./. ;
                                                                                                                        } ;
                                                                                                                in
                                                                                                            ''
                                                                                                                ${ timestamp } &&
                                                                                                                    export PASSWORD_STORE_DIR=$( ${ _environment-variable "OUT" }/scripts/repository/${ value.repository } ) &&
                                                                                                                    export PASSWORD_STORE_GPG_OPTS="--homedir $( ${ _environment-variable "OUT" }/scripts/dot-gnupg/${value.dot-gnupg } )" &&
                                                                                                                    export PASSWORD_STORE_ENABLE_EXTENSIONS=true &&
                                                                                                                    export PASSWORD_STORE_EXTENSIONS_DIR=${ extensions } &&
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
                                                                                                            ${ timestamp } &&
                                                                                                                ${ pkgs.jetbrains.idea-community }/bin/idea-community $( ${ _environment-variable "OUT" }/scripts/portfolio )
                                                                                                        '' ;
                                                                                                    in "makeWrapper ${ pkgs.writeShellScript "script" script } $out/bin/studio --set OUT $out" ;
                                                                                            in
                                                                                                ''
                                                                                                    ${ pkgs.coreutils }/bin/mkdir $out &&
                                                                                                        ${ timestamp } &&
                                                                                                        ${ pkgs.coreutils }/bin/mkdir $out/applications &&
                                                                                                        ${ if builtins.length ( builtins.attrNames config.personal.user.career.applications ) > 0 then builtins.concatStringsSep " &&\n\t" ( builtins.concatLists ( builtins.attrValues ( builtins.mapAttrs application config.personal.user.career.applications ) ) ) else "#" } &&
                                                                                                        ${ pkgs.coreutils }/bin/mkdir $out/bin &&
                                                                                                        makeWrapper ${ pkgs.writeShellScript "applications" "${ pkgs.coreutils }/bin/echo ${ _environment-variable "OUT" }/applications" } $out/bin/applications --set OUT $out &&
                                                                                                        ${ pkgs.coreutils }/bin/mkdir $out/share &&
                                                                                                        ${ pkgs.coreutils }/bin/mkdir $out/share/bash-completion &&
                                                                                                        ${ pkgs.coreutils }/bin/mkdir $out/share/bash-completion/completions &&
                                                                                                        ${ pkgs.coreutils }/bin/mkdir $out/share/man &&
                                                                                                        ${ pkgs.coreutils }/bin/mkdir $out/share/man/man1 &&
                                                                                                        ${ if builtins.length ( builtins.attrNames config.personal.user.pass ) > 0 then builtins.concatStringsSep " &&\n\t" ( builtins.concatLists (  builtins.attrValues ( builtins.mapAttrs pass config.personal.user.pass ) ) ) else "#" } &&
                                                                                                        ${ if builtins.length ( builtins.attrNames config.personal.user.firefox ) > 0 then builtins.concatStringsSep " &&\n\t" ( builtins.attrValues ( builtins.mapAttrs firefox config.personal.user.firefox ) ) else "#" } &&
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
                                                                                        pkgs.trashy
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
                                                                        career =
                                                                            {
                                                                                applications =
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
                                                                                                                        birth-date = lib.mkOption { default = null ; type = lib.types.nullOr lib.types.int ; } ;
                                                                                                                        current-time = lib.mkOption { type = lib.types.int ; } ;
                                                                                                                        date-mask = lib.mkOption { default = "%B %Y" ; type = lib.types.str ; } ;
                                                                                                                        experience-target = lib.mkOption { default = 60 * 60 * 24 * 365 * 10 ; type = lib.types.int ; } ;
                                                                                                                        filter = lib.mkOption { default = 60 * 60 * 24 * 31 ; type = lib.types.int ; } ;
                                                                                                                        objective = lib.mkOption { type = lib.types.str ; } ;
                                                                                                                        padding = lib.mkOption { default = 0 ; type = lib.types.int ; } ;
                                                                                                                        preferred = lib.mkOption { default = null ; type = lib.types.nullOr lib.types.str ; } ;
                                                                                                                        recruiter = lib.mkOption { type = lib.types.str ; } ;
                                                                                                                        skills = lib.mkOption { default = [ ] ; type = lib.types.listOf lib.types.str ; } ;
                                                                                                                        social-security-number = lib.mkOption { default = null ; type = lib.types.nullOr lib.types.int ; } ;
                                                                                                                        synopsis =
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
                                                                                                                                                                timestamp = lib.mkOption { type = lib.types.int ; } ;
                                                                                                                                                                notes = lib.mkOption { type = lib.types.str ; } ;
                                                                                                                                                            } ;
                                                                                                                                                    } ;
                                                                                                                                            in lib.types.listOf config ;
                                                                                                                                } ;
                                                                                                                        timestamp = lib.mkOption { type = lib.types.int ; } ;
                                                                                                                    } ;
                                                                                                            } ;
                                                                                                    in lib.types.attrsOf config ;
                                                                                        } ;
                                                                                    education =
                                                                                        lib.mkOption
                                                                                            {
                                                                                                default = [ ] ;
                                                                                                type =
                                                                                                    let
                                                                                                        config =
                                                                                                            lib.types.submodule
                                                                                                                {
                                                                                                                    university = lib.mkOption { type = lib.types.str ; } ;
                                                                                                                    degree = lib.mkOption { type = lib.types.str ; } ;
                                                                                                                    major = lib.mkOption { type = lib.types.str ; } ;
                                                                                                                } ;
                                                                                                        in lib.types.listOf config ;
                                                                                            } ;
                                                                                    experience =
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
                                                                                                                            company = lib.mkOption { type = lib.types.str ; } ;
                                                                                                                            title = lib.mkOption { type = lib.types.str ; } ;
                                                                                                                            from = lib.mkOption { type = lib.types.int ; } ;
                                                                                                                            to = lib.mkOption { type = lib.types.int ; } ;
                                                                                                                            achievements =
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
                                                                                                                                                                    commentary = lib.mkOption { default = null ; type = lib.types.nullOr lib.types.str ; } ;
                                                                                                                                                                    point = lib.mkOption { type = lib.types.str ; } ;
                                                                                                                                                                    skills = lib.mkOption { type = lib.types.listOf lib.types.str ; } ;
                                                                                                                                                                } ;
                                                                                                                                                        } ;
                                                                                                                                                in lib.types.listOf config ;
                                                                                                                                    } ;
                                                                                                                            separation-reason = lib.mkOption { default = null ; type = lib.types.nullOr lib.types.str ; } ;
                                                                                                                        } ;
                                                                                                                } ;
                                                                                                        in lib.types.listOf config ;
                                                                                            } ;
                                                                            } ;
                                                                        current-time = lib.mkOption { type = lib.types.int ; } ;
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
                                                                        firefox =
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
                                                                                                                profile = lib.mkOption { type = lib.types.str ; } ;
                                                                                                            } ;
                                                                                                    } ;
                                                                                            in lib.types.attrsOf config ;
                                                                                } ;
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
                                                                                        token = lib.mkOption { type = lib.types.path ; } ;
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
