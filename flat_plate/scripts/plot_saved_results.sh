#!/usr/bin/env bash

USAGE="Usage: $(basename $0) [OPTIONS]
Options:
  -d <dir>: Directory to load results from
  -n <name>: Name to attribute to data
  -s <name>: Saves the plot to 'name'

Runs the simulation using a variety of grid sizes and differencing methods"

DIRS=()
NAMES=()
SAVE_FIGS_NAME=""

while getopts d:n:s:h flag
do
    case "${flag}" in
        d) DIRS+=("$OPTARG");;
        n) NAMES+=("$OPTARG");;
        s) SAVE_FIGS_NAME=${OPTARG};;
        h) echo "$USAGE"; exit;
    esac
done

if [ "${#DIRS[@]}" -ne "${#NAMES[@]}" ]; then
    echo "ERROR: Unequal number of inputs for directories (-d) and names (-n)!"
    exit 1;
fi

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

# Form the input arguments for the plot data sources
PLOT_ARGS=()
for i in "${!DIRS[@]}"; do
    DATA_DIR=${DIRS[i]}
    DATA_NAME=${NAMES[i]}
    PLOT_ARGS+=("-i $DATA_NAME $DATA_DIR/postProcessing/plate.xy $DATA_DIR/postProcessing/x1_0.xy $DATA_DIR/initialConditions")
done

PLOT_ARGS="${PLOT_ARGS[*]}"

SAVE_ARGS=""
if [ ! -z "${SAVE_FIGS_NAME}" ];
then
    SAVE_ARGS="-s $SAVE_FIGS_NAME"
fi

octave $SCRIPT_DIR/plot_results.m $PLOT_ARGS -Cf_lim 0.0 0.006 -y_plus_lim 1e-1 1e4 $SAVE_ARGS
