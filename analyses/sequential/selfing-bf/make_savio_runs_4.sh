#!/bin/bash


rm -rf runs_ind4
mkdir runs_ind4

for rep in {1..100}
do

    # base_dir = "/global/scratch/freyman/projects/onagrad_chromo/analyses/sequential/selfing-bf/"
    # rep = 1
    # seed(1) 
    
    echo "base_dir = \"/global/scratch/freyman/projects/onagrad_chromo/analyses/sequential/selfing-bf/\"" >> runs_ind4/${rep}.Rev
    echo "rep = ${rep}" >> runs_ind4/${rep}.Rev
    echo "seed(${rep})" >> runs_ind4/${rep}.Rev
    cat sim_independent4.Rev >> runs_ind4/${rep}.Rev
    
done

for job in {0..4}
do


echo "#!/bin/bash
# Job name:
#SBATCH --job-name=sim_ind4_${job}
#
# Partition:
#SBATCH --partition=savio
#
# Processors:
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --cpus-per-task=1
#
# Wall clock limit (max=72:00:00)
#SBATCH --time=72:00:00
#
# Account:
#SBATCH --account=fc_freyman
#
# Specify Faculty Computing Allowance:
#SBATCH --qos=savio_normal
#" > runs_ind4/ono${job}.sh
start=$[job*20 + 1]
end=$[job*20 + 20]
for core in $(seq $start $end)
do
    echo "/global/scratch/freyman/revbayes/projects/cmake/rb /global/scratch/freyman/projects/onagrad_chromo/analyses/sequential/selfing-bf/runs_ind4/$core.Rev > /global/scratch/freyman/projects/onagrad_chromo/analyses/sequential/selfing-bf/output/${core}_ind4.out 2>&1 &" >> runs_ind4/ono${job}.sh
done
echo "wait" >> runs_ind4/ono${job}.sh

done
