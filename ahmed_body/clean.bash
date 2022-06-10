#!/usr/bin/env bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

pushd $SCRIPT_DIR > /dev/null

foamListTimes -rm
foamListTimes -rm -processor
rm -rf postProcessing
rm -rf log.simpleFoam*

rm -rf 0/uniform

popd > /dev/null
