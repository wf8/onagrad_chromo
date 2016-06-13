#! /usr/bin/python

import csv
import itertools
import operator


files = ["output/chromo1.log", "output/chromo2.log",
         "output/chromo3.log", "output/chromo4.log",
         "output/chromo5.log"]

#Iteration   Posterior   Likelihood  Prior   clado_demipoly  clado_demipoly_pr   clado_fission   clado_fission_pr    clado_fusion    clado_fusion_pr clado_no_change clado_no_change_pr  clado_polyploid clado_polyploid_pr  clado_type[1]   clado_type[2]   clado_type[3]   clado_type[4]   clado_type[5]   clado_type[1]   clado_type[2]   clado_type[3]   clado_type[4]   clado_type[5]   delta   delta_l lambda  lambda_l    mu  rho

# log file columns
demipoly_i = 5
fission_i = 7
fusion_i = 9
no_change_i = 11
polyploid_i = 13
delta_i = 24
delta_l_i = 25
lambda_i = 26
lambda_l_i = 27
mu_i = 28
rho_i = 29

# sample counts
samples = 0
clado_demipoly = 0
clado_fission = 0
clado_fusion = 0
clado_polyploid = 0
delta = 0
delta_l = 0
lambda_ = 0
lambda_l = 0
mu = 0
rho = 0
all_clado = 0
all_ana = 0
clado_poly_no_ana_poly = 0
ana_poly_no_clado_poly = 0
both_poly = 0
either_poly = 0

def most_common(L):
  # get an iterable of (item, iterable) pairs
  SL = sorted((x, i) for i, x in enumerate(L))
  #print 'SL:', SL
  groups = itertools.groupby(SL, key=operator.itemgetter(0))
  # auxiliary function to get "quality" for an item
  def _auxfun(g):
    item, iterable = g
    count = 0
    min_index = len(L)
    for _, where in iterable:
      count += 1
      min_index = min(min_index, where)
      #print 'item %r, count %r, minind %r' % (item, count, min_index)
    return count, -min_index
  # pick the highest-count/earliest item
  return max(groups, key=_auxfun)[0]

bitstrings = []

for f in files:
    with open(f, 'rb') as csvfile:
        csvreader = csv.reader(csvfile, delimiter="\t")
        for row in csvreader:
            if row[0] != "Iteration":

                bitstring = ""
                samples += 1

                if row[demipoly_i] == "0":
                    clado_demipoly += 1
                    bitstring += "0"
                else:
                    bitstring += "1"
                if row[fission_i] == "0":
                    clado_fission += 1
                    bitstring += "0"
                else:
                    bitstring += "1"
                if row[fusion_i] == "0":
                    clado_fusion += 1
                    bitstring += "0"
                else:
                    bitstring += "1"
                if row[polyploid_i] == "0":
                    clado_polyploid += 1
                    bitstring += "0"
                else:
                    bitstring += "1"
                
                if row[demipoly_i] == "0" and row[fission_i] == "0" and row[fusion_i] == "0" and row[polyploid_i] == "0":
                    all_ana += 1

                if row[delta_i] == "0":
                    delta += 1
                    bitstring += "0"
                else:
                    bitstring += "1"
                if row[delta_l_i] == "0" or (row[delta_l_i] != "0" and row[delta_i] == "0"):
                    delta_l += 1
                    bitstring += "0"
                else:
                    bitstring += "1"
                if row[lambda_i] == "0":
                    lambda_ += 1
                    bitstring += "0"
                else:
                    bitstring += "1"
                if row[lambda_l_i] == "0" or (row[lambda_l_i] != "0" and row[lambda_i] == "0"):
                    lambda_l += 1
                    bitstring += "0"
                else:
                    bitstring += "1"
                if row[mu_i] == "0":
                    mu += 1
                    bitstring += "0"
                else:
                    bitstring += "1"
                if row[rho_i] == "0":
                    rho += 1
                    bitstring += "0"
                else:
                    bitstring += "1"

                bitstrings.append(bitstring)

                if row[delta_i] == "0" and row[lambda_i] == "0" and row[mu_i] == "0" and row[rho_i] == "0":
                    all_clado += 1

                if row[polyploid_i] != "0" and row[rho_i] == "0":
                    clado_poly_no_ana_poly += 1
                if row[polyploid_i] == "0" and row[rho_i] != "0":
                    ana_poly_no_clado_poly += 1
                if row[polyploid_i] != "0" and row[rho_i] != "0":
                    both_poly += 1
                if row[polyploid_i] != "0" or row[rho_i] != "0":
                    either_poly += 1

maxx = most_common(bitstrings)
print("MAP model = " + maxx)
print("posterior of MAP = " + str( round( bitstrings.count(maxx) / float(samples), 2)))


print("\n total num samples = " + str(samples))
print("\nPosterior prob of models that include cladogenetic parameters:")
print("clado_demipoly = " + str( round( (samples - clado_demipoly) / float(samples), 2) ))
print("clado_fission = " + str( round( (samples - clado_fission) / float(samples), 2)))
print("clado_fusion = " + str( round( (samples - clado_fusion) / float(samples), 2)))
print("clado_polyploid = " + str( round( (samples - clado_polyploid) / float(samples), 2)))
print("\nPosterior prob of models that include anagenetic parameters:")
print("delta = " + str( round( (samples - delta) / float(samples), 2)))
print("delta_l = " + str( round( (samples - delta_l) / float(samples), 2)))
print("lambda = " + str( round( (samples - lambda_) / float(samples), 2)))
print("lambda_l = " + str( round( (samples - lambda_l) / float(samples), 2)))
print("mu = " + str( round( (samples - mu) / float(samples), 2)))
print("rho = " + str( round( (samples - rho) / float(samples), 2)))

print("\nOther probs:")
print("any poly (clado or ana) = " + str( round( either_poly / float(samples), 2)))
print("both clado and ana poly = " + str( round( both_poly / float(samples), 2)))
print("clado_poly_no_ana_poly = " + str( round( clado_poly_no_ana_poly / float(samples), 2)))
print("ana_poly_no_clado_poly = " + str( round( ana_poly_no_clado_poly / float(samples), 2)))

print("\nPosterior prob of models that are all cladogenetic or all anagenetic:")
print("all_clado = " + str( round( all_clado / float(samples), 2)))
print("all_ana = " + str( round( all_ana / float(samples), 2)))
