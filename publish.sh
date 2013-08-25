#! /bin/bash
set -e
rootdir=$(cd $(dirname "$0") && pwd)
workdir="$rootdir/gh-pages"
origin=$(git config --get remote.origin.url)

init() {
    rm -rf $workdir
    git clone -q "$origin" $workdir
    pushd $workdir
    git checkout --orphan gh-pages
    git rm -rf .
    echo >.nojekyll "Sphinx generated"
    git add .nojekyll
    git commit -a -m 'Initialized by paver publish_init'
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

test "$1" == "init" && init || publish

