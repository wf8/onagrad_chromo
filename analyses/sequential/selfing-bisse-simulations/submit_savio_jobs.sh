#!/bin/bash

for job in {0..4}
do
    sbatch runs_dep/ono${job}.sh
    sbatch runs_ind/ono${job}.sh
done
