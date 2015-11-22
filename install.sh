#!/bin/bash

# Stop on the first sign of trouble
set -e

VERSION="master"
if [[ $1 != "" ]]; then VERSION=$1; fi

# Update the gateway installer to the correct branch (defaults to master)
echo "Updating installer files..."
git checkout -q $VERSION
OLD_HEAD=$(git rev-parse HEAD)
git pull
NEW_HEAD=$(git rev-parse HEAD)

if [[ $OLD_HEAD != $NEW_HEAD ]]; then
    echo "New installer found. Restarting process..."
    exec "./install.sh $1"
fi

echo "Installation completed."
