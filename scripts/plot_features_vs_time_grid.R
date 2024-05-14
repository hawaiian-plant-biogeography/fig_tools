# libraries
library(ggplot2)
library(reshape2)
#library(patchwork)
library(cowplot)


# arguments
my_args = commandArgs(trailingOnly=T)

feature_fn = "./input/hawaii_data/feature_summary.csv"
age_fn = "./input/hawaii_data/age_summary.csv"
desc_fn = "./input/hawaii_data/feature_description.csv"
region_names = "GNKOMHZ"

if (length(my_args) == 4) {
    feature_fn = my_args[1]
    age_fn = my_args[2]
    desc_fn = my_args[3]
    region_names = my_args[4]
}

# settings
low_color = "#eeeeff"
high_color = "#4444ff"
na_color = "#cccccc"

# read input
df_feature = read.csv(feature_fn, sep=",", header=T)
df_age = read.csv(age_fn, sep=",", header=T)
df_desc = read.csv(desc_fn, sep=",", header=T)

regions = strsplit(region_names, "")[[1]]
ages = c(0, df_age$mean_age, Inf)
num_regions = length(regions)
num_ages = length(df_age$mean_age) + 1

#print( df_feature[, c("feature_index","feature_relationship","feature_type")] )

col_names = c("feature_index", "feature_relationship", "feature_type")
feature_sets = df_feature[ !duplicated( df_feature[, col_names] ), col_names ]

for (i in 1:nrow(feature_sets)) {
    idx = feature_sets[i,1]
    rel = feature_sets[i,2]
    typ = feature_sets[i,3]
    desc = df_desc$description[ df_desc$index==idx & df_desc$relationship==rel & df_desc$type==typ ]

    row_idx = (df_feature$feature_index==idx & df_feature$feature_relationship==rel & df_feature$feature_type == typ)
    time_fn = df_feature$feature_path[row_idx]
    plot_fn = paste0("./output/out.feat_vs_time.idx_",idx,".rel_",rel,".typ_",typ,".pdf")

    title <- ggdraw() + 
      draw_label(desc, fontface = 'bold', x = 0, hjust = 0
      ) + theme( plot.margin = margin(0.5, 0.5, 0.5, 7) )
        # add margin on the left of the drawing canvas,
        # so title is aligned with left edge of first plot
    
    p_list = list()
    min_val = Inf
    max_val = -Inf
    for (j in 1:num_ages) {
        
        # read feature_set
        x = read.csv(time_fn[j], sep=",", header=T)
        if (nrow(x) == ncol(x)) {
            rownames(x) = colnames(x)
        }
        for (k in 1:ncol(x)) {
            x[is.nan(x[,k]),k] = NA
        }
        
        # plot inf
        min_val = min(c(min_val,min(x, na.rm=T)))
        max_val = max(c(max_val,max(x, na.rm=T)))
        zlim = c(min_val, max_val)
       
        ylab = paste0("Epoch ", j) #, "\n", ages[j], " to ", ages[j+1],)
            
        # convert to melted long format matrix
        m = melt(as.matrix(x))
        colnames(m) = c("region1", "region2", "value")
        m$region1 = factor(m$region1, ordered=T, levels=rev(regions))
        m$region2 = factor(m$region2, ordered=T, levels=regions)

        # make plot
        p = ggplot(m, aes(x=region2, y=region1, fill=value))
        p = p + geom_tile(color="black")
        p = p + geom_text(aes(label = round(value, 1)))
        p = p + xlab(NULL) + ylab(ylab)
        p = p + theme_bw()
        if (rel == "within") {
            p = p + theme(axis.text.y = element_blank(),
                          axis.ticks.y = element_blank())
        }
        p = p + theme(axis.line = element_blank(),
                      plot.background = element_blank(),
                      panel.grid.minor = element_blank(),
                      panel.grid.major = element_blank(),
                      panel.border = element_blank() )
        p = p + scale_fill_gradient(low=low_color, high=high_color, na.value=na_color, limits=zlim)
        if (j == num_ages) {
            p_legend = cowplot::get_legend(p)
        }
        p = p + theme(legend.position="none")
        p_list[[ length(p_list)+1 ]] = p
    }
    
    # collect info about plot size
    if (rel == "between") {
        h = num_ages * num_regions
    } else if (rel == "within") {
        h = num_ages
    }
    
    p_fig = cowplot::plot_grid(plotlist=p_list, ncol=1)
    p_tit = cowplot::plot_grid(title, p_fig, ncol=1, rel_heights=c(0.1, h))
    p_all = cowplot::plot_grid(p_tit, p_legend, ncol=2, rel_widths=c(10,1))
    #p_all = p_all + ggtitle(desc)
    p_all = p_all + theme(plot.margin=margin(2,2,2,2))

    pdf(plot_fn, width=num_regions, h)
    print(p_all)
    dev.off()

}
