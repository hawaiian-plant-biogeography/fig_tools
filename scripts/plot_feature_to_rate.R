# libraries
library(ggplot2)
library(reshape2)
#library(patchwork)
library(cowplot)
# library(rjson)
library(data.table)
library(HDInterval)
library(igraph)


# arguments
my_args = commandArgs(trailingOnly=T)

feature_fn = "./input/hawaii_data/feature_summary.csv"
age_fn = "./input/hawaii_data/age_summary.csv"
desc_fn = "./input/hawaii_data/feature_description.csv"
res_fn = "./input/results/Kadua_crash_M1_777"
json_fn = "./input/results/Kadua_M1_100.param.json"
mdl_fn = "./input/results/Kadua_M1_213.model.txt"
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


# files
res_fp = "./input/results"
res_prefix = "Kadua_crash_M1_777"
res_pattern = paste0(res_prefix, ".time.*")
files = list.files(path=res_fp, pattern=res_pattern, full.names=T)

regions = strsplit(region_names, "")[[1]]
ages = c(0, df_age$mean_age, 22)
num_regions = length(regions)
num_ages = length(df_age$mean_age) + 1

proc = c("d", "e", "w", "b")
f_burn = 0.1
n_burn = NA # as.integer(f_burn * (length(json_all)-1)) + 1
thin_by = 10

# collect posterior traces
df_time = list()
for (i in 1:length(files)) {
    df = read.csv(files[i], header=T, sep="\t")

    if (is.na(n_burn)) {
        n_burn = as.integer(f_burn * nrow(df))
    }

    df = df[(n_burn+1):nrow(df), ]
    df_time[[i]] = df
}

df_all = read.csv(mdl_fn, sep="\t", head=T)
df_eff = df_all[ , grepl("(^phi)|(^sigma)", names(df_all))]


param_node = names(df_eff)
param_desc = c()
for (i in 1:length(param_node)) {
    
    z = gsub("\\.", "_", param_node[i])
    tok = strsplit(z, split="_")[[1]]
    
    typ = ifelse(tok[1] == "phi", "quantitative", "categorical")
    rel = ifelse(tok[2] %in% c("e", "w"), "within", "between")
    idx = as.numeric(tok[3])
    
    
    y = c(idx, rel, typ, tok[1], tok[2], param_node[i])
    print(y)
    
    param_desc = rbind(param_desc, y)
}


df_param_desc = data.frame(param_desc)
rownames(df_param_desc)=NULL
colnames(df_param_desc)=c("idx","rel","typ","letter","process","param")


# sort for plotting purposes
sort_idx = order(df_param_desc$typ, df_param_desc$rel, df_param_desc$idx)
df_param_desc = df_param_desc[sort_idx, ]
param_node_sort = df_param_desc$param

coverage = 0.8
df_mean = colMeans(df_eff)
df_hdi = apply(df_eff, 2, function(x) { hdi(x, credMass=coverage) } )



proc_node = c("m_b","m_d","m_e","m_w")

m = matrix(0, ncol=length(proc_node), nrow=length(param_node_sort))
rownames(m) = param_node_sort
colnames(m) = proc_node

for (i in 1:length(df_mean)) {
    n = names(df_mean)[i]
    j = paste0("m_", df_param_desc$process[df_param_desc$param == n])
    m[n,j] = df_mean[i]
}

all_names = c(param_node_sort, proc_node)

#g1 <- graph.adjacency(cor1$r, weighted=TRUE, mode="lower")

g1 = graph_from_incidence_matrix(m, weighted=T)

layout = matrix(data=NA, nrow=length(all_names), ncol=2)
rownames(layout) = all_names
q_idx = which(grepl("^phi", V(g1)$name))
c_idx = which(grepl("^sigma", V(g1)$name))
m_idx = which(grepl("^m", V(g1)$name))
layout[q_idx,2] = -2
layout[m_idx,2] = 0
layout[c_idx,2] = 2
layout[q_idx,1] = -(1:length(q_idx))
layout[c_idx,1] = -(1:length(c_idx))
layout[m_idx,1] = -(1:length(proc_node))
layout[m_idx,1] = layout[m_idx,1] * 2 + 1/2
layout = layout[,2:1]


#layout2 <- layout_as_bipartite(g1)
#layout2[,2] = abs(layout2[,2] - 1)


#g1 <- delete_edges(g1, E(g1)[ abs(weight) < 0.1 ])
plot.igraph(g1, 
    layout=layout,
    vertex.shape="rectangle",
    vertex.size=(strwidth(V(g1)$label) + strwidth("oo")) * 500,
    vertex.size2=strheight("I") * 2 * 100,
    vertex.color=c("green","cyan")[V(g1)$type+1],
    vertex.label.family = "sans",
    vertex.label.color="black",
    edge.width=abs(E(g1)$weight)*8, 
    edge.color=ifelse(E(g1)$weight > 0, "#ffaaaa","#aaaaff"),
    edge.label.family = "sans",
    # edge.label=ifelse(E(g1)$weight > 0, "+","-"),
    edge.label=round( E(g1)$weight, digits=2 ),
    edge.label.dist=10,
    edge.label.color="black",
    #edge.label.degree=pi/2,
    rescale=F,
    xlim=c(-3, 3),
    ylim=c( min(layout[,2]), max(layout[,2]) ))


par(mar=c(0,0,0,0)+.1)

qfeat = c("Distance (km)",  "Log distance (km)", "Altitude (m)", "Log altitude (m)")
cfeat = c("In/out Hawaii?", "Into younger?", "Young island?",  "Net growth?")

text( x=-5, y=-(1:4)*2 + 1/2, qfeat, adj=0)
text( x=5, y=-(1:4)*2 + 1/2, cfeat, adj=1)

###############



df_rate = list()
min_rate = c("w"=Inf, "e"=Inf, "d"=Inf, "b"=Inf)
max_rate = -min_rate

for (p in proc) {
    pattern = paste0("r_", p)
    idx = grepl(pattern=paste0("r_",p), names(df))
    df_p = df_mean[idx]
    df_p = df_p[ sort(names(df_p)) ]
    
    r_t = list()
    
    offset = c(1,num_regions)
    if (p == "b" || p == "d") {
        offset = c(num_regions, num_regions)
    }
    
    for (i in 1:num_ages) {
        j = (i-1) * prod(offset) + 1
        k = j + prod(offset) - 1
        r = df_p[j:k]
        # hacky fix: better to read in the NA from region features
        r[r == 0] = NA
        r[r > 20] = NA     
        m = matrix(r, nrow=offset[1], ncol=offset[2], byrow=T)
        colnames(m) = regions
        if (ncol(m) == nrow(m)) {
            rownames(m) = regions
        } else {
            rownames(m) = c("G")
        }
        r_t[[i]] = m
        
        if (min(m, na.rm=T) < min_rate[p]) min_rate[p] = min(m, na.rm=T)
        if (max(m, na.rm=T) > max_rate[p]) max_rate[p] = max(m, na.rm=T)
    }
    
    df_rate[[p]] = r_t
}


for (y in proc) {
    
    desc = paste0("r_", y, "(t)")
    title <- ggdraw() +
      draw_label(desc, fontface = 'bold', x = 0, hjust = 0
      ) + theme( plot.margin = margin(0.5, 0.5, 0.5, 7) )
        
    plot_fn = paste0("./output/rate_vs_time_process_", y, ".pdf")
    p_list = list()
    for (j in 1:num_ages) {
        x = df_rate[[y]][[j]]
        # convert to melted long format matrix
        m = melt(as.matrix(x))
        colnames(m) = c("region1", "region2", "value")
        m$region1 = factor(m$region1, ordered=T, levels=rev(regions))
        m$region2 = factor(m$region2, ordered=T, levels=regions)

        
        ylab = paste0("Epoch ", j) #, "\n", ages[j], " to ", ages[j+1],)
        
        # make plot
        p = ggplot(m, aes(x=region2, y=region1, fill=value))
        p = p + geom_tile(color="black")
        p = p + geom_text(aes(label = round(value, 2)))
        p = p + xlab(NULL) + ylab(ylab)
        p = p + theme_bw()
        if (y == "w" || y == "e") {
            p = p + theme(axis.text.y = element_blank(),
                          axis.ticks.y = element_blank())
        }
        p = p + theme(axis.line = element_blank(),
                      plot.background = element_blank(),
                      panel.grid.minor = element_blank(),
                      panel.grid.major = element_blank(),
                      panel.border = element_blank() )
        p = p + scale_fill_gradient(low=low_color, high=high_color, na.value=na_color,
            limits=c(min_rate[y], max_rate[y]))
        if (j == num_ages) {
            p_legend = cowplot::get_legend(p)
        }
        p = p + theme(legend.position="none")
        p_list[[ length(p_list)+1 ]] = p
    }
    # collect info about plot size
    if (y == "d" || y == "b") {
        h = num_ages * num_regions
    } else if (y == "w" || y == "e") {
        h = num_ages
    }

    p_fig = cowplot::plot_grid(plotlist=p_list, ncol=1)
    p_tit = cowplot::plot_grid(title, p_fig, ncol=1, rel_heights=c(0.1, h))
    p_all = cowplot::plot_grid(p_tit, p_legend, ncol=2, rel_widths=c(10,1))
    #p_all = p_all + ggtitle(desc)
    p_all = p_all + theme(plot.margin=margin(2,2,2,2))

    pdf(plot_fn, width=num_regions, height=h)
    print(p_all)
    dev.off()
    
}


df_all = data.frame()
for (y in proc) {
    for (i in 1:num_ages) {
        d = dim(df_rate[[y]][[i]])
        for (j in 1:d[1]) {
            for (k in 1:d[2]) {
                dk = (k-3) * 0.05
                if (i != num_ages) {
                    row = c(y, ages[i]+dk, ages[i+1]+dk, regions[j], regions[k], df_rate[[y]][[i]][j,k], df_rate[[y]][[i+1]][j,k])
                } else {
                    row = c(y, ages[i]+dk, ages[i+1]+dk, regions[j], regions[k], df_rate[[y]][[i]][j,k], df_rate[[y]][[i]][j,k])
                }
                df_all = rbind(df_all, row)
            }
        }
    }
}
colnames(df_all) = c("process","age1","age2","region1","region2","rate1", "rate2")
df_all$rate1 = as.numeric(df_all$rate1)
df_all$rate2 = as.numeric(df_all$rate2)
df_all$age1 = as.numeric(df_all$age1)
df_all$age2 = as.numeric(df_all$age2)
#df_all$region1 = factor(df_all$region1, order=T, levels=regions)
#df_all$region2 = factor(df_all$region2, order=T, levels=regions)

df_w = df_all[ df_all$process == "w", ] # & df_all$region2 == "G", ]
df_e = df_all[ df_all$process == "e", ] # & df_all$region2 == "G", ]
df_div = df_w
df_div$rate1 = df_div$rate1 - df_e$rate1
df_div$rate2 = df_div$rate2 - df_e$rate2

pp = ggplot(df_div, aes(x=age1, xend=age2, color=region2, y=rate1, yend=rate1))
pp = pp + geom_segment()
pp = pp + geom_segment( aes(x=age2, xend=age2, color=region2, y=rate1, yend=rate2))
pp = pp + geom_point( aes(x=age2, y=rate1), size=1/2 )
pp = pp + geom_point( aes(x=age1, y=rate1), size=1/2 )
pp = pp + theme_bw()
pp = pp + xlab("Age (Ma)") + ylab("r_w(i,t) - r_e(i,t)")
pp = pp + ggtitle("Within-region net div. rates over time")
pp
