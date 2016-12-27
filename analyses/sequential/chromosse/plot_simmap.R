library(plotrix)
library(phytools)

plot_posteriors = FALSE

#pdf("tree.pdf")

if (!plot_posteriors) {

    sim2 = read.simmap(file="character.tree",format="phylip")
    
    colors = vector()
    for (i in 1:length( sim2$maps ) ) { 
        colors = c(colors, names(sim2$maps[[i]]) )
    }
    colors = sort(as.numeric(unique(colors)))

} else {

    sim2 = read.simmap(file="posterior.tree",format="phylip")

    colors = 1:100
}


#max_chromo = 26
#cols = setNames( rainbow(max_chromo), 1:max_chromo)

if (!plot_posteriors) {
    cols = setNames( rainbow(length(colors), start=0.07, end=0.9), colors)
} else {
    cols = setNames( rainbow(length(colors), start=0.0, end=0.4), colors)
}

plotSimmap(sim2, cols, fsize=0.124, lwd=1, split.vertical=TRUE)

if (!plot_posteriors) {
    add.simmap.legend(colors=cols,vertical=TRUE, shape="circle", prompt=TRUE)
} else {

    leg = c("0.0", "0.25", "0.5", "0.75", "1.0")
    colors = c(rainbow(1, start=0.0), rainbow(1, start=0.1), rainbow(1, start=0.2), rainbow(1, start=0.3), rainbow(1, start=0.4))

    x = 0
    y = 0

    cat("Click where you want to draw the legend\n")
    x <- unlist(locator(1))
    y <- x[2]
    x <- x[1]

    fsize = 1

    h <- fsize * strheight(LETTERS[1])
    w <- par()$mfcol[2] * h * abs(diff(par()$usr[1:2])/diff(par()$usr[3:4]))

    y <- y - 0:(length(leg) - 1) * 1.5 * h
    x <- rep(x + w/2, length(y))
    text(x + w, y, leg, pos = 4, cex = fsize/par()$cex)

    mapply(draw.circle, x = x, y = y, col = colors, MoreArgs = list(nv = 200, radius = w/2))

    #legend( x="bottomleft", legend=c("0.0", "0.25", "0.5", "0.75", "1.0"), fill=c(rainbow(1, start=0.0), rainbow(1, start=0.1), rainbow(1, start=0.2), rainbow(1, start=0.3), rainbow(1, start=0.4)), bty="n")
}
#dev.off()

