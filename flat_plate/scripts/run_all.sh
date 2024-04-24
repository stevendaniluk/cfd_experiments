#!/usr/bin/env bash

USAGE="Usage: $(basename $0) [OPTIONS]
Options:
  -c: Clears all existing data

Meshes and runs the simulation"

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

pushd $SCRIPT_DIR/.. > /dev/null

CLEAN=false

while getopts j:csh flag
do
   case "${flag}" in
      c) CLEAN=true;;
      h) echo "$USAGE"; exit;
   esac
done

if [ "$CLEAN" = true  ]
then
    ./scripts/clean.sh -ms
fi

./scripts/mesh.sh
./scripts/solve.sh

popd > /dev/null
