################################################################################
#
# Summarizing RevBayes output
# 
#
# authors: Sebastian Hoehna, Will Freyman
#
########V########################################################################

library(coda)
library(ggplot2)
source("multiplot.R")

data <- read.table("output-lognormal/selfing1.log", header=TRUE, skip=0)

t <- c("C A", "I A", "C B", "I B")
l <- length(data$extinction.1.)
dat_ext  <- data.frame(dens=c(data$extinction.1., data$extinction.2., data$extinction.3., data$extinction.4.), State=rep(t, each=l))
dat_spec <- data.frame(dens=c(data$speciation.1., data$speciation.2., data$speciation.3., data$speciation.4.), State=rep(t, each=l))
dat_div  <- data.frame(dens=c(data$diversification.1., data$diversification.2., data$diversification.3., data$diversification.4.), State=rep(t, each=l))

pdf("spec_extinct_rates.pdf", width=7, height=6)

cols <- c("springgreen1", "springgreen4", "slateblue1", "slateblue4")
a <- c(0.3,0.6,0.3,0.6)

p1 <- ggplot(dat_spec, aes(x=dens, fill=State)) + labs(title = "Speciation", x="Rate", y="Posterior Density") + geom_density() + xlim(c(0, 2.0)) + scale_fill_manual(values=alpha(cols, a)) + theme_minimal()
p2 <- ggplot(dat_ext, aes(x=dens, fill=State)) + labs(title = "Extinction", x="Rate", y="Posterior Density") + geom_density() + xlim(c(0, 2.0)) + scale_fill_manual(values=alpha(cols, a)) + theme_minimal() + coord_cartesian(ylim=c(0, 20))
p3 <- ggplot(dat_div, aes(x=dens, fill=State)) + labs(title = "Net-Diversification", x="Rate", y="Posterior Density") + geom_density() + xlim(c(-0.5, 1.0)) + scale_fill_manual(values=alpha(cols, a)) + theme_minimal()


multiplot(p3, p1, p2)

dev.off()



