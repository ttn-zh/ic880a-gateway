#!/bin/bash

# Stop on the first sign of trouble
set -e

VERSION="master"
if [[ $1 != "" ]]; then VERSION=$1; fi

# Update the gateway installer to the correct branch (defaults to master)
echo "Updating installer files..."
git checkout -q $VERSION
git pull



echo "Installation completed."
