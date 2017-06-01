#!/bin/bash

for job in {0..0}
do
    sbatch runs/ono${job}.sh
done
