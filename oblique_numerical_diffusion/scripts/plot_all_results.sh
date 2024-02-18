#!/usr/bin/env bash

USAGE="Usage: $(basename $0) [OPTIONS]
Options:
  -d <dir>: Directory to load results from, defaults to 'results'
  -s <name>: Saves the plot to 'name'

Runs the simulation using a variety of grid sizes and differencing methods"

LOAD_DIR="results"
SAVE_PATH=""

while getopts d:s:h flag
do
   case "${flag}" in
      d) LOAD_DIR=${OPTARG};;
      s) SAVE_PATH=${OPTARG};;
      h) echo "$USAGE"; exit;
   esac
done

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

pushd $SCRIPT_DIR/../$LOAD_DIR > /dev/null

INPUT_ARG=""
for FILENAME in *.csv; do
    # Form on set or arguments to pass to the plotting script

    # Name for plot should just be the filename, but replace some problematic characters
    BASE_NAME=$(basename ${FILENAME})
    BASE_NAME=${BASE_NAME%.*}
    BASE_NAME="${BASE_NAME//_/ }"
    BASE_NAME="${BASE_NAME//-/.}"

    INPUT_ARG="${INPUT_ARG} -i \"${FILENAME}\" \"${BASE_NAME}\""
done

SAVE_ARG=""
if [ ! -z "$SAVE_PATH" ]; then
    SAVE_ARG="-s $SAVE_PATH"
fi
echo $SAVE_ARG

eval octave $SCRIPT_DIR/plot_scalar_diffusion.m ${INPUT_ARG} -y -0.2 1.2 $SAVE_ARG
