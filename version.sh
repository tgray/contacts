#!/bin/sh -

if [[ ! -d ".git" ]]; then
    # version=`cat VERSION | grep version | awk '{print $2}'`
    commit=`cat VERSION | grep commit | awk '{print $2}'`
else
    echo "Getting information from git"

    describe=`git describe --long --dirty`
    if [ -n "$describe" ]
    then
        version=`echo $describe | cut -d '-' -f1`
        delta=`echo $describe | cut -d '-' -f2`
        commit=`echo $describe | cut -d '-' -f3 | cut -c2-`
        dirty=`echo $describe | cut -d '-' -f4`
    else
        version="0.0.0"
        commit="None"
        delta=""
        dirty=""
    fi
fi

if [ -n "$dirty" ]
then
    commit="${commit}-d"
fi

if [ -f "$1" ]
then
    echo "Modifying $1"
	# sed -i .bak -E "s/^(__version__ = )\"([^\"]*)\"/\1\"${version}\"/" $1 || exit 3
	sed -i .bak -E "s/\"version\": \"([^\"]+)\"/\"version\": \"${version}\"/" $1 || exit 3
	sed -i .bak -E "s/\"build\": \"([^\"]+)\"/\"build\": \"${commit}\"/" $1 || exit 3
    rm $1.bak
elif [ -z "$1" ]
then
    echo "Must supply a file to modify"
    exit 1
else
    echo "File $1 does not exist"
    exit 2
fi
