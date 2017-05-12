#! /usr/bin/python

import csv 

input_file = "data/summary.tsv"
output_file = "data/polyploidization.csv"

# ignore (Lythraceae)
exclude = range(1, 45)
exclude += range(629, 672)

# sc lineages
sc = range(46, 57)
sc += range(616, 626)
sc += [58,59,60,61,612,64,65,66,67,607]
sc += range(562,603)
sc += range(70,112)
sc += range(113,118)
sc += range(556,558)
sc += range(120,122)
sc += range(124,151)
sc += range(152,158)
sc += range(161,189)
sc += range(536,546)
sc += range(529,534)
sc += range(525,526)
sc += range(521,522)
sc += range(514,516)
sc += range(509,511)
sc += range(485,508)
sc += range(193,198)
sc += range(475,477)
sc += range(199,221)
sc += range(453,474)
sc += range(222,223)
sc += [518, 227]
sc += range(231,234)
sc += range(441,442)
sc += range(237,241)
sc += [34,249,252,253,255,257]
sc += range(261,269)
sc += range(404,411)
sc += range(271,272)
sc += range(274,275)
sc += range(384,397)
sc += range(276,292)
sc += [381, 390]
sc += range(298,302)
sc += range(374,375)
sc += range(311,313)
sc += [304, 308, 361,318,337,341,330]
sc += range(332,333)
sc += range(327,328)

with open(input_file, "rb") as in_f, open(output_file, "wb") as out_f:
    tsv_in = csv.reader(in_f, delimiter='\t')
    csv_out = csv.writer(out_f)

    total_sc_events = 0
    total_si_events = 0

    samples = {}

    # iteration   node_index  branch_start_time   branch_end_time start_state end_state   transition_time transition_type
    for row in tsv_in:

        if row[0] != "iteration":

            iteration = int(row[0])
            index = int(row[1])
            start = int(row[5])
            end = int(row[4])

            # exclude samples from the outgroup
            if (index not in exclude):

                if iteration not in samples:
                    samples[iteration] = [0, 0]

                # check for poly or demi-polyploidization event
                if (abs(start - end) > 1):

                    if index in sc:
                        total_sc_events += 1
                        samples[iteration][0] += 1
                    else:
                        total_si_events += 1
                        samples[iteration][1] += 1


    # write output
    for s in list(samples.keys()):
        csv_out.writerow(samples[s])

print("Total SC polyploidization events: " + str(total_sc_events))
print("Total SI polyploidization events: " + str(total_si_events))
print("Done.")
