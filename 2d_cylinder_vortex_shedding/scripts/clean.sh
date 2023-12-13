#!/usr/bin/env bash

USAGE="Usage: $(basename $0) [OPTIONS]
Options:
  -m: Clears all mesh data
  -s: Clears all simulation data

Cleans mesh and simulation artifacts"

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

pushd $SCRIPT_DIR/.. > /dev/null

MESH=false
SIMULATION=false

while getopts msh flag
do
   case "${flag}" in
      m) MESH=true;;
      s) SIMULATION=true;;
      h) echo "$USAGE"; exit;
   esac
done

if [ "$MESH" = true  ]
then
    rm constant/geometry/*.eMesh
    rm -rf constant/extendedFeatureEdgeMesh
    rm -rf constant/polyMesh
    foamListTimes -rm -processor -constant -withZero -withFunctionEntries

    rm log.mesh
fi

if [ "$SIMULATION" = true  ]
then
    foamListTimes -rm -withFunctionEntries
    foamListTimes -rm -processor -withZero -withFunctionEntries
    rm -rf postProcessing

    rm -rf log.solve
    rm -rf log.solve.analyzed
fi

popd > /dev/null
