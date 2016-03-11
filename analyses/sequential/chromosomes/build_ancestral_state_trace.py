#! /usr/bin/python

import csv
import itertools
import operator


f = "output/chromo-anc1.log"
n = 340 # number of tips
burnin = 100

root = 678
root_state = []
base_lyth = 677
base_lyth_states = []
base_onag = 630
base_onag_states = []

final_csv = []
with open(f, 'rb') as csvfile:
    csvreader = csv.reader(csvfile, delimiter="\t")
    for j, row in enumerate(csvreader):
        final_row = []
        for i, column in enumerate(row):
            if i == 0 or (i > 2 * n and i % 2 == 0):
                final_row.append(column)
                if j + 1 > burnin:
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

with open(f + ".final.log", "wb") as csvfile:
    csvwriter = csv.writer(csvfile, delimiter="\t")
    for row in final_csv:
        csvwriter.writerow(row)
