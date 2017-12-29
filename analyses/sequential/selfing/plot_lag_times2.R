
#
# Plot a density of the lag time from the loss of self-incompability
# to the time when net diversification goes negative.
#
# Will Freyman
#

library(coda)
library(ggplot2)

input_file = "output/events.tsv"

# recursive function to traverse up tree towards
# root looking for time of loss of self-incompatibility
get_time = function(parent, data_iter, end_time, total_time, depth) {

    d_parent = data_iter[which(data_iter$node_index == parent),]

    d_parent = d_parent[with(d_parent, order(transition_time)),]

    for (i in 1:nrow(d_parent)) {
        if (d_parent[i,]$start_state != 2 & d_parent[i,]$end_state == 2) {
            this_time = d_parent[i,]$transition_time - end_time
            return(total_time + this_time / 2^depth)
        }
    }

    grandparent = d_parent[1,]$parent_index
    if (is.na(grandparent)) {
        return(NA)
    }

    this_time = d_parent[1,]$branch_start_time - end_time
    total_time = total_time + this_time / 2^depth  
    return(get_time(grandparent, data_iter, d_parent[1,]$branch_start_time, total_time, depth + 1))
}


# find all transitions from self-compatible B (state 2) to 
# self-compatible A (state 0)
data = read.table(input_file, header=TRUE, skip=0)
d2 = data[which(data$end_state == 0 & data$start_state == 2),]

# now calculate the lag times for each transition
lag_times = vector()
for (i in 1:nrow(d2)) {
#for (i in 1:1000) {
    
    iteration = d2[i,]$iteration
    parent = d2[i,]$parent_index

    data_iter = data[which(data$iteration == iteration),]

    lag = get_time(parent, data_iter, d2[i,]$transition_time, 0, 0)
    lag_times = c(lag, lag_times)

}


# finally plot results
pdf("lag_times.pdf", width=5, height=5)

mean_lag = mean(lag_times, na.rm=TRUE)
print(paste0("mean lag = ", mean_lag))
print(paste0("num declines = ", length(lag_times)))
df = data.frame(x=na.omit(lag_times))
write.csv(df, file="lag_times.csv")

p = ggplot(df, aes(x=x)) + geom_histogram(aes(y=..density..), binwidth=1, colour="darkgrey", fill=NA)
p = p + geom_density(alpha=0.4, adjust=2, colour="black", fill="honeydew4")
p = p + geom_vline(xintercept=mean_lag, linetype="dashed", colour="black")
p = p + labs(x="Millions of Years", y="Density")
p = p + theme_minimal() + xlim(0, 50)
print(p)


dev.off()

