resetValet(){
    arm brew unlink php && arm brew link --force php
    composer self-update --2
    composer global remove laravel/valet
    rm -rf ~/.config/valet
    composer global require laravel/valet
    valet install
}
reinstallValet(){
    local PHP_VERSION="$1"
    local VALET_VERSION="$2"

    echo "This will re-install valet then will re-link if you have env file. You may need to re-link/re-run park."

    COMPOSER_VERSION="2"
    if [[ "$PHP_VERSION" = "php@7.0" || "$PHP_VERSION" = "php@7.1" || "$PHP_VERSION" = "php@7.2" || "$PHP_VERSION" = "php@7.3" ]]; then
        COMPOSER_VERSION="1"
    fi

    arm valet stop
    arm valet uninstall
    arm valet unsecure --all
    rm -rf ~/.config/valet
    composer global remove laravel/valet
    composer self-update --"$COMPOSER_VERSION"
    arm brew unlink "php@$(arm php -v | head -n 1 | grep -oE 'PHP ([0-9]+\.[0-9]+)' | cut -d " " -f 2)"
    arm brew unlink "$PHP_VERSION" && arm brew link --force "$PHP_VERSION"
    arm brew link --overwrite "$PHP_VERSION"
    composer global require "$VALET_VERSION"
    echo "Running valet install ..."
    arm valet install
    composer global update
    echo "Done switching to $PHP_VERSION"
}

reconfigureValet(){
    local PHP_VERSION="$1"
    local COMPOSER_VERSION="$2"

    composer self-update --"$COMPOSER_VERSION"
    echo "Composer Verssion: $COMPOSER_VERSION"
    echo "Running valet use $PHP_VERSION --force ..."
    arm valet use "$PHP_VERSION" --force
    composer global update
    echo "Done switching to $PHP_VERSION"
}

valetLatest(){
    local PHP_VERSION="$1"

    echo "Switching to $PHP_VERSION"

    COMPOSER_VERSION="2"
    if [[ "$PHP_VERSION" = "php@7.0" || "$PHP_VERSION" = "php@7.1" || "$PHP_VERSION" = "php@7.2" || "$PHP_VERSION" = "php@7.3" ]]; then
        COMPOSER_VERSION="1"
    fi

    valetVersion=$(valet -V | head -n 1 | grep -oE 'Valet ([0-9]+\.[0-9]+)' | cut -d " " -f 2)
    if [ "$valetVersion" = "3.3" ]; then
        reinstallValet "$PHP_VERSION" "laravel/valet"
    else
        reconfigureValet "$PHP_VERSION" "$COMPOSER_VERSION"
    fi
}

valet3x(){
    local PHP_VERSION="$1"

    COMPOSER_VERSION="2"
    if [[ "$PHP_VERSION" = "php@7.0" || "$PHP_VERSION" = "php@7.1" || "$PHP_VERSION" = "php@7.2" || "$PHP_VERSION" = "php@7.3" ]]; then
        COMPOSER_VERSION="1"
    fi

    echo "Switching to $PHP_VERSION"
    valetVersion=$(valet -V | head -n 1 | grep -oE 'Valet ([0-9]+\.[0-9]+)' | cut -d " " -f 2)
    if [ "$valetVersion" = "3.3" ]; then
        reconfigureValet "$PHP_VERSION" "$COMPOSER_VERSION"
    else
        reinstallValet "$PHP_VERSION" "laravel/valet:^3"
    fi
}

valetLink() {
    # Check if the environment variable AUTO_LINK_VALET is set to true
    if [[ "$AUTO_LINK_VALET" == "true" ]]; then
        # Check if the .env file exists
        if [[ -f ".env" ]]; then
            echo "Environment variable AUTO_LINK_VALET is set. Running valet link..."
            valet link
        else
            echo "No .env file found. Skipping valet link."
        fi
    else
        echo "AUTO_LINK_VALET is not set or false. Skipping valet link."
    fi
}

php83() {
    valetLatest "php"
    valetLink
    valet links
}

php82() {
    valet3x "php@8.2"
    valetLink
    valet links
}

php81() {
    valet3x "php@8.1"
    valetLink
    valet links
}

php74() {
    valet3x "php@7.4"
    valetLink
    valet links
}

php73() {
    valet3x "php@7.3"
}

php72() {
    valet3x "php@7.2"
}

php71() {
    valet3x "php@7.1"
}

php70() {
    valet3x "php@7.0"
}

alias usereset='resetValet'
alias usephp83='php83'
alias usephp82='php82'
alias usephp81='php81'
alias usephp74='php74'
alias usephp73='php73'
alias usephp72='php72'
alias usephp71='php71'
alias usephp70='php70'
# multi php

arm() {
  arch -x86_64 $@
}

# Switch to ARM x86_64 - Intel Brew
intel-brew() {
  eval "$(/usr/local/bin/brew shellenv)"
}

# Switch to ARM - Apple M1 Brew
apple-brew() {
  export PATH=$PATH:/opt/homebrew/bin
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

# Default Brew Intel Compatibility
eval "$(/usr/local/bin/brew shellenv)"

# Default Brew ARM
#export PATH=$PATH:/opt/homebrew/bin
#eval "$(/opt/homebrew/bin/brew shellenv)"

#composer
export PATH=${PATH}:~/.composer/vendor/bin

# oracle
alias ora="apple-brew && colima start --arch x86_64 --cpu 2 --memory 4 && docker start oracle-xe"

# valet
export AUTO_LINK_VALET=true

