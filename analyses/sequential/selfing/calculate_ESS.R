
library(coda)

read.table("combined.log", header=TRUE)

HPDinterval(as.mcmc(log$rate_BA))
mean(log$rate_BA)

HPDinterval(as.mcmc(log$speciation.1)
