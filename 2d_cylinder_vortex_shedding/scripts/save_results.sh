#!/usr/bin/env bash

USAGE="Usage: $(basename $0) <OUTPUT_DIR_NAME> <T_POINT> <PLOT_FORCE_OPTIONS>

T_POINT: postProcessing time point to use
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
T_POINT=$2
PLOT_ARGS="${@:3}"

mkdir -p $OUTPUT_DIR

# Logs
cp {log.mesh,log.solve} $OUTPUT_DIR/

# Solver plots
pyFoamPlotWatcher.py log.solve --hardcopy --solver-not-running-anymore --silent
mv {cont.png,linear.png} $OUTPUT_DIR/
rm {linear_,cont_,bound,bound_}.png

# y+
cp postProcessing/yPlus/$T_POINT/yPlus.dat $OUTPUT_DIR/

# Force coefficient data and plot
cp postProcessing/forces/$T_POINT/forceCoeffs.dat $OUTPUT_DIR/
octave scripts/plot_force_coeffs.m postProcessing/forces/$T_POINT/forceCoeffs.dat $PLOT_ARGS -s force_coeffs
mv force_coeffs.png $OUTPUT_DIR/

octave scripts/analyze_force_coeffs.m postProcessing/forces/$T_POINT/forceCoeffs.dat $PLOT_ARGS > $OUTPUT_DIR/force_coeffs_range.txt

# Paraview screenshot
pyFoamPVSnapshot.py . --state-file turbulence_props.pvsm --latest-time
mv Snapshot_2d_cylinder_vortex_shedding_*_turbulence_props.png $OUTPUT_DIR/paraview_turbulence_props.png
