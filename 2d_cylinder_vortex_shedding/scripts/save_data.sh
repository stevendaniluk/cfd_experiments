#!/usr/bin/env bash

USAGE="Usage: $(basename $0) <OUTPUT_DIR_NAME>


Saves the following data to results/OUTPUT_DIR_NAME:
  -constant directory
  -processor directories
"

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

pushd $SCRIPT_DIR/.. > /dev/null

OUTPUT_DIR=results/$1

mkdir -p $OUTPUT_DIR

cp -r 0.orig $OUTPUT_DIR/
cp -r include $OUTPUT_DIR/
cp -r constant $OUTPUT_DIR/
cp -r system $OUTPUT_DIR/
cp -r processor* $OUTPUT_DIR/
