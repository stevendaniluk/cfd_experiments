#!/usr/bin/env bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

pushd $SCRIPT_DIR

CORES=10

foamCleanCase

echo "Block mesh..."
surfaceFeatures
blockMesh

echo "Decomposing..."
decomposePar -force

echo "Snappy Hex Mesh..."
mpirun -np $CORES snappyHexMesh -overwrite -parallel

echo "Reconstructing..."
reconstructParMesh -constant -noZero

echo "Renumbering..."
renumberMesh -overwrite

echo "Decomposing..."
decomposePar -force

echo "Done mesh!"

popd
