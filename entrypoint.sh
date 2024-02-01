#!/bin/bash

export WORKSPACE=/tools

nohup Rscript $WORKSPACE/annotation_comparison/R/main.R &

python3 $WORKSPACE/tdt.py