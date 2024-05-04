library(RevGadgets)
library(ggplot2)

args = commandArgs()
mcc_fn = "./output/out.mcc.tre"
out_fn = "./output/plot_mcc_tree.pdf"

# read in the tree 
mcc_tree <- readTrees(paths = mcc_fn)

# plot the MCC tree
mcc = plotTree(tree = mcc_tree, 
            timeline = T, 
            tip_labels_size = 3, 
            age_bars_width = 2,
            node_age_bars = T) + 
            theme(legend.position.inside = c(.05, .6),
                  legend.background = element_rect(fill="transparent"))

# write pdf file
pdf(out_fn, height=9, width=12)
print(mcc)
dev.off()
