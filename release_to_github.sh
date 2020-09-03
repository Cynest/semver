#!/bin/bash
#
# Create or edit a github release

set -eo pipefail

releaseinfo=$(pwd)/releaseinfo
rpms=$(pwd)/rpmbuild/RPMS/x86_64

if [[ ! -f ${releaseinfo}/version.env ]]; then
    echo "version.env not found at ${releaseinfo}"
    exit 1;
fi

if [[ ! -f ${releaseinfo}/CHANGELOG ]]; then
    echo "CHANGELOG not found at ${releaseinfo}"
    exit 1;
fi

if [[ ! -d ${rpms} ]]; then
    echo "${rpms} folder not found"
fi

export $(cat ${releaseinfo}/version.env | xargs)

if [[ -n $CIRCLECI ]]; then
    prefix=$1
    if [ -z "$1" ]; then
        prefix=$CIRCLE_PROJECT_REPONAME
    fi

    TAGNAME=$CIRCLE_TAG
    RELEASENAME="${prefix}-${VERSION} ${METADATA/#+/}"
    PRE_RELEASE=""
    if [[ "$TAGNAME" =~ ^.*-rc[0-9]*$ ]]; then
        PRE_RELEASE=--pre-release
    fi

    # Create release or edit existing
    {
        cat ${releaseinfo}/CHANGELOG | github-release release \
        --user $CIRCLE_PROJECT_USERNAME \
        --repo $CIRCLE_PROJECT_REPONAME \
        --tag $TAGNAME \
        --name "$RELEASENAME" \
        $PRE_RELEASE \
        --description - 2> /dev/null
    } ||
    {
        cat ${releaseinfo}/CHANGELOG | github-release edit \
        --user $CIRCLE_PROJECT_USERNAME \
        --repo $CIRCLE_PROJECT_REPONAME \
        --tag $TAGNAME \
        --name "$RELEASENAME" \
        $PRE_RELEASE \
        --description -
    }
    
    # Upload RPMs
    if [ -d ${rpms} ]; then
        RPM7NAME=$(cd ${rpms}; ls -1rt *.el7.x86_64.rpm | tail -n 1)
        RPM7FILE=${rpms}/$RPM7NAME
        github-release upload --user $CIRCLE_PROJECT_USERNAME --repo $CIRCLE_PROJECT_REPONAME --tag $TAGNAME --name $RPM7NAME --file $RPM7FILE
    fi
else
    echo "This script is to be executed from a CircleCI job."
fi
