#!/usr/bin/env bash

USAGE="Usage: $(basename $0) [OPTIONS]
Options:
  -c: Clears all mesh data
  -j <cores>: Number of cores to use, defaults to 1 (i.e. single threaded)

Generates and renumbers a mesh, and will decompose when multithreaded"

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

pushd $SCRIPT_DIR/.. > /dev/null

CLEAN=false
CORES=1

while getopts j:censh flag
do
   case "${flag}" in
      c) CLEAN=true;;
      j) CORES=${OPTARG};;
      h) echo "$USAGE"; exit;
   esac
done

LOG_NAME=log.mesh
{

if [ "$CLEAN" = true ]
then
    ./scripts/clean.sh -m
fi

echo "Block mesh..."
blockMesh

echo "Renumbering..."
renumberMesh -overwrite -noZero

echo "Done mesh!"

} | tee -a $LOG_NAME

popd > /dev/null
