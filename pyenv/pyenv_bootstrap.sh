#! /bin/bash
#
# pyenv installation
#
set -e

: ${PYENV_TAG:=v20140924}
: ${PYENV_SRC:=https://github.com/yyuu/pyenv.git}
: ${SNAKES:=2.6.9 2.7.8 3.3.5} # add versions in SORTED order
: ${VENV_SRC:=https://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.9.1.tar.gz}

fail() { # fail with error message on stderr and exit code 1
    echo >&2 "ERROR:" "$@"
    exit 1
}

test $(id -un) == "pyenv" || fail "Script must be run as the 'pyenv' user!"

cd
PYENV_HOME=$(pwd)
test -x .pyenv/bin/pyenv && ( cd .pyenv; git pull --ff-only; ) || git clone "$PYENV_SRC" .pyenv
( cd .pyenv; git checkout "$PYENV_TAG"; )
export PATH="$HOME/.pyenv/bin:$PATH"

mkdir -p bin lib tmp
rm bin/* 2>/dev/null || :
rm -rf lib/virtualenv 2>/dev/null || :

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
