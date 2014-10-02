#! /bin/bash
#
# pyenv Debian packaging
#
set -e

name="${PYENV_PKGNAME:-opt-pyenv}"

fail() { # fail with error message on stderr and exit code 1
    echo >&2 "ERROR:" "$@"
    exit 1
}

which fpm >/dev/null || fail "You need to install fpm!"
test $(id -un) == "pyenv" || fail "Script must be run as 'pyenv' user!"

cd
version=$(cd .pyenv && git describe --tag); version=${version#v}
iteration=$(grep Revision: $(dirname $0)/pyenv_bootstrap.sh | tr -dc 0-9)-$(lsb_release -cs)
description="Simple Python version management"
url="https://github.com/jhermann/priscilla/tree/master/pyenv"

test -n "$DEBFULLNAME" || fail "You must define the DEBFULLNAME envvar"
test -n "$DEBEMAIL" || fail "You must define the DEBEMAIL envvar"

rm -rf tmp/* 2>/dev/null || :
mkdir -p dist tmp
rm *.deb dist/$name*.deb 2>/dev/null || :
fpm -s dir -t deb \
    -n "$name" -v $version --iteration $iteration \
    --category "tools" --deb-user root --deb-group root \
    -m "\"$DEBFULLNAME\" <$DEBEMAIL>" \
    --license "Apache2/MIT/PSFL" --vendor "Priscilla" \
    --description  "$description" \
    --url "${url:-https://github.com/yyuu/pyenv}" \
    --workdir "tmp" -x ".git" $HOME/.pyenv $HOME/bin  # $HOME/*.sh
mv *.deb dist

for pkg in dist/$name*.deb; do
    echo "~~~" "$pkg"
    #dpkg-deb -c "$pkg"
    dpkg-deb -I "$pkg"
done
