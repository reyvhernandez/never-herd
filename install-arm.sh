#!/bin/bash

# Author: Reynaldo Hernandez
# Created: Feb 2024
# Description: Auto install and configure multi PHP development environment includes oracle running on docker

OK='\033[0;32m'
FAIL='\033[0;31m'
WARN='\033[0;33m'
NC='\033[0m' # No Color

LOG_FILE="log.txt"
# Clear log file
> "$LOG_FILE"

# Function to log messages
log_message() {
    local message="$1"
    echo "$(date +"%Y-%m-%d %T"): $message" >> "$LOG_FILE"
}

installPackage(){
  local PACKAGE="$1"

  if ! arch -x86_64 brew list --formula | grep -q "$PACKAGE"; then
       echo "$PACKAGE is not installed. Installing..."

       arch -x86_64 brew install "$PACKAGE"
       echo -e "${OK}$PACKAGE installed successfully!${NC}"
   else
       echo -e "${WARN}$PACKAGE is already installed.${NC}"
   fi
}

installPHP(){
    local PHP_VERSION="$1"
        echo "Checking $PHP_VERSION"

        echo "Install and link $PHP_VERSION"
        installPackage "$PHP_VERSION"

        arch -x86_64 brew unlink "php@$(arch -x86_64 php -v | head -n 1 | grep -oE 'PHP ([0-9]+\.[0-9]+)' | cut -d " " -f 2)"
        arch -x86_64 brew unlink "$PHP_VERSION"
        arch -x86_64 brew link --force "$PHP_VERSION"

        echo "Current verion: $PHP_VERSION"
}

installOCI8(){
  local OCI8_VERSION="$1"

   echo "Checking $OCI8_VERSION"

   # Check if destination folder exist
   instantClient="/usr/local/instantclient/"
   # Check if the folder exists
   if [ -d "$instantClient" ]; then
        if [[ $(arch -x86_64 php -m | grep oci8) ]]; then
           echo -e "${WARN}$OCI8_VERSION is already installed.${NC}"
           log_message "$OCI8_VERSION - OK"
        else
           echo "Intall $OCI8_VERSION. Installing..."
           sudo arch -x86_64 pecl install $OCI8_VERSION <<< "instantclient,/usr/local/lib"

           if [[ $(arch -x86_64 php -m | grep oci8) ]]; then
               echo -e "${OK}$OCI8_VERSION installation successful.${NC}"
                log_message "OCI8 for $OCI8_VERSION - OK"
           else
               echo -e "${FAIL} $OCI8_VERSION installation failed.${NC}"
               log_message "$OCI8_VERSION - Fail"
           fi
        fi
   fi
}

installRedis(){
  local REDIS="$1"

   echo "Checking $REDIS"

   # Check if the folder exists
   if [ -d "$instantClient" ]; then
        if [[ $(arch -x86_64 php -m | grep oci8) ]]; then
           echo -e "${WARN}$REDIS is already installed.${NC}"
           log_message "$REDIS - OK"
        else
           echo "Intall $REDIS. Installing..."
           sudo arch -x86_64 pecl install $REDIS

           if [[ $(arch -x86_64 php -m | grep oci8) ]]; then
               echo -e "${OK}$REDIS installation successful.${NC}"
                log_message "OCI8 for $REDIS - OK"
           else
               echo -e "${FAIL} $REDIS installation failed.${NC}"
               log_message "$REDIS - Fail"
           fi
        fi
   fi
}

# Delete temp folder
folder_path="$(pwd)18.1"
# Check if the folder exists
if [ -d "$folder_path" ]; then
    rm -rf "$folder_path"
fi

# Delete temp folder
folder_path="$(pwd)instantclient_18_1"
# Check if the folder exists
if [ -d "$folder_path" ]; then
    rm -rf "$folder_path"
fi

# Check if Rosetta is installed
machine_arch=$(arch -x86_64 uname -m)
if [[ "$machine_arch" == "x86_64" ]]; then
    echo -e "${WARN}Rosetta is already installed.${NC}"
else
    echo "Install Rosetta..."
    /usr/sbin/softwareupdate --install-rosetta
fi

# Check if intel Homebrew is already installed
if ! [ -f /usr/local/bin/brew ]; then
    echo "Intel Homebrew is not installed. Installing..."

    #Install Homebrew
    arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH
    # echo 'eval "$(/usr/local/bin/brew shellenv)"' >> /Users/$(whoami)/.zprofile
    eval "$(/usr/local/bin/brew shellenv)"

    echo -e "${OK}Intel Homebrew installed successfully!${NC}"
    log_message "Intel Homebrew - OK."
else
    eval "$(/usr/local/bin/brew shellenv)"

    echo -e "${WARN}Intel Homebrew is already installed.${NC}"
    log_message "Intel Homebrew - OK."
fi

# Check if destination folder exist
instantClient="/usr/local/instantclient/"
if [ ! -d "$instantClient" ]; then
    echo "Installing OCI8."

    # Unzip Instantclients
    unzip -q instantclient-basic-macos.x64-18.1.0.0.0.zip
    unzip -q instantclient-sdk-macos.x64-18.1.0.0.0-2.zip
    unzip -q instantclient-sqlplus-macos.x64-18.1.0.0.0.zip

    mv instantclient_18_1 18.1

    # Copy InstantClient folder
    sudo mkdir -p "$instantClient"
    sudo cp -r "$(pwd)/18.1 /usr/local/instantclient/"

    if [ $? -eq 0 ]; then
        echo -e "${OK}InstantClient created successfully.${NC}"

        # Make sure /usr/local/include exist
        include="/usr/local/include/"
        # Check if the folder exists
        if [ ! -d "$include" ]; then
            # Create the folder if it doesn't exist
            sudo mkdir -p "$include"
            if [ $? -eq 0 ]; then
                echo -e "${OK}/usr/local/include/ created successfully.${NC}"
            else
                echo -e "${FAIL}/usr/local/include/ failed to create folder.${NC}"
            fi
        else
            echo -e "${WARN}/usr/local/include/ already exists.${NC}"
        fi

        # Make sure /usr/local/bin exist
        bin="/usr/local/bin/"
        # Check if the folder exists
        if [ ! -d "$bin" ]; then
            # Create the folder if it doesn't exist
            sudo mkdir -p "$bin"
            if [ $? -eq 0 ]; then
                echo -e "${OK}/usr/local/bin/ created successfully.${NC}"
            else
                echo -e "${FAIL}/usr/local/bin/ failed to create folder.${NC}"
            fi
        else
            echo -e "${WARN}/usr/local/bin/ already exists.${NC}"
        fi

        # Make sure /usr/local/lib exist
        lib="/usr/local/lib/"
        # Check if the folder exists
        if [ ! -d "$lib" ]; then
            # Create the folder if it doesn't exist
            sudo mkdir -p "$lib"
            if [ $? -eq 0 ]; then
                echo -e "${OK}/usr/local/lib/ created successfully.${NC}"
            else
                echo -e "${FAIL}/usr/local/lib/ failed to create folder.${NC}"
            fi
        else
            echo -e "${WARN}/usr/local/lib/ already exists.${NC}"
        fi

        # Create symblink
        echo "Creating symblink..."
        sudo ln -sf /usr/local/instantclient/18.1/sdk/include/*.h /usr/local/include/
        sudo ln -sf /usr/local/instantclient/18.1/sqlplus /usr/local/bin/
        sudo ln -sf /usr/local/instantclient/18.1/*.dylib /usr/local/lib/
        sudo ln -sf /usr/local/instantclient/18.1/*.dylib.18.1 /usr/local/lib/
        sudo ln -sf /usr/local/lib/libclntsh.dylib.18.1 /usr/local/lib/libclntsh.dylib
    else
        echo -e "${FAIL}InstantClient failed to create folder.${NC}"
    fi
else
    echo -e "${WARN}InstantClient already exists.${NC}"
fi

# Multi PHP
# Install PHP 8.1 and corresponding OCI8
echo "Installing PHP..."

# user intel homebrew
eval "$(/usr/local/bin/brew shellenv)"
arch -x86_64 brew tap shivammathur/homebrew-php

installPHP "php@7.0" && installOCI8 "oci8-2.2.0" && installRedis "redis"
installPHP "php@7.1" && installOCI8 "oci8-2.2.0" && installRedis "redis"
installPHP "php@7.2" && installOCI8 "oci8-2.2.0" && installRedis "redis"
installPHP "php@7.3" && installOCI8 "oci8-2.2.0" && installRedis "redis"
installPHP "php@7.4" && installOCI8 "oci8-2.2.0" && installRedis "redis"
#installPHP "php@8.0" && installOCI8 "oci8-3.0.1" && installRedis "redis"
installPHP "php@8.1" && installOCI8 "oci8-3.2.1" && installRedis "redis"
installPHP "php@8.2" && installOCI8 "oci8" && installRedis "redis"
installPHP "php" && installOCI8 "oci8" && installRedis "redis"

# Check if Composer is already installed
installPackage "composer"

# Check if Composer path already exists in .zprofile
if ! grep -q '.composer/vendor/bin' ~/.zprofile; then
    # Add Composer to PATH
    # echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.zprofile

    # add alias
    cat "$(pwd)/zprofile" >> ~/.zprofile

    source "/Users/$(whoami)/.zprofile"

    echo -e "${OK}Composer added to PATH successfully!${NC}"
else
    echo -e "${WARN}Composer path already exists in ~/.zprofile.${NC}"
fi

installPackage "nginx"
installPackage "dnsmasq"
installPackage "redis"

#Install and configure valet
file_path="$HOME/.composer/vendor/bin/valet"
if [ -e "$file_path" ]; then
    echo -e "${WARN}Valet is already installed.${NC}"
else
    # Install Valet using Composer
    echo "Valet is not installed. Installing..."
    
    composer global require laravel/valet

    valet install
fi

  # Oracle and Docker
  installPackage "git"
  installPackage "docker"
  installPackage "nvm"

  # intall pyenv python version manager
  installPackage "pyenv"
  if ! arch -x86_64 brew list --formula | grep -q pyenv; then
    arch -x86_64 pyenv install 2.7.18
    arch -x86_64 pyenv global 2.7.18
    # configure NVM
    if ! grep -q 'PATH=$(pyenv root)/shims:$PATH' ~/.zprofile; then
      echo 'PATH=$(pyenv root)/shims:$PATH' >> ~/.zprofile
    fi
  fi

  # configure NVM
  if ! grep -q 'export NVM_DIR' ~/.zprofile; then
    mkdir ~/.nvm
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zprofile

    echo '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm' >> ~/.zprofile
    echo '[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion' >> ~/.zprofile
  fi

 # ====================
 # Start Apple Homebrew
 # Check if Apple Homebrew is already installed
 if ! [ -f /opt/homebrew/bin/brew ]; then
     echo "Apple Homebrew is not installed. Installing..."

     #Install Homebrew
     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

     # Add Apple Homebrew to PATH
     # echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$(whoami)/.zprofile
     eval "$(/opt/homebrew/bin/brew shellenv)"

     echo -e "${OK}Apple Homebrew installed successfully!${NC}"
     log_message "Apple Homebrew - OK."
 else
     echo -e "${WARN}Apple Homebrew is already installed.${NC}"
     log_message "Apple Homebrew - OK."
 fi

  eval "$(/opt/homebrew/bin/brew shellenv)"
  # Check if Colima is already installed
  if ! brew list --formula | grep -q "colima"; then
      echo "Colima is not installed. Installing..."

      eval "$(/opt/homebrew/bin/brew shellenv)"

      # Install colima using Homebrew
      brew install colima

      echo -e "${OK}Colima installed successfully!${NC}"

      # Run Colima
      colima start --arch x86_64 --memory 4 --cpu 2

      CONTAINER_NAME="oracle-xe"
      #Create Docker or Oracle
      docker run -d --name $CONTAINER_NAME -p 1521:1521 -e ORACLE_PASSWORD=oracle gvenzl/oracle-xe

      # Check if the container is running
      if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
          echo -e "${OK}Oracle installed and running.${NC}"
          log_message "Oracle - OK"
      else
          echo -e "${FAIL}Oracle installation failed.${NC}"
          log_message "Oracle - FAIL"
      fi
  else
      echo -e "${WARN}Colima is already installed.${NC}"

      eval "$(/opt/homebrew/bin/brew shellenv)"

      echo "Checking Oracle."
      CONTAINER_NAME="oracle-xe"

      colima start
      docker start "$CONTAINER_NAME"
      # Check if the container is running
      if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
          echo -e "${OK}Oracle installed and running.${NC}"
          log_message "Oracle - OK"
      else
          echo -e "${FAIL}Oracle installation failed.${NC}"
          log_message "Oracle - Fail"
      fi
  fi
 # End Apple Homebrew

echo -e "${OK}Installation complete.${NC}"
