#! /usr/bin/python

import csv
import itertools
import operator

csv.field_size_limit(2147483647)

burnin = 1000 # per trace
sample_freq = 1 # number of iterations per sample
n_runs = 200 # number of MCMC runs to combine

print("Combining parameter traces...")

final_csv = []
gen = 0
header_done = False
for log in range(1, n_runs + 1):
    with open("output/selfing" + str(log) + ".log", 'r') as csvfile:
        lines_to_skip = 0
        csvreader = csv.reader(csvfile, delimiter="\t")
        for j, row in enumerate(csvreader):
            if (row[0][0] == "#"):
                lines_to_skip += 1
            else:
                if not header_done:
                    final_csv.append(row)
                    header_done = True
                elif j - 1 - lines_to_skip > burnin:
                    final_row = []
                    for i, column in enumerate(row):
                        if i == 0:
                            final_row.append(gen)
                            gen += sample_freq
                        else:
                            final_row.append(column)
                    final_csv.append(final_row)

with open("output/combined.log", "w") as csvfile:
    csvwriter = csv.writer(csvfile, delimiter="\t", lineterminator="\n")
    for row in final_csv:
        csvwriter.writerow(row)

#print("Combining ancestral state traces...")
#
#final_csv = []
#gen = 0
#header_done = False
#for log in range(1, n_runs + 1):
#    with open("output/stochastic_selfing" + str(log) + ".log", 'r') as csvfile:
#        lines_to_skip = 0
#        csvreader = csv.reader(csvfile, delimiter="\t")
#        for j, row in enumerate(csvreader):
#            if (row[0][0] == "#"):
#                lines_to_skip += 1
#            else:
#                if not header_done:
#                    final_csv.append(row)
#                    header_done = True
#                elif j - 1 - lines_to_skip > burnin:
#                    final_row = []
#                    for i, column in enumerate(row):
#                        if i == 0:
#                            final_row.append(gen)
#                            gen += sample_freq
#                        else:
#                            final_row.append(column)
#                    final_csv.append(final_row)
#
#with open("output/combined-anc.log", "w") as csvfile:
#    csvwriter = csv.writer(csvfile, delimiter="\t", lineterminator="\n")
#    for row in final_csv:
#        csvwriter.writerow(row)

print("Done.")
