#! /bin/bash
#
# pyenv installation
#
set -e
umask 0022

# Set defaults for various options, if not already provided in the environment
: ${PYENV_TAG:=v20160726}
: ${PYENV_SRC:=https://github.com/yyuu/pyenv.git}
: ${SNAKES:=2.6.9 2.7.12 3.3.6 3.4.5 3.5.2} # add versions in SORTED order
: ${VENV_SRC:=https://pypi.python.org/packages/5c/79/5dae7494b9f5ed061cff9a8ab8d6e1f02db352f3facf907d9eb614fb80e9/virtualenv-15.0.2.tar.gz}


fail() { # fail with error message on stderr and exit code 1
    echo >&2 "ERROR:" "$@"
    exit 1
}

test $(id -un) == "pyenv" || fail "Script must be run as the 'pyenv' user!"

cd
mkdir -p bin lib tmp
rm bin/* 2>/dev/null || :
rm -rf .pyenv 2>/dev/null || :
rm -rf lib/virtualenv 2>/dev/null || :

PYENV_HOME=$(pwd)
test -x .pyenv/bin/pyenv && ( cd .pyenv; git pull --ff-only; ) || git clone "$PYENV_SRC" .pyenv
( cd .pyenv; git checkout "$PYENV_TAG"; )
export PATH="$HOME/.pyenv/bin:$PATH"

test -f tmp/virtualenv.tgz || wget --no-check-certificate -O tmp/virtualenv.tgz "$VENV_SRC"
( cd lib && tar xzf ../tmp/virtualenv.tgz && mv virtualenv-[0-9]* virtualenv ) || \
    ( mv tmp/virtualenv.tgz tmp/virtualenv.tgz,broken && echo "virtualenv: broken tarball?" && false )

for version in $SNAKES; do
    # install Python
    test -x ~/.pyenv/versions/$version/bin/python || .pyenv/bin/pyenv install $version

    # install virtualenv
    test -x ~/.pyenv/versions/$version/bin/virtualenv || \
       ( cd lib/virtualenv && ~/.pyenv/versions/$version/bin/python setup.py install )

    # link versioned tools
    for tool in .pyenv/versions/$version/bin/*${version%.*}*; do
        egrep -v "bin/(pip|easy_install)" <<<$tool >/dev/null || continue
        tool=$(basename $tool)
        ln -nfs ../.pyenv/versions/$version/bin/$tool bin/$tool
        ln -nfs $tool bin/$(sed -re "s/${version%.*}/${version%.*.*}/" <<<$tool)
    done

    ln -nfs ../.pyenv/versions/$version/bin/python bin/python${version%.*}
    ln -nfs python${version%.*} bin/python${version%.*.*}
done
.pyenv/bin/pyenv rehash

#echo '# activate pyenv, source this file in ~/.bash_profile or similar' >~/activate.sh
#echo 'export PATH="'"$PYENV_HOME"'/.pyenv/bin:$PATH"' >>~/activate.sh
#echo 'eval "$(pyenv init -)"' >>~/activate.sh
