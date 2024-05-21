#!/bin/bash

set -e

DUTS="rams stubs"

for DUT in $DUTS; do
  make DUT=$DUT
  make clean
done
