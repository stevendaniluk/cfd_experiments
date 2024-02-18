#!/usr/bin/env bash

USAGE="Usage: $(basename $0) [OPTIONS]
Options:
    -f <field>: Custom field in initialConditions to modify
    -p <file>: File containing values for 'field' to run
    -m: Re mesh before each run
    -x: Do not include field name in results file
    -s: Generate and save figures (line plot, residuals, paraview)
    -o <dir>: Directory to save postProcessing results to, defaults to 'results'

Runs permutations of the simulation for user defined parameters"

FIELDS=()
PERMUTATIONS_FILES=()
MESH=false
X_FIELD=false
SAVE_FIGS=false
SAVE_DIR="results"

while getopts f:p:o:mxsh flag
do
    case "${flag}" in
        f) FIELDS+=("$OPTARG");;
        p) PERMUTATIONS_FILES+=("$OPTARG");;
        m) MESH=true;;
        x) X_FIELD=true;;
        s) SAVE_FIGS=true;;
        o) SAVE_DIR=${OPTARG};;
        h) echo "$USAGE"; exit;
    esac
done

if [ "${#FIELDS[@]}" -ne "${#PERMUTATIONS_FILES[@]}" ]; then
    echo "ERROR: Unequal number of inputs for fields (-f) and permutations (-p)!"
    exit 1;
fi

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

for i in "${!FIELDS[@]}"; do
    F=${FIELDS[i]}

    while read V; do
        # Form the name to write results to
        RESULTS_NAME=""
        if [ "$X_FIELD" = false ]; then
            RESULTS_NAME="${F}=${V}"
        else
            RESULTS_NAME="${V}"
        fi

        # Clean up log file name to remove common or problematic characters
        RESULTS_NAME_RAW=$RESULTS_NAME
        RESULTS_NAME="${RESULTS_NAME//"Gauss "/}"
        RESULTS_NAME="${RESULTS_NAME//" grad(U)"/}"
        RESULTS_NAME="${RESULTS_NAME// /_}"
        RESULTS_NAME="${RESULTS_NAME//./-}"

        # Change the field value
        sed -i "s/^${F} .*$/${F} ${V};/" include/initialConditions

        # Handle remeshing
        if [ "$MESH" = true ]; then
            ./scripts/mesh.sh
        fi

        # Solve and save results
        ./scripts/clean.sh -s -l
        ./scripts/solve.sh -l $RESULTS_NAME

        mv "log.solve.$RESULTS_NAME" "${SAVE_DIR}/log.solve.$RESULTS_NAME"

        # Save sample points from line
        cp postProcessing/line_sample/1/line.csv "${SAVE_DIR}/${RESULTS_NAME}.csv"

        if [ "$SAVE_FIGS" = true ]; then
            # Plot of line sample point
            octave scripts/plot_scalar_diffusion.m -i "${SAVE_DIR}/${RESULTS_NAME}.csv" "${RESULTS_NAME_RAW}" -y -0.2 1.2 -s "${SAVE_DIR}/${RESULTS_NAME}"

            # Residuals plot
            pyFoamPlotWatcher.py ${SAVE_DIR}/log.solve.$RESULTS_NAME --hardcopy --solver-not-running-anymore --silent --prefix-hardcopy=$RESULTS_NAME
            mv "${RESULTS_NAME}.linear.png" "${SAVE_DIR}/residuals_${RESULTS_NAME}.png"
            rm "${RESULTS_NAME}.linear_.png"
            rm -rf ${SAVE_DIR}/log.solve.$RESULTS_NAME.analyzed

            # Save ParaView screenshot
            pyFoamPVSnapshot.py . --state-file analysis.pvsm --latest-time
            mv Snapshot_oblique_numerical_diffusion_00001_t\=1_analysis.png "${SAVE_DIR}/paraview_${RESULTS_NAME}.png"
        fi

    done < ${PERMUTATIONS_FILES[i]}
done

if [ "$SAVE_FIGS" = true ]; then
    # Make a plot of all results
    ./scripts/plot_all_results.sh -d ${SAVE_DIR} -s all_lines_plot
fi

# Replace the original initialConditions file
mv include/initialConditions.bckp include/initialConditions

popd > /dev/null
