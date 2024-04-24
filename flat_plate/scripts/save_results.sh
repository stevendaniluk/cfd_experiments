#!/usr/bin/env bash

USAGE="Usage: $(basename $0) <OUTPUT_DIR_NAME> [OPTIONS]

Options:
  -t <time>: Time point to save results for
  -f: Don't generate figures

Saves the following data to results/OUTPUT_DIR_NAME:
  -Log files from mesh generation and solver
  -initialConditions file
  -postProcessing data
  -0 directory
  -fvSchemes and fvSolution
  -Plot of solver residuals (optional)
  -Plot of continuity (optional)
  -Plots of Cf and y+ (optional)
"

SKIP_FIGS=false
T_POINT="latest"
while getopts t:fh flag
do
    case "${flag}" in
        t) T_POINT=${OPTARG};;
        f) SKIP_FIGS=true;;
        h) echo "$USAGE"; exit;
    esac
done

OUTPUT_DIR=${@:$OPTIND:1}

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

pushd $SCRIPT_DIR/.. > /dev/null

mkdir -p $OUTPUT_DIR/postProcessing

# Initial conditions
cp include/initialConditions $OUTPUT_DIR/
cp system/{fvSchemes,fvSolution} $OUTPUT_DIR/

mkdir -p $OUTPUT_DIR/0
cp 0/{p,U,k,nut,omega,epsilon} $OUTPUT_DIR/0/ 2>/dev/null

# Logs
cp {log.mesh,log.solve} $OUTPUT_DIR/

# Solver plots
if [ "$SKIP_FIGS" = false  ]
then
    pyFoamPlotWatcher.py log.solve --hardcopy --solver-not-running-anymore --silent 2> /dev/null
    mv {cont.png,linear.png} $OUTPUT_DIR/
    rm {linear_,cont_,bound,bound_}.png
fi

# Post processing data
cp postProcessing/wallShearStress/0/* $OUTPUT_DIR/postProcessing/
cp postProcessing/yPlus/0/* $OUTPUT_DIR/postProcessing/

LATEST_TIME=""
if [ $T_POINT = "latest" ]
then
    LATEST_TIME=$(foamListTimes -withFunctionEntries -latestTime | tail -n 1)
else
    LATEST_TIME=$T_POINT
fi

cp postProcessing/U_profile_sample/$LATEST_TIME/* $OUTPUT_DIR/postProcessing/
cp postProcessing/wall_shear_sample/$LATEST_TIME/* $OUTPUT_DIR/postProcessing/

if [ "$SKIP_FIGS" = false  ]
then
    ./scripts/plot_saved_results.sh -d $OUTPUT_DIR -n Simulated -s $OUTPUT_DIR/plots
fi
