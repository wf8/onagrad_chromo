

library(ggtree)

# from https://github.com/GuangchuangYu/ggtree/blob/master/R/tree-utilities.R
getXcoord2 <- function(x, root, parent, child, len, start=0, rev=FALSE) {
    x[root] <- start
    x[-root] <- NA  ## only root is set to start, by default 0
        
    currentNode <- root
    direction <- 1
    if (rev == TRUE) {
        direction <- -1
    }
    while(anyNA(x)) {
        idx <- which(parent %in% currentNode)
        newNode <- child[idx]
        x[newNode] <- x[parent[idx]]+len[idx] * direction
        currentNode <- newNode
    }

    return(x)
}

# from https://github.com/GuangchuangYu/ggtree/blob/master/R/tree-utilities.R
getXcoord <- function(tr) {
    edge <- tr$edge
    parent <- edge[,1]
    child <- edge[,2]
    root <- getRoot(tr)

    len <- tr$edge.length

    N <- getNodeNum(tr)
    x <- numeric(N)
    x <- getXcoord2(x, root, parent, child, len)
    return(x)
}

# from https://github.com/GuangchuangYu/ggtree/blob/master/R/tree-utilities.R
getYcoord <- function(tr, step=1) {
    Ntip <- length(tr[["tip.label"]])
    N <- getNodeNum(tr)

    edge <- tr[["edge"]]
    parent <- edge[,1]
    child <- edge[,2]

    cl <- split(child, parent)
    child_list <- list()
    child_list[as.numeric(names(cl))] <- cl
    
    y <- numeric(N)
    tip.idx <- child[child <= Ntip]
    y[tip.idx] <- 1:Ntip * step
    y[-tip.idx] <- NA

    currentNode <- 1:Ntip
    while(anyNA(y)) {
        pNode <- unique(parent[child %in% currentNode])
        ## piping of magrittr is slower than nested function call.
        ## pipeR is fastest, may consider to use pipeR
        ##
        ## child %in% currentNode %>% which %>% parent[.] %>% unique
        ## idx <- sapply(pNode, function(i) all(child[parent == i] %in% currentNode))
        idx <- sapply(pNode, function(i) all(child_list[[i]] %in% currentNode))
        newNode <- pNode[idx]
        
        y[newNode] <- sapply(newNode, function(i) {
            mean(y[child_list[[i]]], na.rm=TRUE)
            ##child[parent == i] %>% y[.] %>% mean(na.rm=TRUE)           
        })
        
        currentNode <- c(currentNode[!currentNode %in% unlist(child_list[newNode])], newNode)
        ## currentNode <- c(currentNode[!currentNode %in% child[parent %in% newNode]], newNode)
        ## parent %in% newNode %>% child[.] %>%
        ##     `%in%`(currentNode, .) %>% `!` %>%
        ##         currentNode[.] %>% c(., newNode)
    }
    
    return(y)
}

# from https://github.com/GuangchuangYu/ggtree/blob/master/R/tree-utilities.R
getParent <- function(tr, node) {
    if ( node == getRoot(tr) )
        return(0)
    edge <- tr[["edge"]]
    parent <- edge[,1]
    child <- edge[,2]
    res <- parent[child == node]
    if (length(res) == 0) {
        stop("cannot found parent node...")
    }
    if (length(res) > 1) {
        stop("multiple parent found...")
    }
    return(res)
}

# read in tree
t = read.beast("output/ancestral_states_results.tree")
tree = attributes(t)$phylo
n_node = getNodeNum(tree)

# set the root's start state to NA
attributes(t)$stats$start_state_1[n_node] = NA

# get chromosome counts to display on the tip
counts = read.table("data/chromosome_counts.csv", sep=",", header=FALSE, stringsAsFactor=FALSE)
names(counts) = c("taxa", "count")

# add the chromosome counts to tip labels
for (i in 1:length(attributes(t)$phylo$tip.label)) {
    count = counts$count[ counts$taxa==attributes(t)$phylo$tip.label[i] ]
    if (count == "?")
        new_label = paste(count, attributes(t)$phylo$tip.label[i], sep="    ")
    else
        #if (as.numeric(as.character(count)) >= 10)
        if (as.numeric(count) >= 10)
            new_label = paste(count, attributes(t)$phylo$tip.label[i], sep="  ")
        else
            new_label = paste(count, attributes(t)$phylo$tip.label[i], sep="    ")
    attributes(t)$phylo$tip.label[i] = paste(" ", new_label, sep="")
}

# remove underscores
attributes(t)$phylo$tip.label = gsub("_", " ", attributes(t)$phylo$tip.label)

# add tip labels
#p = ggtree(t, size=.1) + geom_tiplab(align=TRUE, size=.75, linesize = 0.05) + ggplot2::xlim(0, 200) 
p = ggtree(t, size=.5) + ggplot2::xlim(0, 200) 

# add ancestral chromosome counts on internal nodes
#p = p + geom_text(aes(label=end_state_1, hjust=-.5), size=.75)

# add clado daughter lineage start states on "shoulders" of tree
# get x, y coordinates of all nodes
x = getXcoord(tree)
y = getYcoord(tree)
x_anc = numeric(n_node)
for (i in 1:n_node) {
    if (getParent(tree, i) != 0) {
        # if not the root, get the x coordinate for the parent node
        x_anc[i] = x[getParent(tree, i)]
    }
}
# plot the states on the "shoulders"
#p = p + geom_text(aes(label=start_state_1, x=x_anc, y=y, hjust=1.5), size=0.75)

# show chromo number as size / posteriors as color
p = p + geom_nodepoint(aes(colour=end_state_1_pp, size=end_state_1), alpha=.3) +
        scale_size(range = c(3, 10)) +
        scale_colour_gradient2(low="#D55E00", mid="#F0E442", high="#009E73", limits=c(0.0, 1), midpoint =0.5) +
        guides(colour = guide_legend("Posterior probability", override.aes = list(size=8)), 
                size = guide_legend("Chromosome number", legend=c("6","10","12","16")))

# add a time scale
root_age = 111.2643

p = p + theme_tree2() +
        scale_x_continuous(breaks=c(111.2643, 61.2643, 11.2643), minor_breaks=c(101.26, 91.26, 81.26, 71.26, 51.26, 41.26,31.26,21.26,1.26), labels=c("0", "50", "100")) +
        theme(panel.grid.major   = element_line(color="grey18", size=.2),
              panel.grid.minor   = element_line(color="grey28", size=.2, linetype="dashed"),
              panel.grid.major.y = element_blank(),
              panel.grid.minor.y = element_blank(),
              legend.position="left")

ggsave("ancestral_states_zoom_out.pdf", width = 12, height = 9)
print(p)
