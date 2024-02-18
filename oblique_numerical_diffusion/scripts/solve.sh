#!/usr/bin/env bash

USAGE="Usage: $(basename $0) [OPTIONS]
Options:
  -c: Clears all results data
  -l <name>: Log name suffix to add (default name is log.solve)

Runs the simulation, logs to the file 'log'
"

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

pushd $SCRIPT_DIR/.. > /dev/null

CLEAN=false
LOG_SUFFIX=""

while getopts cl:h flag
do
   case "${flag}" in
      c) CLEAN=true;;
      l) LOG_SUFFIX=${OPTARG};;
      h) echo "$USAGE"; exit;
   esac
done

if [ "$CLEAN" = true ]
then
    ./scripts/clean.sh -s
fi

foamRun | tee -a log.solve.$LOG_SUFFIX

echo "Done simulation!"

popd > /dev/null
