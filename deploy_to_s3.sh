#!/bin/bash
#
# Deploy files to S3

set -eo pipefail

rpms=$(pwd)/rpmbuild/RPMS/x86_64

if [[ ! -d ${rpms} ]]; then
    echo "${rpms} folder not found"
    exit 1;
fi

if [[ -n $CIRCLECI ]]; then
    # Deploy to S3
    if [ -d ${rpms} ]; then
        RPM7NAME=$(cd ${rpms}; ls -1rt *.el7.x86_64.rpm | tail -n 1)
        aws s3 cp ${rpms}/$RPM7NAME s3://spo-fusion-repo/fusion7-test/$RPM7NAME
    fi
else
    echo "This script is to be executed from a CircleCI job."
fi
