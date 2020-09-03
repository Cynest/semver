#!/bin/bash

# Versions in a go.sum file can appear in the following formats
# a) Semver tag                     v1.4.0
# b) Semver tag +incompatible       v1.4.0+incompatible
# c) Semver tag-date-commithash     v0.0.0-20171018192106-9c78ae89daeb

# This script aims to account for these three possibilities and return a valid git reference to
# locked version of the dependency provided.
# In the case of examples a and b, this will return v1.4.0
# In the case of example c, this will return 9c78ae89daeb

# If a go installation is available, `go list -m` will attempt to be used. This requires go1.11 or newer.
# Otherwise, the script falls back on using awk to parse the go.sum file.
usage() {
    echo "Usage: $0 [go.sum file] [dependency]"
    echo "      Prints out a valid git reference from the provided go.sum file for a dependency."
    echo "      If no dependency is provided, versions for all dependencies will be printed in the form:"
    echo "          package version"
}

# Argument 1 is the version string to parse
parse_version() {
    # cut the string by `+` for example b and take the first part of the cut string
    local v=$(cut -d'+' -f1 <<< $1)
    # cut the string by `-` and check if we have a specific hash in our version string
    local vhash=$(cut -d'-' -f3 <<< $v)
    if [ ! -z $vhash ]; then
        v=$vhash
    fi
    
    if [ -z $v ]; then
        return 1;
    fi
    
    echo $v
    return 0;
}

# Argument 1 is the dependency to get the version line for. If not provided all dependencies will be returned
get_version_line() {
    local d=$1
    if [ ! -z $HASGO ]; then
        [ -z $d ] && d="all"
        cd $SUMFILEDIR; go list -m $d
    fi

    [ ! -z $d ] && depmatch='$1==dep &&' || depmatch=""
    awkline="{sub(/\/go\.mod$/, \"\", \$2)}; $depmatch !seen[\$1]++ {print \$1, \$2}"
    awk -v OFS=' ' -v dep="$DEP" "$awkline" $SUMFILE
}

if [ -z $1 ]; then
    usage
    exit 1
fi

SUMFILE=$1
DEP=$2
HASGO=$(which go 2> /dev/null)
SUMFILEDIR=$(dirname "${SUMFILE}")

get_version_line $DEP | \
    while 
        IFS=' ' read dep version 
    do
        v=$(parse_version $version)
        retval=$?
        [ $retval -gt 0 ] && continue
        [ ! -z $DEP ] && echo $v || echo $dep $v
    done 
