#! /usr/bin/python
"""
Script to read in MCMC trace files and generate a new Rev script that continues
the chain from its last position.
"""

import csv

# specify which chain and which segment of the chain
chain_num = 1
segment_num = 1
output_file = str(chain_num) + "-" + str(segment_num) + ".Rev"
old_log_file = "output/" + str(chain_num) + "-" + str(segment_num - 1) + ".log"
old_tree_file = "output/" + str(chain_num) + "-" + str(segment_num - 1) + ".trees"

# set up the model by adding template_model.Rev
final_script = []
with open("templates/template_model.Rev") as f:
    for line in f.readlines():
        final_script.append(line)

if segment_num > 1:
    # get the parameter values
    parameters = []
    with open(old_log_file, 'rb') as csvfile:
        csvreader = csv.reader(csvfile, delimiter="\t")
        n_rows = sum(1 for _ in csvfile)
        for i, row in enumerate(csvreader):
            # get the names of each parameter
            if i == 0:
                for param in row:
                    parameters.append([param, ""])
            # get the last sampled value of each parameter
            if i == n_rows:
                for j, value in enumerate(row):
                    parameters[j][1] = value

    # add the parameter values to the Rev script
    for param in parameters:
        final_script.append(param[0] + ".setValue(" + param[1] + ")\n")

    # get the last sampled tree
    # TODO
    # make a tree file
    # TODO
    # add tree to script
    final_script.append('starting_tree <- readTrees(base_dir + "/starting_trees/' + str(chain_num) + "-" + str(segment_num) +'.tree")[1]\n')
    final_script.append('timetree.setValue(starting_tree)\n')


# set up the mcmc analysis by adding template_mcmc.Rev
with open("templates/template_mcmc.Rev") as f:
    for line in f.readlines():
        final_script.append(line)



# write the final script
# TODO
output = open('sample', 'a')
output.write(all_sample + native_sample + nonnative_sample)
output.close()

print("Done.")
