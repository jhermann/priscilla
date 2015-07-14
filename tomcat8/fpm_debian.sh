#! /bin/bash
#
# Apache Tomcat8 Debian packaging
#
set -e
umask 0022

name="${PKGNAME:-opt-tomcat8}"
version=8.0.24
iteration=1
description="Open-source Java web server and servlet container"
url="http://tomcat.apache.org/tomcat-8.0-doc/"
mirror="http://www.webhostingjams.com/mirror"
dist_url="$mirror/apache/tomcat/tomcat-8/v$version/bin/apache-tomcat-$version.tar.gz"

fail() { # fail with error message on stderr and exit code 1
    echo >&2 "ERROR:" "$@"
    exit 1
}

which fpm >/dev/null || fail "You need to install fpm!"
test -n "$DEBFULLNAME" || fail "You must define the DEBFULLNAME envvar"
test -n "$DEBEMAIL" || fail "You must define the DEBEMAIL envvar"

# Remove redundant build stuff
rm -rf ./tmp/* 2>/dev/null || :

mkdir -p tmp/opt/tomcat
tarball="apache-tomcat-$version.tar.gz"
test -f "$tarball" || curl -Lo "$tarball" "$dist_url"
echo -n "Extracting tarball"
tar -xvz -C tmp/opt/tomcat --strip-components=1 -f "$tarball" | tr -dc \\n | tr \\n .
echo
rm -rf tmp/opt/tomcat/webapps/{docs,examples,host-manager,ROOT} || :

echo "Packaging $name..."
( cd tmp && fpm -s dir -t deb -a all \
    -n "$name" -v $version --iteration $iteration \
    --category "httpd" --deb-user root --deb-group root \
    -m "\"$DEBFULLNAME\" <$DEBEMAIL>" \
    --license "Apache 2.0" --vendor "Priscilla" \
    --description  "$description" \
    --url "${url}" \
    --workdir "." -x ".git" opt && mv *.deb .. )

for pkg in $name*.deb; do
    echo "~~~" "$pkg"
    #dpkg-deb -c "$pkg"
    dpkg-deb -I "$pkg"
done
