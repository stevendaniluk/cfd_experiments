#!/usr/bin/env bash

USAGE="Usage: $(basename $0) <OUTPUT_DIR_NAME> <PLOT_FORCE_OPTIONS>

PLOT_FORCE_OPTIONS: Optional, passes all arguments to the plot_force_coeffs.m script

Saves the following data to results/OUTPUT_DIR_NAME:
  -Plot of residuals
  -Plot of continuity
  -Plot of Cd and Cl force coefficients
  -forceCoeffs.dat file
  -Log files from mesh generation and solver
"

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

pushd $SCRIPT_DIR/.. > /dev/null

OUTPUT_DIR=results/$1
PLOT_ARGS="${@:2}"

# Generate plots
pyFoamPlotWatcher.py log.solve --hardcopy --solver-not-running-anymore --silent
octave scripts/plot_force_coeffs.m postProcessing/forces/0/forceCoeffs.dat $PLOT_ARGS -s force_coeffs

# Move/copy data to destination
mkdir -p $OUTPUT_DIR
mv {cont.png,linear.png,force_coeffs.png} $OUTPUT_DIR/
cp {log.mesh,log.solve,postProcessing/forces/0/forceCoeffs.dat} $OUTPUT_DIR/
rm {linear_,cont_}.png
