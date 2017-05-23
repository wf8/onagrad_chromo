library(plotrix)
library(phytools)

#character_file = "output/marginal_character.tree"
#posteriors_file = "output/marginal_posterior.tree"
character_file = "output-good/marginal_character.tree"
posteriors_file = "output-good/marginal_posterior.tree"

write_pdf = !FALSE
prompt = FALSE

if (write_pdf) {
    pdf("character_tree.pdf")
}

# first plot character

sim2 = read.simmap(file=character_file, format="phylip")

colors = vector()
for (i in 1:length( sim2$maps ) ) { 
    colors = c(colors, names(sim2$maps[[i]]) )
}
colors = sort(as.numeric(unique(colors)))

cols = setNames( rainbow(length(colors), start=0.0, end=1), colors)
#cols = setNames( rainbow(length(colors), start=0.07, end=0.9), colors)

plotSimmap(sim2, cols, fsize=0.124, lwd=1, split.vertical=TRUE)

#add.simmap.legend(colors=cols,vertical=TRUE, shape="circle", prompt=prompt, x=3, y=200)

x = 3
y = 210

if (prompt) {
    cat("Click where you want to draw the legend\n")
    x = unlist(locator(1))
    y = x[2]
    x = x[1]
}

fsize = 1

h = fsize * strheight(LETTERS[1])
w = par()$mfcol[2] * h * abs(diff(par()$usr[1:2])/diff(par()$usr[3:4]))

leg = names(cols)
colors = cols
y = y - 0:(length(leg) - 1) * 1.5 * h
x = rep(x + w/2, length(y))
text(x + w, y, leg, pos = 4, cex = fsize/par()$cex)

mapply(draw.circle, x = x, y = y, col = colors, MoreArgs = list(nv = 200, radius = w/2, border="white"))

if (!write_pdf) {
    invisible(readline(prompt="continue?"))
} else {
    dev.off()
}

# now plot posteriors

if (write_pdf) {
    pdf("posteriors_tree.pdf")
}

sim2 = read.simmap(file=posteriors_file, format="phylip")

colors = 1:100
    
cols = setNames( rainbow(length(colors), start=0.0, end=0.4), colors)

plotSimmap(sim2, cols, fsize=0.124, lwd=1, split.vertical=TRUE)

# add a legend to the posteriors plot
leg = c("0.0", "0.25", "0.5", "0.75", "1.0")
colors = c(rainbow(1, start=0.0), rainbow(1, start=0.1), rainbow(1, start=0.2), rainbow(1, start=0.3), rainbow(1, start=0.4))

x = 3
y = 200

if (prompt) {
    cat("Click where you want to draw the legend\n")
    x = unlist(locator(1))
    y = x[2]
    x = x[1]
}

fsize = 1

h = fsize * strheight(LETTERS[1])
w = par()$mfcol[2] * h * abs(diff(par()$usr[1:2])/diff(par()$usr[3:4]))

y = y - 0:(length(leg) - 1) * 1.5 * h
x = rep(x + w/2, length(y))
text(x + w, y, leg, pos = 4, cex = fsize/par()$cex)

mapply(draw.circle, x = x, y = y, col = colors, MoreArgs = list(nv = 200, radius = w/2, border="white"))

#legend( x="bottomleft", legend=c("0.0", "0.25", "0.5", "0.75", "1.0"), fill=c(rainbow(1, start=0.0), rainbow(1, start=0.1), rainbow(1, start=0.2), rainbow(1, start=0.3), rainbow(1, start=0.4)), bty="n")


if (write_pdf) {
    dev.off()
}
