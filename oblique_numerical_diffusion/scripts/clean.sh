#!/usr/bin/env bash

USAGE="Usage: $(basename $0) [OPTIONS]
Options:
  -m: Clears all mesh data
  -s: Clears all simulation data
  -l: Do not clear log files

Cleans mesh and simulation artifacts"

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

pushd $SCRIPT_DIR/.. > /dev/null

MESH=false
SIMULATION=false
LOGS=true

while getopts mslh flag
do
   case "${flag}" in
      m) MESH=true;;
      s) SIMULATION=true;;
      l) LOGS=false;;
      h) echo "$USAGE"; exit;
   esac
done

{
if [ "$MESH" = true ]
then
    rm -rf constant/polyMesh
fi

if [ "$SIMULATION" = true ]
then
    foamListTimes -rm -withFunctionEntries
    rm -rf postProcessing

fi

if [ "$LOGS" = true ]
then
    rm -f log.mesh
    rm -rf log.solve*
fi
} > /dev/null

popd > /dev/null
