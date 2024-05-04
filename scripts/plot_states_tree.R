library(RevGadgets)
library(ggplot2)

mcc_fn = "./output/out.mcc.tre"
state_fn = "./output/out.states.tre"
plot_anc_pie_fn = "./output/out.states_prob.pdf"
plot_anc_map_fn = "./output/out.states_map.pdf"
labels_fn = "./input/kadua_data/kadua_range_label.csv"
region_names = "GNKOMHZ"

args = commandArgs(trailingOnly=T)
print(args)
if (length(args) > 0) {
    labels_file = args[1]
    region_names = args[2]
}

# Create the labels vector
regions = unlist(strsplit(region_names, "")[[1]])
df_states = read.csv(labels_fn, colClasses=c("range"="character"))
labs = rep(NA, nrow(df_states))
for (i in 1:nrow(df_states)) {
    # get range strings
    x = df_states$range[i]
    # convert into range bit-vectors
    s = as.numeric(strsplit(x=x,split="")[[1]])
    # convert into region-set strings
    y = paste0(regions[which(s==1)], collapse="")
    labs[i] = y
}
names(labs) = as.character( 0:(nrow(df_states)-1))
print(labs)

# pass the labels vector and file name to the processing script
anc_tree <- processAncStates(state_fn, state_labels = labs)

# read in the tree 
mcc_tree <- readTrees(paths = mcc_fn)

# Uncomment to see states needing color assignments
#print(anc_tree@state_labels)

# Manually define colors
# colors=c(
#     "Z"="black",
#     "R"="#e7298a",
#     "K"="#e6ab02",
#     "O"="#1b9e77",
#     "M"="royalblue",
#     "H"="yellow",
#     "RZ"="red",
#     "RK"="darkblue",
#     "KM"="yellow",
#     "KO"="orchid",
#     "OM"="green",
#     "MH"="tomato",
#     "KOM"="cyan",
#     "OMH"="darkgreen",
#     "KOMH"="cadetblue3")


# Plot the results with pies at nodes
pie <- plotAncStatesPie(t = anc_tree,
                        # Include cladogenetic events
                        cladogenetic = TRUE, 
                        # Add text labels to the tip pie symbols
                        tip_labels_states = TRUE,
                        # Offset those text labels slightly
                        tip_labels_states_offset = .4,
                        # Pass in your named and ordered color vector
                        # pie_colors = colors, 
                        # Offset the tip labels to make room for tip pies
                        tip_labels_offset = .7, 
                        # Move tip pies right slightly 
                        tip_pie_nudge_x = .1,
                        # Change the size of node and tip pies  
                        tip_pie_size = 0.8,
                        node_pie_size = 1.2,
                        shoulder_pie_size = 0.7,
                        # opaque colors
                        state_transparency = 1.0,
                        timeline = TRUE) +
  # Move the legend 
  theme(legend.position.inside = c(0.95, 0.7) )

pdf(plot_anc_pie_fn, height=9, width=12)
print(pie)
dev.off()

map <- plotAncStatesMAP(t = anc_tree,
                        # Include cladogenetic events
                        cladogenetic = T,
                        # Pass in the same color vector
                        # node_color = colors,
                        # Print tip label states
                        tip_labels_states = TRUE,
                        # Offset those text labels slightly
                        tip_labels_states_offset = .2,
                        # adjust tip labels
                        tip_labels_offset = 0.8,
                        # increase tip states symbol size
                        tip_states_size = 3,
                        shoulder_states_size = 3,
                        # opaque colors
                        state_transparency = 1.0,
                        timeline = TRUE) +
  # adjust legend position and remove color guide
  theme(legend.position.inside = c(0.95, 0.36) )

pdf(plot_anc_map_fn, height=9, width=12)
print(map)
dev.off()


