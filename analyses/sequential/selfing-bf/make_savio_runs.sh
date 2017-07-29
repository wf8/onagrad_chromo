#!/bin/bash


rm -rf runs_dep
rm -rf runs_ind
mkdir runs_dep
mkdir runs_ind

for rep in {1..100}
do

    # base_dir = "/global/scratch/freyman/projects/onagrad_chromo/analyses/sequential/selfing-bf/"
    # rep = 1
    # seed(1) 
    
    echo "base_dir = \"/global/scratch/freyman/projects/onagrad_chromo/analyses/sequential/selfing-bf/\"" >> runs_dep/${rep}.Rev
    echo "rep = ${rep}" >> runs_dep/${rep}.Rev
    echo "seed(${rep})" >> runs_dep/${rep}.Rev
    cat sim_dependent.Rev >> runs_dep/${rep}.Rev
    
    echo "base_dir = \"/global/scratch/freyman/projects/onagrad_chromo/analyses/sequential/selfing-bf/\"" >> runs_ind/${rep}.Rev
    echo "rep = ${rep}" >> runs_ind/${rep}.Rev
    echo "seed(${rep})" >> runs_ind/${rep}.Rev
    cat sim_independent.Rev >> runs_ind/${rep}.Rev
    
done

for job in {0..4}
do

echo "#!/bin/bash
# Job name:
#SBATCH --job-name=sim_dep${job}
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
#" > runs_dep/ono${job}.sh
start=$[job*20 + 1]
end=$[job*20 + 20]
for core in $(seq $start $end)
do
    echo "/global/scratch/freyman/revbayes/projects/cmake/rb /global/scratch/freyman/projects/onagrad_chromo/analyses/sequential/selfing-bf/runs_dep/$core.Rev > /global/scratch/freyman/projects/onagrad_chromo/analyses/sequential/selfing-bf/output/${core}_dep.out 2>&1 &" >> runs_dep/ono${job}.sh
done
echo "wait" >> runs_dep/ono${job}.sh


echo "#!/bin/bash
# Job name:
#SBATCH --job-name=sim_ind${job}
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
#" > runs_ind/ono${job}.sh
start=$[job*20 + 1]
end=$[job*20 + 20]
for core in $(seq $start $end)
do
    echo "/global/scratch/freyman/revbayes/projects/cmake/rb /global/scratch/freyman/projects/onagrad_chromo/analyses/sequential/selfing-bf/runs_ind/$core.Rev > /global/scratch/freyman/projects/onagrad_chromo/analyses/sequential/selfing-bf/output/${core}_ind.out 2>&1 &" >> runs_ind/ono${job}.sh
done
echo "wait" >> runs_ind/ono${job}.sh

done
