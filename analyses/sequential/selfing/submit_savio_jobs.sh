#!/bin/bash

for job in {0..9}
do
    sbatch runs/ono${job}.sh
done
