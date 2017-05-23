#!/bin/bash

for job in {0..3}
do
    sbatch runs/ono${job}.sh
done
