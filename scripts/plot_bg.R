library(RevGadgets)
library(ggplot2)

mcc_file = "../../output/Kadua_rj_8_10_103.mcc.tre"
state_file = "../../output/Kadua_rj_8_10_103.states.tre"

# Create the labels vector
regions = c("R", "K", "O", "M", "H", "Z")
df_states = read.csv("state_labels.n6.txt", colClasses=c("range"="character"))
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

# pass the labels vector and file name to the processing script
anc_tree <- processAncStates(state_file, state_labels = labs)

# read in the tree 
mcc_tree <- readTrees(paths = mcc_file)

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
  theme(legend.position = c(0.95, 0.7) )

pdf("kadua_anc_pie.pdf", height=9, width=12)
print(pie)
dev.off()

map <- plotAncStatesMAP(t = anc_tree,
                        # Include cladogenetic events
                        cladogenetic = T,
                        # Pass in the same color vector
                        node_color = colors,
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
  theme(legend.position = c(0.95, 0.36) )

pdf("kadua_anc_map.pdf", height=9, width=12)
print(map)
dev.off()


# plot the FBD tree
mcc = plotTree(tree = mcc_tree, 
            timeline = T, 
            tip_labels_size = 3, 
            age_bars_width = 2,
            node_age_bars = T) + 
    # use ggplot2 to move the legend and make 
    # the legend background transparent
        theme(legend.position=c(.05, .6),
              legend.background = element_rect(fill="transparent"))

pdf("kadua_mcc_hpd.pdf", height=9, width=12)
print(mcc)
dev.off()
