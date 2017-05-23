
library(coda)
library(ggplot2)

data <- read.table("output/combined.log", header=TRUE, skip=0)

t <- c("clado_demipoly", "clado_fusion", "clado_fission", "clado_polyploid", "delta", "eta", "gamma", "rho")

l = length(data$clado_demipoly)
data_rates  <- data.frame(dens=c(data$clado_demipoly, data$clado_fusion, data$clado_fission, data$clado_polyploid, data$delta, data$eta, data$gamma, data$rho), Parameter=rep(t, each=l))
data_rates$Parameter <- factor(data_rates$Parameter,
                        levels = c("clado_fission", "clado_fusion", "clado_polyploid", "clado_demipoly", "gamma", "delta", "rho", "eta"),ordered = TRUE)

pdf("chromosome_rates.pdf")

p1 = ggplot(data_rates, aes(factor(Parameter), dens, fill=Parameter)) + labs(x="chromosome evolution parameters", y="rate (transitions per million years)") + geom_violin(scale = "width",adjust = .75, width=0.8) + theme_minimal() + theme(text=element_text(size=16))

p1 = p1 + geom_segment(aes(x=0.75, y=0.0008, xend=1.25, yend=0.0008, color="red"), linetype="dotted")
p1 = p1 + geom_segment(aes(x=0.75, y=0.0, xend=1.25, yend=0.0, color="red"), linetype="dotted")
p1 = p1 + geom_segment(aes(x=1.75, y=0.0013, xend=2.25, yend=0.0013, color="red"), linetype="dotted")
p1 = p1 + geom_segment(aes(x=1.75, y=0.0, xend=2.25, yend=0.0, color="red"), linetype="dotted")
p1 = p1 + geom_segment(aes(x=2.75, y=0.0074, xend=3.25, yend=0.0074, color="red"), linetype="dotted")
p1 = p1 + geom_segment(aes(x=2.75, y=0.00084, xend=3.25, yend=0.00084, color="red"), linetype="dotted")
p1 = p1 + geom_segment(aes(x=3.75, y=0.00344, xend=4.25, yend=0.00344, color="red"), linetype="dotted")
p1 = p1 + geom_segment(aes(x=3.75, y=0.0, xend=4.25, yend=0.0, color="red"), linetype="dotted")
p1 = p1 + geom_segment(aes(x=4.75, y=0.0012, xend=5.25, yend=0.0012, color="red"), linetype="dotted")
p1 = p1 + geom_segment(aes(x=4.75, y=0.0, xend=5.25, yend=0.0, color="red"), linetype="dotted")
p1 = p1 + geom_segment(aes(x=5.75, y=0.0063, xend=6.25, yend=0.0063, color="red"), linetype="dotted")
p1 = p1 + geom_segment(aes(x=5.75, y=0.0023, xend=6.25, yend=0.0023, color="red"), linetype="dotted")
p1 = p1 + geom_segment(aes(x=6.75, y=0.0079, xend=7.25, yend=0.0079, color="red"), linetype="dotted")
p1 = p1 + geom_segment(aes(x=6.75, y=0.0, xend=7.25, yend=0.0, color="red"), linetype="dotted")
p1 = p1 + geom_segment(aes(x=7.75, y=0.0047, xend=8.25, yend=0.0047, color="red"), linetype="dotted")
p1 = p1 + geom_segment(aes(x=7.75, y=0.0, xend=8.25, yend=0.0, color="red"), linetype="dotted")

clado = 0.1
ana = 0.7
a = c(clado, clado, clado, clado, ana, ana, ana, ana)
p1 = p1 + scale_fill_manual(values=alpha("grey", a)) + guides(fill=FALSE, colour=FALSE)

greek_labels = c(expression(gamma[c]), expression(delta[c]), expression(rho[c]),
                 expression(eta[c]), expression(gamma[a]), expression(delta[a]),
                 expression(rho[a]), expression(eta[a]))


print(p1 + scale_x_discrete(labels=greek_labels))
dev.off()

