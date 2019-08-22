#!/bin/bash

yourfilenames=`ls ./replays/sc2replay/*.SC2Replay`
for eachfile in $yourfilenames
do
   python ../s2protocol/s2protocol/s2_cli.py --all --ndjson $eachfile
done