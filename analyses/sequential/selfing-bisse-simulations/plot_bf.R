
library(dplyr)
library(ggplot2)

dep = read.delim("bf_dependent.tsv", header=FALSE)
ind = read.delim("bf_independent.tsv", header=FALSE)

names(dep) = c("rep", "bf", "z")
names(ind) = c("rep", "bf", "z")

n = 2 * ( dep %>% arrange(rep) %>% select(bf) - ind %>% arrange(rep) %>% select(bf) )

p = ggplot(n, aes(bf)) + geom_histogram(binwidth = 0.75) + 
    theme_classic(base_size=14) +
    xlab("2lnBF") + ylab("frequency") +
    geom_segment(aes(x=19.9, xend=19.9, y=2, yend=0), colour="salmon", arrow = arrow(length = unit(0.5, "cm"))) +
    geom_segment(aes(y=0, yend=10, x=6, xend=6), linetype="dotted", colour="grey") +
    geom_segment(aes(y=0, yend=10, x=10, xend=10), linetype="dashed", colour="grey") 

ggsave("bf_plot.pdf", p)

