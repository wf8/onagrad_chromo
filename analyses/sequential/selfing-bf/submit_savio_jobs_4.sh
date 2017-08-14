#!/bin/bash

for job in {0..4}
do
    sbatch runs_ind4/ono${job}.sh
done
