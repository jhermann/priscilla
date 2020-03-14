# NOT an executable script, needs to be sourced...
#DESC Common definitions for all setup scripts.

# Show traces?
DEBUG=true

# Just log mutating commands instead of executing them?
DRY_RUN=false

# Fail early and hard
set -e

# Load global settings
. "$SCRIPT_DIR/utils/settings.sh"

# Ensure CWD is the script tree root
SCRIPT_PWD="$(pwd)"
command cd "$SCRIPT_DIR"


#
# Manifest constants
#
ESC=$(echo -en \\0033)
BOLD="$ESC[1m"
OFF="$ESC[0m"

$DRY_RUN && DRY="_dry_run" || DRY=""


#
# Internal helpers
#
_dry_run() {
    bold "DRY RUN:" "$@"
}


#
# Logging / diagnostics
#
bold() {
    echo "$BOLD""$@""$OFF"
}

banner() {
    ch="$1"; shift
    for i in $(seq 78); do echo -n "$ch"; done; echo
    echo "$ch $BOLD""$@""$OFF @ $(hostname)"
    for i in $(seq 78); do echo -n "$ch"; done; echo
    if test "$ch" = "="; then export _profile_banner="$@"; fi
}

trace() {
    $DEBUG && echo "TRACE: ""$@" || :
}

info() {
    echo "INFO:" "$@"
}

warn() {
    echo "$BOLD""WARN:" "$@""$OFF"
}

fail() {
    trap ERR
    echo "$BOLD""FATAL ERROR:" "$@""$OFF"
    exit 1
}

error_trap() {
    RC=$?
    trap ERR
    echo "$BOLD""FAILURE: Premature end of build script with RC=$RC, read the log!""$OFF"
    echo
    echo
    exit $RC
}

tools_init() {
    _mod_startup=$(timer)
    script="$(basename $1)"
    banner "~" "Build ${script%%.sh}"
}

tools_done() {
    script="$(basename $1)"
    bold "DONE: Build ${script%%.sh} took $(timer $_mod_startup) @ $(hostname)"
    echo
}


#
# Other helper functions
#
timer() {
    # Elapsed time.
    #
    #   t=$(timer)
    #   ... # do something
    #   printf 'Elapsed time: %s\n' $(timer $t)
    #      ===> Elapsed time: 0:01:12
    #
    # If called with no arguments a new timer is returned.
    # If called with arguments the first is used as a timer
    # value and the elapsed time is returned in the form HH:MM:SS.
    if [[ $# -eq 0 ]]; then
        echo $(date '+%s')
    else
        local  stime=$1
        etime=$(date '+%s')

        if [[ -z "$stime" ]]; then stime=$etime; fi

        dt=$((etime - stime))
        ds=$((dt % 60))
        dm=$(((dt / 60) % 60))
        dh=$((dt / 3600))
        printf '%d:%02d:%02d' $dh $dm $ds
    fi
}


# Packaging mainloop
pkg_tools_main() {
    # the calling script must define the pkg_tools_build and pkg_tools_pkg functions
    BUILD_DIR="$SCRIPT_PWD/build/opt_tools_$(basename ${0%.sh})"
    test -z "$BUILD_ID" || BUILD_DIR="$WORKSPACE/build"
    mkdir -p "$BUILD_DIR"
    export BUILD_DIR=$(cd "$BUILD_DIR" && pwd)
    #echo $BUILD_DIR

    action="$1"; shift
    case "$action" in
        build)
            pkg_tools_build
            ;;
        pkg)
            pkg_tools_build
            pkg_tools_pkg "$@"
            ;;
        *)
            echo "usage: call this script with the 'build' or 'pkg' action (pkg includes a build)"
            exit 1
            ;;
    esac
}


# Build a tool package from a directory tree
pkg_tools_pkg_dir() {
    local name version iteration description url
    name="$1"; shift
    version="$1"; shift
    iteration="$1"; shift
    description="$1"; shift
    url="$1"; shift
    # other args are passed to fpm

    # --iteration 1-$(lsb_release -cs)
    $DRY mkdir -p "$BUILD_DIR/tmp"
    $DRY rm "$BUILD_DIR"/opt-tools-$name*.deb 2>/dev/null || :
    ( cd "$BUILD_DIR" && set -x && $DRY $FPM_BIN -s dir -t deb \
        -n "opt-tools-$name" -v $version --iteration $iteration \
        --category "tools" --deb-user root --deb-group root \
        -m "\"$DEBFULLNAME\" <$DEBEMAIL>" \
        --license "See contained license, or homepage" --vendor "github.com/jhermann/priscilla" \
        --description  "$description" \
        --url "${url:-https://github.com/jhermann/priscilla}" \
        --workdir "$BUILD_DIR/tmp" "$@" )

    # Provide pkg info for *.deb
    if which dpkg-deb >/dev/null 2>&1; then
        for pkg in "$BUILD_DIR"/opt-tools-$name*.deb; do
            echo "~~~" "$pkg"
            #dpkg-deb -c "$pkg"
            dpkg-deb -I "$pkg"
        done
    fi
}


# Maven artifact URLs
gavc_url() {
    local gavc g a v c
    gavc="$1"
    g=$(cut -d: -f1 <<<"$gavc")
    a=$(cut -d: -f2 <<<"$gavc")
    v=$(cut -d: -f3 <<<"$gavc")
    c=$(cut -d: -f4 <<<"$gavc")
    echo "$MAVEN_REPO/${g//.//}/$a/$v/$a-$v.${c:-jar}"
}


# Register failure TRAP and start timer
trap error_trap ERR
_profile_startup=$(timer)
