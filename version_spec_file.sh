#!/bin/bash
#
# This script takes a RPM spect file and creates a spec file with version

set -eo pipefail

# Check for a .spect file as input.
if [[ $# -lt 1 ]] || [ "${1##*.}" != "spect" ]; then
    echo "${1} is not a spec template .spect file"
    exit 1;
fi

if [[ ! -f ${2}/version.env ]]; then
    echo "version.env not found at ${2}"
    exit 1;
fi

SPEC_TEMPLATE_FILE=$(readlink -f $1)

export $(cat ${2}/version.env | xargs)

# Create .spec file with Version and Release set
SPEC_FILE="${SPEC_TEMPLATE_FILE%.*}.spec"
cp ${SPEC_TEMPLATE_FILE} ${SPEC_FILE}
sed -i "s/{{VERSION}}/${VERSION}/" "$SPEC_FILE"
sed -i "s/{{RELEASE}}/${RELEASE}${METADATA/#+/.}/" "$SPEC_FILE"
