#!/usr/bin/env bash

USAGE="Usage: $(basename $0) [OPTIONS]
Options:
  -c: Clears all existing data
  -s: Runs setFields
  -j <cores>: Number of cores to use, defaults to 1 (i.e. single threaded)

Generates and renumbers a mesh, and will decompose when multithreaded"

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

pushd $SCRIPT_DIR/.. > /dev/null

CLEAN=false
SET_FIELDS=""
CORES=1

while getopts j:csh flag
do
   case "${flag}" in
      c) CLEAN=true;;
      s) SET_FIELDS="-s";;
      j) CORES=${OPTARG};;
      h) echo "$USAGE"; exit;
   esac
done

if [ "$CLEAN" = true  ]
then
    ./scripts/clean.sh -ms
fi

./scripts/mesh.sh -j $CORES
./scripts/solve.sh $SET_FIELDS -j $CORES

popd > /dev/null
