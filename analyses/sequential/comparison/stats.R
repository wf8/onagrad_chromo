
library(ggplot2)

d = read.csv(file="data/polyploidization.csv", header=FALSE)

t.test(d[[1]],d[[2]], paired=FALSE)
t.test(d[[1]],d[[2]], paired=TRUE)

colnames(d) = c("SC", "SI")
d_stacked = stack(d)
colnames(d_stacked)[2] = "Mating System"

cols <- c("springgreen1", "slateblue1")

pdf("polyploidization_events.pdf", width=6, height=4)

p = ggplot(d_stacked, aes(x=values)) + geom_density(aes(group=`Mating System`, colour=`Mating System`, fill=`Mating System`), alpha=0.3)
p = p + scale_fill_manual(values=cols)
p = p + scale_colour_manual(values=cols)
p = p + labs(x = "Number of Polyploidization Events")
#p = ggplot(d_stacked, aes(y=values, x=ind)) + geom_violin(aes(group=ind, colour=ind, fill=ind), alpha=0.3)
print(p)

dev.off()
