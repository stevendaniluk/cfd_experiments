#!/usr/bin/env bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

pushd $SCRIPT_DIR

CORES=10

mpirun -np $CORES simpleFoam -parallel | tee -a log.simpleFoam
reconstructPar -noZero -newTimes

popd
