#! /bin/bash
set -e
rootdir=$(cd $(dirname "$0") && pwd)
workdir="$rootdir/gh-pages"
origin=$(git config --get "remote.origin.url")
user_name=$(git config --get "user.name")
user_email=$(git config --get "user.email")

fail() {
    echo "FATAL ERROR:" "$@"
    exit 1
}

set_user() {
    git config --local --replace-all "user.name" "$user_name"
    git config --local --replace-all "user.email" "$user_email"
}

init() {
    rm -rf $workdir
    git clone -q "$origin" $workdir
    pushd $workdir
    git checkout --orphan gh-pages
    git rm -rf .
    set_user
    echo >.nojekyll "Sphinx generated"
    git add .nojekyll
    git commit -a -m 'Initialized by publish init'
    git push origin gh-pages
    popd
}

publish() {
    set -x
    rm -rf $workdir
    mkdir $workdir
    htmldir="$rootdir/build/html"
    test ! -d "$htmldir" || rm -rf "$htmldir"

    doc/Makefile html

    pushd $workdir

    git init
    set_user
    git remote add -t gh-pages -f origin "$origin"
    git checkout gh-pages

    cp -frpl "$htmldir"/{,.}??* .
    git add .

    # Push it!
    git status
    git commit -m 'Docs published'
    git push origin gh-pages
    git status

    popd
}

which sphinx-build >/dev/null || fail "'sphinx-build' not found, need to activate a virtualenv?"
test "$1" == "init" && init || publish
