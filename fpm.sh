#! /bin/bash
#DESC Package "fpm" tool and its dependencies
SCRIPT_DIR=$(command cd $(dirname $0) && pwd) ; . $SCRIPT_DIR/utils/common.sh

export GEM_NAME=fpm
export GEM_VERSION=1.11.0
export GEM_DESC="fpm helps you build packages quickly and easily (packages like RPM and DEB formats)"
export GEM_URL="http://fpm.readthedocs.io/"
export GEM_DEPS="$JVM_DEPS"

export PKG_HOME="$TOOLS_DIR/$GEM_NAME"
export JRUBY_URL=$(gavc_url org.jruby:jruby-complete:$JRUBY_VERSION)

umask 0022


gem_install() {
    local name version
    name="$1"
    version="$2"

    opts=""
    test -z "$version" || opts="$opts --version $version"

    echo "Installing GEM $name $version"
    ( cd "$BUILD_DIR$PKG_HOME" && java -jar "$JRUBY_JAR" -S gem install -N -i "$GEM_HOME" $opts $name )
}


pkg_tools_build() {
    export JRUBY_JAR="$BUILD_DIR$PKG_HOME/lib/java/jruby-complete.jar"
    export GEM_HOME="$BUILD_DIR$PKG_HOME/lib/ruby"
    export GEM_PATH="$GEM_HOME"

    $DRY mkdir -p "$BUILD_DIR$PKG_HOME"/{bin,lib/java,lib/ruby} \
                  "$BUILD_DIR$TOOLS_DIR/bin" "$BUILD_DIR$BIN_DIR"
    test -e "$JRUBY_JAR" || $DRY wget -q -O "$JRUBY_JAR" "$JRUBY_URL"
    test -e "$GEM_HOME/bin/$GEM_NAME" || $DRY gem_install $GEM_NAME $GEM_VERSION

    export FPM_BIN="$BUILD_DIR$PKG_HOME/bin/$GEM_NAME"
    $DRY_RUN || cat >"$FPM_BIN" <<'.'
#! /usr/bin/env bash
export PKG_HOME=$(cd $(dirname $(readlink -f "$0"))/.. && pwd)
export GEM_NAME=$(basename "$0")
export GEM_HOME="$PKG_HOME/lib/ruby"
export GEM_PATH="$GEM_HOME"
exec java -jar "$PKG_HOME/lib/java/jruby-complete.jar" -S "$GEM_HOME/bin/$GEM_NAME" "$@"
.
    $DRY_RUN || cat >"$BUILD_DIR$TOOLS_DIR/bin/$GEM_NAME" <<'.'
#! /usr/bin/env bash
TOOLS_HOME=$(cd $(dirname $(readlink -f "$0"))/.. && pwd)
GEM_NAME=$(basename "$0")
exec "$TOOLS_HOME/$GEM_NAME/bin/$GEM_NAME" "$@"
.
    $DRY chmod a+rx "$FPM_BIN" "$BUILD_DIR$TOOLS_DIR/bin/$GEM_NAME"
    $DRY ln -nfs "$TOOLS_DIR/bin/$GEM_NAME" "$BUILD_DIR$BIN_DIR"

    $DRY_RUN || ( cd "$BUILD_DIR" && find opt usr \( -type d -o -type l \) -ls )
    $DRY_RUN || ( $FPM_BIN -h | egrep $GEM_NAME.version )
}


pkg_tools_pkg() {
    release=${1:-1}
    pkg_tools_pkg_dir $GEM_NAME $GEM_VERSION $release "$GEM_DESC" "$GEM_URL" \
        -a all $GEM_DEPS opt usr
}


tools_init $0
pkg_tools_main "$@"
tools_done $0
