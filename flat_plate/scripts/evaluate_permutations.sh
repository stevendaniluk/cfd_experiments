#!/usr/bin/env bash

USAGE="Usage: $(basename $0) [OPTIONS]
Options:
    -p <file>: CSV file containing permutations
    -m: Re mesh before each run
    -o <dir>: Directory to save postProcessing results to, defaults to 'results'

Runs permutations of the simulation for user defined parameters"

PERMUTATIONS_FILES=()
MESH=false
SAVE_DIR="results"

while getopts p:o:mh flag
do
    case "${flag}" in
        p) PERMUTATIONS_FILES+=("$OPTARG");;
        m) MESH=true;;
        o) SAVE_DIR=${OPTARG};;
        h) echo "$USAGE"; exit;
    esac
done

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

pushd $SCRIPT_DIR/.. > /dev/null

# Destination to save to
mkdir -p $SAVE_DIR

# Back up the initialConditions file
cp include/initialConditions include/initialConditions.bckp

# Clean all previous results
./scripts/clean.sh -msl

if [ "$MESH" = false ]; then
    # Not remeshing every run, so do once initially
    ./scripts/mesh.sh
fi

PLOT_ARGS=()
for CURRENT_PERM_FILE in "${PERMUTATIONS_FILES[@]}"; do
    echo "Parsing $CURRENT_PERM_FILE"
    while IFS=',' read -ra V; do
        PERM_FIELD=("${V[0]}")
        PERM_VAL=("${V[1]}")
        PERM_NAME=("${V[2]}")

        # Clean up directory name to remove common or problematic characters
        RESULTS_NAME=$PERM_NAME
        RESULTS_NAME="${RESULTS_NAME// /_}"
        RESULTS_NAME="${RESULTS_NAME//./-}"

        # Change the field value
        sed -i "s/^${PERM_FIELD} .*$/${PERM_FIELD} ${PERM_VAL};/" include/initialConditions

        # Handle remeshing
        if [ "$MESH" = true ]; then
            ./scripts/mesh.sh -c
        fi

        # Solve and save results
        ./scripts/clean.sh -s
        ./scripts/solve.sh
        ./scripts/save_results.sh $SAVE_DIR/$RESULTS_NAME

        # Form the input arguments for the plot data sources
        PLOT_ARGS+=("-d $SAVE_DIR/$RESULTS_NAME -n $PERM_NAME")

    done < ${CURRENT_PERM_FILE}
done

# Generate plots for all variations together
PLOT_ARGS="${PLOT_ARGS[*]}"
./scripts/plot_saved_results.sh $PLOT_ARGS -s "${SAVE_DIR}/all_plots"

# Replace the original initialConditions file
mv include/initialConditions.bckp include/initialConditions

popd > /dev/null
