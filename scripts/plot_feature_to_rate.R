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

feature_fn   = "./example_input/hawaii_data/feature_summary.csv"
age_fn       = "./example_input/hawaii_data/age_summary.csv"
desc_fn      = "./example_input/hawaii_data/feature_description.csv"
model_fn     = "./example_input/results/divtime_timefig.model.txt"
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
df_all = read.csv(model_fn, sep="\t", head=T)
df_eff = df_all[ , grepl("(^phi)|(^sigma)", names(df_all))]

# dataset info
regions = strsplit(region_names, "")[[1]]
num_regions = length(regions)

proc = c("d", "e", "w", "b")
f_burn = 0.1
n_burn = NA # as.integer(f_burn * (length(json_all)-1)) + 1
thin_by = 10

# gather info about feature <-> param <-> rate
param_node = names(df_eff)
param_desc = c()
for (i in 1:length(param_node)) {
    
    z = gsub("\\.", "_", param_node[i])
    tok = strsplit(z, split="_")[[1]]
    
    typ = ifelse(tok[1] == "phi", "quantitative", "categorical")
    rel = ifelse(tok[2] %in% c("e", "w"), "within", "between")
    idx = as.numeric(tok[3])
    
    y = c(idx, rel, typ, tok[1], tok[2], param_node[i])
    
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


# create dummy plot to gather info about label sizes
pdf(NULL)
tmp = plot.igraph(g1, layout=layout)
vsize = strwidth(V(g1)$label) + strwidth("oo") * 1500
vsize2 = strheight("I") * 2 * 350

# create full plot
pdf("./output/plot_feature_to_rate_network.pdf", height=8, width=12)
    
plot.igraph(g1, 
    layout=layout,
    vertex.shape="rectangle",
    vertex.size=vsize,
    vertex.size2=vsize2,
    vertex.color=c("green","cyan")[V(g1)$type+1],
    vertex.label.family = "sans",
    vertex.label.color="black",
    edge.width=abs(E(g1)$weight)*8, 
    edge.color=ifelse(E(g1)$weight > 0, "#ffaaaa","#aaaaff"),
    edge.label.family = "sans",
    edge.label=sapply(E(g1)$weight, function(x) {
        y=round(x,digits=2);
        if (y>0) { y = paste0("+",y) } else {y};
        return(y)}),
    edge.label.dist=10,
    edge.label.color="black",
    rescale=F,
    xlim=c(-3, 3),
    ylim=c( min(layout[,2]), max(layout[,2]) ))


par(mar=c(0,0,0,0)+.1)

# get this from file
qfeat = c("Distance (km)",  "Log distance (km)", "Altitude (m)", "Log altitude (m)")
cfeat = c("In/out Hawaii?", "Into younger?", "Young island?",  "Net growth?")

text( x=-5, y=-(1:4)*2 + 1/2, qfeat, adj=0)
text( x=5, y=-(1:4)*2 + 1/2, cfeat, adj=1)


dev.off()

quit()
