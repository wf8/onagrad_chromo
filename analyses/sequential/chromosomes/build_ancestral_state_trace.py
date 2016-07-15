#! /usr/bin/python

import csv
import itertools
import operator


f = ["output/chromo-anc1.log", "output/chromo-anc2.log",
     "output/chromo-anc3.log", "output/chromo-anc4.log",
     "output/chromo-anc5.log"]

t = ["output/chromo1.trees", "output/chromo2.trees",
     "output/chromo3.trees", "output/chromo4.trees",
     "output/chromo5.trees"]

n = 340 # number of tips
burnin = 100 # per trace
sample_freq = 2 # number of iterations per sample

# node ids
root = 678
root_state = []
base_lyth = 677
base_lyth_states = []
base_onag = 630
base_onag_states = []

print("Combining ancestral state traces...")

final_csv = []
gen = 0
header_done = False
for log in f:
    with open(log, 'rb') as csvfile:
        csvreader = csv.reader(csvfile, delimiter="\t")
        for j, row in enumerate(csvreader):
            if not header_done:
                final_csv.append(row)
                header_done = True
            elif j + 1 > burnin:
                final_row = []
                for i, column in enumerate(row):
                    if i == 0:
                        final_row.append(gen)
                        gen += sample_freq
                    else:
                        final_row.append(column)
                        current_index = (i / 2) - 1
                        if current_index == root:
                            root_state.append(column)
                        if current_index == base_lyth:
                            base_lyth_states.append(column)
                        if current_index == base_onag:
                            base_onag_states.append(column)
                final_csv.append(final_row)

root_map = max(set(root_state), key=root_state.count)
lyth_map = max(set(base_lyth_states), key=base_lyth_states.count)
onag_map = max(set(base_onag_states), key=base_onag_states.count)

root_pp = round(root_state.count(root_map) / float(len(root_state)), 2)
lyth_pp = round(base_lyth_states.count(lyth_map) / float(len(base_onag_states)), 2)
onag_pp = round(base_onag_states.count(onag_map) / float(len(base_lyth_states)), 2)

print("Root MAP = " + str(root_map) + ", pp = " + str(root_pp))
print("Base Lyth MAP = " + str(lyth_map) + ", pp = " + str(lyth_pp))
print("Base Onag MAP = " + str(onag_map) + ", pp = " + str(onag_pp))

with open("output/chromo-anc-final.log", "wb") as csvfile:
    csvwriter = csv.writer(csvfile, delimiter="\t")
    for row in final_csv:
        csvwriter.writerow(row)

print("Combining tree traces...")

final_csv = []
gen = 0
header_done = False
for log in t:
    with open(log, 'rb') as csvfile:
        csvreader = csv.reader(csvfile, delimiter="\t")
        for j, row in enumerate(csvreader):
            if not header_done:
                final_csv.append(row)
                header_done = True
            elif j + 1 > burnin:
                final_row = []
                for i, column in enumerate(row):
                    if i == 0:
                        final_row.append(gen)
                        gen += sample_freq
                    else:
                        final_row.append(column)
                final_csv.append(final_row)

with open("output/chromo-anc-final.trees", "wb") as csvfile:
    csvwriter = csv.writer(csvfile, delimiter="\t")
    for row in final_csv:
        csvwriter.writerow(row)

print("Done.")
