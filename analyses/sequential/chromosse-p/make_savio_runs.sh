#!/bin/bash


rm -rf runs
mkdir runs

for rep in {1..80}
do

    # base_dir = "/global/scratch/freyman/projects/onagrad_chromo/analyses/sequential/chromosse-p/"
    # rep = 1
    # seed(1) 
    
    echo "base_dir = \"/global/scratch/freyman/projects/onagrad_chromo/analyses/sequential/chromosse-p/\"" >> runs/${rep}.Rev
    echo "rep = ${rep}" >> runs/${rep}.Rev
    echo "seed(${rep})" >> runs/${rep}.Rev
    cat onagrad.Rev >> runs/${rep}.Rev
    
done

for job in {0..3}
do

echo "#!/bin/bash
# Job name:
#SBATCH --job-name=ono${job}
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
#" > runs/ono${job}.sh
start=$[job*20 + 1]
end=$[job*20 + 20]
for core in $(seq $start $end)
do
    echo "/global/scratch/freyman/revbayes/projects/cmake/rb /global/scratch/freyman/projects/onagrad_chromo/analyses/sequential/chromosse-p/runs/$core.Rev > /global/scratch/freyman/projects/onagrad_chromo/analyses/sequential/chromosse-p/output/${core}.out 2>&1 &" >> runs/ono${job}.sh
done
echo "wait" >> runs/ono${job}.sh

done
