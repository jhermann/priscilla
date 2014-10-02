#! /bin/bash
#
# Initial build machine setup; this script installs necessary build
# dependencies (on Debian-like distros) and creates a "pyenv" user
# where the "pyenv" command is used to create the package contents.
#
set -e

pyenv_uid=${PYENV_UID:-3141}
pyenv_home=${PYENV_HOME:-/opt/pyenv}

test $(id -u) -eq 0 || { echo "Setup must be done as root!"; exit 1; }

# Platform stuff
case $(lsb_release -cs) in
    squeeze)    readline=5; libdb=4.8 ;;
    precise)    readline=6; libdb=5.1 ;;
    *)          readline=6; libdb=5.1 ;;
esac

# Install build-depends
apt-get install python-dev build-essential git \
    libbz2-dev libexpat1-dev libgdbm-dev libncursesw5-dev \
    libreadline$readline-dev libdb$libdb-dev \
    libsqlite3-dev libssl-dev libtar-dev libtinfo-dev libz-dev libzip-dev

# Create pydev user (needed to build the packages, but not when using them)
grep ^pyenv: /etc/passwd >/dev/null || \
    adduser --home $pyenv_home --shell /bin/bash \
        --firstuid $pyenv_uid --lastuid $(( $pyenv_uid + 666 )) --disabled-password \
        --gecos "pyenv build user" pyenv

# Fill pyenv home with initial content
mkdir -p $pyenv_home/src
cp -p $(dirname $0)/*.sh $pyenv_home/src
chown -R $(stat --format '%U.%G' $pyenv_home) $pyenv_home/src

# Make sure the account works
su - pyenv
