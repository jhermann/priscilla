# NOT an executable script, needs to be sourced...
#DESC Global settings like versions and URLs

# Versions
JRUBY_VERSION=1.7.27
MAVEN_VERSION=3.5.0
ANT_VERSION=1.9.3

# Packaging
TOOLS_DIR=/opt/tools
BIN_DIR=/usr/bin
FPM_BIN=fpm
test -n "$DEBFULLNAME" || export DEBFULLNAME="Jürgen Hermann"
test -n "$DEBEMAIL" || export DEBEMAIL=jh@web.de

# Java
JVM_DEPS='-d oracle-java8-jre|oracle-java8-installer|java8-runtime-headless'

# Maven
MAVEN_REPO="https://repo1.maven.org/maven2"
MAVEN_DISTRO="$MAVEN_REPO/org/apache/maven/apache-maven/$MAVEN_VERSION/apache-maven-$MAVEN_VERSION-bin.tar.gz"
MAVEN_HOME="$TOOLS_DIR/apache-maven-$MAVEN_VERSION"
