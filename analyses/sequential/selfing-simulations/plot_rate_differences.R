
library(coda)

#burnin = 1000
burnin = 100

ess_values = vector()
rate_differences = vector()

for (i in 1:400) {

    in_file = paste("output/selfing", i, ".log", sep="")
    data = read.table(in_file, sep="\t", header=TRUE)

    x = as.mcmc(data$Posterior[burnin:length(data$Posterior)])
    ess_values = c(ess_values, effectiveSize(x))

    # calculate rate differences
    ex1 = HPDinterval(as.mcmc(data$extinction.1.[burnin:length(data$extinction.1.)]))
    ex2 = HPDinterval(as.mcmc(data$extinction.2.[burnin:length(data$extinction.2.)]))
    ex3 = HPDinterval(as.mcmc(data$extinction.3.[burnin:length(data$extinction.3.)]))
    ex4 = HPDinterval(as.mcmc(data$extinction.4.[burnin:length(data$extinction.4.)]))
    sp1 = HPDinterval(as.mcmc(data$speciation.1.[burnin:length(data$speciation.1.)]))
    sp2 = HPDinterval(as.mcmc(data$speciation.2.[burnin:length(data$speciation.2.)]))
    sp3 = HPDinterval(as.mcmc(data$speciation.3.[burnin:length(data$speciation.3.)]))
    sp4 = HPDinterval(as.mcmc(data$speciation.4.[burnin:length(data$speciation.4.)]))

    diff_ex_a = 0.0
    diff_ex_b = 0.0
    diff_sp_a = 0.0
    diff_sp_b = 0.0

    if (ex1[1] > ex2[2])
        diff_ex_a = ex1[1] - ex2[2]
    if (ex2[1] > ex1[2])
        diff_ex_a = ex2[1] - ex1[2]
    if (ex3[1] > ex4[2])
        diff_ex_b = ex3[1] - ex4[2]
    if (ex4[1] > ex3[2])
        diff_ex_b = ex4[1] - ex3[2]
    if (sp1[1] > sp2[2])
        diff_sp_a = sp1[1] - sp2[2]
    if (sp2[1] > sp1[2])
        diff_sp_a = sp2[1] - sp1[2]
    if (sp3[1] > sp4[2])
        diff_sp_b = sp3[1] - sp4[2]
    if (sp4[1] > sp3[2])
        diff_sp_b = sp4[1] - sp3[2]

    diff_sum = diff_ex_a + diff_ex_b + diff_sp_a + diff_sp_b
    rate_differences = c(rate_differences, diff_sum)

}

print(paste("Mean posterior ESS:", mean(ess_values)))
print("Rate difference estimated from observed data: 0.6416")
print("Rate differences estimated from simulated data:")
print(rate_differences)
z = ecdf(rate_differences)
print(paste("probability of observing smaller value:", z(0.6416)))
print(summary(z))
print(paste("num samples after burnin =", length(data$extinction.1.) - burnin))

