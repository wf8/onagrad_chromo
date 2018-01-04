
#
# Plot a density of the lag time from the loss of self-incompability
# to the time when net diversification goes negative.
#
# Will Freyman
#

# mean lag = 1.96863
# mean num declines = 118.327


library(coda)
library(ggplot2)

input_file = "output/events.tsv"

# recursive function to traverse down tree towards
# tips looking for time of loss of self-incompatibility
get_times = function(data_iter, index, time_elapsed) {

    # get events for this node and order events by transition_time
    data_node = data_iter[which(data_iter$node_index == index),]
    data_node = data_node[order(data_node$transition_time, decreasing=TRUE),]

    branch_start_state = data_node[1,]$start_state
    branch_end_state = data_node[nrow(data_node),]$end_state
    if (is.na(branch_start_state))
        print(data_node)

    #first check to see if went from self-incompatible (state 1 or 3)
    # to self-compatible A (state 0) all on this branch, if so end recursion
    if (branch_start_state %in% c(1, 3) & branch_end_state == 0) {
        time_of_loss = 0
        time_of_decline = 0
        for (i in 1:nrow(data_node)) {
            if (data_node[i,]$start_state %in% c(1, 3) &
                data_node[i,]$end_state %in% c(0, 2) &
                time_of_loss == 0) {
                time_of_loss = data_node[i,]$transition_time
            }
            if (data_node[i,]$start_state %in% c(1, 2, 3) &
                data_node[i,]$end_state == 0 &
                time_of_decline == 0) {
                time_of_decline = data_node[i,]$transition_time
            }
            if (time_of_loss != 0 & time_of_decline != 0) {
                break
            }
        }
        return(time_of_loss - time_of_decline)
    }
    
    # check to see if we went from self-compatible B (state 2) to
    # self-compatible A (state 0), if so end recursion
    if (branch_start_state == 2 & branch_end_state == 0) {
        for (i in 1:nrow(data_node)) {
            if (data_node[i,]$end_state == 0) {
                time_elapsed = time_elapsed + 
                               data_node[i,]$branch_start_time - 
                               data_node[i,]$transition_time
                return(time_elapsed)
            }
        }
    }

    # now check to see if went from self-incompatible (state 1 or 3)
    # to self-compatible B (state 2) 
    if (branch_start_state %in% c(1, 3) & branch_end_state == 2) {
        for (i in 1:nrow(data_node)) {
            if (data_node[i,]$end_state == 2) {
                time_elapsed = data_node[i,]$transition_time - 
                               data_node[i,]$branch_end_time
                break
            }
        }
    }
    
    # recurse to children 
   if (!is.na(data_node[1,]$child1_index)) {
       lags1 = get_times(data_iter, data_node[1,]$child1_index, time_elapsed/2)
       lags2 = get_times(data_iter, data_node[1,]$child2_index, time_elapsed/2)
       return(c(lags1, lags2))
   }
}


#data = read.table(input_file, header=TRUE, skip=0)
iterations = unique(data$iteration)
root_index = max(data$node_index)
lag_times = vector()
n_iterations = length(iterations)
n_iterations = 1000
for (i in 1:n_iterations) {
    
    data_iter = data[which(data$iteration == iterations[i]),]
    lags = get_times(data_iter, root_index, 0)
    lag_times = c(lags, lag_times)


}

# finally plot results
pdf("lag_times.pdf", width=5, height=5)

mean_lag = mean(lag_times, na.rm=TRUE)
print(paste0("mean lag = ", mean_lag))
print(paste0("mean num declines = ", length(lag_times)/n_iterations))
df = data.frame(x=na.omit(lag_times))
write.csv(df, file="lag_times.csv")

p = ggplot(df, aes(x=x)) + geom_histogram(aes(y=..density..), binwidth=1, colour="darkgrey", fill=NA)
p = p + geom_density(alpha=0.4, adjust=2, colour="black", fill="honeydew4")
p = p + geom_vline(xintercept=mean_lag, linetype="dashed", colour="black")
p = p + labs(x="Millions of Years", y="Density")
p = p + theme_minimal() + xlim(0, 15)
print(p)


dev.off()

