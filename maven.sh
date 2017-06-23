#! /bin/bash
#DESC Package "priscilla-maven"
SCRIPT_DIR=$(command cd $(dirname $0) && pwd) ; . $SCRIPT_DIR/utils/common.sh

pkg_tools_build() {
    $DRY wget -q -O "$BUILD_DIR/maven.tgz" "$MAVEN_DISTRO"
    $DRY mkdir -p "$BUILD_DIR$(dirname $MAVEN_HOME)" \
                  "$BUILD_DIR$TOOLS_DIR/bin" "$BUILD_DIR$BIN_DIR"
    $DRY pushd "$BUILD_DIR$(dirname $MAVEN_HOME)" >/dev/null
    $DRY tar xfz "$BUILD_DIR/maven.tgz"
    $DRY chmod -R go-w,go+rX "$BUILD_DIR"
    $DRY popd >/dev/null
    $DRY ln -nfs "$MAVEN_HOME/bin/mvn" "$BUILD_DIR$TOOLS_DIR/bin"

    mvn_current="$(sed -re 's/-[0-9.]+$//' <<<$MAVEN_HOME)-current"
    $DRY ln -nfs $(basename $MAVEN_HOME) "$BUILD_DIR$mvn_current"
    $DRY ln -nfs "$mvn_current/bin/mvn" "$BUILD_DIR$TOOLS_DIR/bin"
    $DRY ln -nfs "$TOOLS_DIR/bin/mvn" "$BUILD_DIR$BIN_DIR"

    $DRY_RUN || ( cd "$BUILD_DIR" && find opt usr \( -type d -o -type l \) -ls )
}


pkg_tools_pkg() {
    pkg_tools_pkg_dir maven $MAVEN_VERSION 1 \
        "Apache Maven is a software project management and comprehension tool." \
        "https://maven.apache.org/" \
        -a all $JVM_DEPS opt usr
}

tools_init $0
pkg_tools_main "$@"
tools_done $0
