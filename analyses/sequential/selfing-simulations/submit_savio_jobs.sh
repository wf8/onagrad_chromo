#!/bin/bash

for job in {0..4}
do
    sbatch runs/ono${job}.sh
done
