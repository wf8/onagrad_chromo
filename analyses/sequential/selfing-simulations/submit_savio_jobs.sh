#!/bin/bash

for job in {0..19}
do
    sbatch runs/ono${job}.sh
done
