#! /usr/bin/python
"""
Script to read in MCMC trace files and generate a new Rev script that continues
the chain from its last position.
"""

import csv

# specify which chain and which segment of the chain
chain_num = 1
segment_num = 2
output_file = str(chain_num) + "-" + str(segment_num) + ".Rev"
old_log_file = "output/" + str(chain_num) + "-" + str(segment_num - 1) + ".log"
old_tree_file = "output/" + str(chain_num) + "-" + str(segment_num - 1) + ".trees"

# set up the model by adding template_model.Rev
print("Setting up model...")
final_script = []
with open("templates/template_model.Rev") as f:
    for line in f.readlines():
        final_script.append(line)

if segment_num > 1:
    print("Getting last sampled parameter values from previous chain segment...")
    # get the parameter values
    parameters = []
    with open(old_log_file, 'rb') as csvfile:
        csvreader = list(csv.reader(csvfile, delimiter="\t"))
        n_rows = sum(1 for _ in csvreader)
        for i, row in enumerate(csvreader):
            # get the names of each parameter
            if i == 0:
                for param in row:
                    parameters.append([param, ""])
            # get the last sampled value of each parameter
            if i == n_rows - 1:
                for j, value in enumerate(row):
                    parameters[j][1] = value

    # add the parameter values to the Rev script
    skip = ["Iteration", "Posterior", "Likelihood", "Prior"]
    for param in parameters:
        if param[0] not in skip:
            final_script.append(param[0] + ".setValue(" + param[1] + ")\n")

    # get the last sampled tree
    print("Getting last sampled tree from previous chain segment...")
    tree = ""
    with open(old_tree_file, 'rb') as csvfile:
        csvreader = list(csv.reader(csvfile, delimiter="\t"))
        n_rows = sum(1 for _ in csvreader)
        for i, row in enumerate(csvreader):
            # get the last sampled value of each parameter
            if i == n_rows - 1:
                tree = row[len(row) - 1]
                break

    # make a tree file
    output = open("starting_trees/" + str(chain_num) + "-" + str(segment_num) +".tree", "w")
    output.write(tree)
    output.close()
    
    # add tree to script
    final_script.append('starting_tree <- readTrees(base_dir + "/starting_trees/' + str(chain_num) + "-" + str(segment_num) +'.tree")[1]\n')
    final_script.append('timetree.setValue(starting_tree)\n')


# set up the mcmc analysis by adding template_mcmc.Rev
print("Setting up MCMC analysis...")
final_script.append("chain_num = " + str(chain_num) + "\n")
final_script.append("run_num = " + str(segment_num) + "\n")
with open("templates/template_mcmc.Rev") as f:
    for line in f.readlines():
        final_script.append(line)

# write the final script
print("Writing file scripts/" + str(chain_num) + "-" + str(segment_num) +".Rev...")
output = open("scripts/" + str(chain_num) + "-" + str(segment_num) +".Rev", "w")
output.write("".join(final_script))
output.close()

print("Done.")
