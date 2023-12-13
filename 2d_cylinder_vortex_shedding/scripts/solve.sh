#!/usr/bin/env bash

USAGE="Usage: $(basename $0) [OPTIONS]
Options:
  -c: Clears all results data
  -s: Runs setFields
  -r: Runs reconstructPar
  -j <cores>: Number of cores to use, defaults to 1 (i.e. single threaded)

Runs the simulation, logs to the file 'log'
"

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

pushd $SCRIPT_DIR/.. > /dev/null

CORES=1
CLEAN=false
SET_FIELDS=false
RECONSTRUCT=false

while getopts j:csrh flag
do
   case "${flag}" in
      j) CORES=${OPTARG};;
      c) CLEAN=true;;
      s) SET_FIELDS=true;;
      r) RECONSTRUCT=true;;
      h) echo "$USAGE"; exit;
   esac
done

LOG_NAME=log.solve

if [ "$CLEAN" = true  ]
then
    ./scripts/clean.sh -s
fi

# Copy the 0 directory over
cp -rT 0.orig 0

if [ $CORES = "1" ]
then
    if [ $SET_FIELDS = true ]
    then
        echo "Setting fields"
        setFields
    fi

    foamRun | tee -a $LOG_NAME
else
    decomposePar -fields

    rm -rf 0

    if [ $SET_FIELDS = true ]
    then
        echo "Setting fields"
        mpirun -np $CORES setFields -parallel
    fi

    echo "Running..."
    mpirun -np $CORES foamRun -parallel | tee -a $LOG_NAME

    if [ $RECONSTRUCT = true ]
    then
        echo "Reconstructing..."
        reconstructPar -newTimes
    fi
fi

echo "Done simulation!"

popd > /dev/null
