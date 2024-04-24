#!/usr/bin/env bash

USAGE="Usage: $(basename $0) [OPTIONS]
Options:
  -c: Clears all results data

Runs the simulation, logs to the file 'log'
"

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

pushd $SCRIPT_DIR/.. > /dev/null

CLEAN=false

while getopts ch flag
do
   case "${flag}" in
      c) CLEAN=true;;
      h) echo "$USAGE"; exit;
   esac
done

LOG_NAME=log.solve

if [ "$CLEAN" = true  ]
then
    ./scripts/clean.sh -s
fi

foamRun | tee -a $LOG_NAME

echo "Done simulation!"

popd > /dev/null
