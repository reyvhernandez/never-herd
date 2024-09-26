# Laravel Never Herd
Auto setup and install your development environment for Laravel.

## Included Apps
* PHP 8.3, 8.2, 8.1, 7.4, 7.3, 7.2, 7.1, 7.0
* Composer
* Valet
* OCI8 are installed in all PHP versions
* Redis are installed in all PHP versions
* Colima and Docker with Oracle is installed and configured
* NVM - Node version manager
* PyEnv - Python version manager
* Using PyEnv set global python version to 2.7.18

## Usage
### Switch PHP version
* ```usephp83```
* ```usephp82``` - recommended version to use
* ```usephp81``` - recommended version to use
* ```usephp74``` - recommended version to use
* ```usephp73```
* ```usephp72```
* ```usephp71```
* ```usephp70```
* ```usereset``` - when getting error when switching, you can try this command to reset to version PHP 8.3, and retry switching to your desired version
* You may need to re-run ```arm valet park or link``` after switching from not recommended PHP version

### switch node version
* ```nvm install {node_version}``` - install node version for more info visit https://github.com/nvm-sh/nvm

### switch python version
* ```arm pyenv install 2.7.18``` - install python version for more info visit
* ```arm pyenv global 2.7.18``` - set python version for more info visit

### Running Oracle
Run on terminal:
* ```ora``` - this will run colima and docker with oracle

### Check Oracle if running
Run on **NEW** terminal:
* ```apple-bew``` - switch to apple-bew
* ```colima start --arch x86_64 --cpu 2 --memory 4``` - run if colima is not running
* ```docker ps``` - check if oracle is running

### create oracle user
```
CREATE USER {user} IDENTIFIED BY {password} QUOTA UNLIMITED ON USERS;
GRANT CONNECT, RESOURCE TO {user};
```

### sample .env
```
#DB_CONNECTION=oracle
#DB_HOST=localhost
#DB_PORT=1521
#DB_DATABASE=xe
#DB_USERNAME="user"
#DB_PASSWORD="password"
```

### Notice
If you are switching from PHP 8.3 to PHP 7.0 it is not aviseable to install global composer package execpt valet as this will break when switching your version.

### Valet Linking
If you have env in your project, after successfully switching to your desired PHP version, this will automatically re-link your project.
The PHP version that have auto re-link are the ff:
* PHP 8.3
* PHP 8.2
* PHP 8.1
* PHP 7.4