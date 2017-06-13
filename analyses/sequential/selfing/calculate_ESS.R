
library(coda)

burnin = 1000

ess_values = vector()

for (i in 1:200) {

    in_file = paste("output/selfing", i, ".log", sep="")
    data = read.table(in_file, sep="\t", header=TRUE)

    x = as.mcmc(data$Posterior[burnin:length(data$Posterior)])
    ess_values = c(ess_values, effectiveSize(x))

}

print(mean(ess_values))
