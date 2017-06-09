
#
# Plot a density of the lag time from the loss of self-incompability
# to the time when net diversification goes negative.
#
# Will Freyman
#

library(coda)
library(ggplot2)


# recursive function to traverse up tree towards
# root looking for time of loss of self-incompatibility
get_time = function(iteration, parent, data) {

    d_iter = data[which(data$iteration == iteration),]
    d_parent = d_iter[which(d_iter$node_index == parent),]

    d_parent = d_parent[with(d_parent, order(transition_time)),]

    for (i in 1:nrow(d_parent)) {
        if (d_parent[i,]$start_state != 2) {
            return(d_parent[i,]$transition_time)
        }
    }

    grandparent = d_parent[i,]$parent_index
    
    return(get_time(iteration, grandparent, data))
}


# find all transitions from self-compatible B (state 2) to 
# self-compatible A (state 0)
data = read.table("output-20/test.tsv", header=TRUE, skip=0)
d1 = data[which(data$start_state == 2),]
d2 = d1[which(d1$end_state == 0),]

# now calculate the lag times for each transition
lag_times = vector()
for (i in 1:nrow(d2)) {

    iteration = d2[i,]$iteration
    parent = d2[i,]$parent_index

    d3 = data[which(data$iteration == iteration),]
    d4 = d3[which(d3$node_index == parent),]

    lag = get_time(iteration, parent, data) - d2[i,]$transition_time
    lag_times = c(lag, lag_times)

}


# finally plot results
pdf("lag_times.pdf", width=7, height=7)

mean_lag = mean(lag_times, na.rm=TRUE)
print(paste("mean lag = ", mean_lag))
df = data.frame(x=na.omit(lag_times))

p = ggplot(df, aes(x=x)) + geom_histogram(aes(y=..density..), binwidth=1, colour="darkgrey", fill=NA)
p = p + geom_density(alpha=0.4, adjust=2, colour="black", fill="honeydew4")
p = p + geom_vline(xintercept=mean_lag, linetype="dashed", colour="black")
p = p + labs(x="Millions of Years", y="Density")
print(p)


dev.off()

