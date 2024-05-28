
library(RevGadgets)
library(coda)
library(ggplot2)
library(ggtree)
library(grid)
library(gridExtra)


args = commandArgs(trailingOnly=T)
model_fn = "./input/results/Kadua_M1_213.model.txt"
feature_fn = "./input/hawaii_data/feature_summary.csv"
desc_fn = "./input/hawaii_data/feature_description.csv"
if (length(args) == 1) {
    model_fn = args[1]
    feature_fn = args[2]
    desc_fn = args[3]
}
base_plot_fn = "./output/out.param"

param_names = c("rho", "sigma", "phi")
process_names = c("d", "e", "w", "b")
trace_quant = readTrace(path=model_fn, burnin=0.1)


df_feature = read.csv(feature_fn, sep=",", header=T)
df_desc = read.csv(desc_fn, sep=",", header=T)
df_all = read.csv(model_fn, sep="\t", head=T)
df_eff = df_all[ , grepl("(^phi)|(^sigma)", names(df_all))]

param_node = names(df_eff)
param_desc = c()
for (i in 1:length(param_node)) {
    
    z = gsub("\\.", "_", param_node[i])
    tok = strsplit(z, split="_")[[1]]
    
    typ = ifelse(tok[1] == "phi", "quantitative", "categorical")
    rel = ifelse(tok[2] %in% c("e", "w"), "within", "between")
    idx = as.numeric(tok[3])
    desc = df_desc$description[ df_desc$rel==rel & df_desc$type==typ & df_desc$index == idx ]
    param_pretty = paste0( tok[1], "_", tok[2], "[", idx, "]" )
    full_name = paste0( param_pretty, " : ", desc )
    
    y = c(idx, rel, typ, tok[1], tok[2], param_node[i], param_pretty, desc, full_name)
    #print(y)
    
    param_desc = rbind(param_desc, y)
}
colnames(param_desc) = c("index","relationship","type","param","process","param_label","param_name","description","full_name")
param_desc = data.frame(param_desc)
trace_names = names(trace_quant[[1]])


for (i in 1:nrow(param_desc)) {
    idx = grepl(param_desc$param_name[i],  trace_names, fixed=T)
    trace_names[idx] = paste0(trace_names[idx], " : ", param_desc$description[i])
    #names(trace_quant[[1]])[ idx ] = param_desc$full_name[i]
    #names(trace_quant[[1]])[ match( param_desc$param_name[i], names(trace_quant[[1]]) ) ] = param_desc$full_name[i]
}
names(trace_quant[[1]]) = trace_names
#trace_names = names(trace_quant[[1]])

for (p in process_names) {
    
    plot_fn = paste0(base_plot_fn, "_", p, ".pdf")

    rho_match      = grep(paste0("^rho_", p), trace_names)
    phi_match      = grep(paste0("^phi_", p), trace_names)
    sigma_match    = grep(paste0("^sigma_", p), trace_names)
    rj_phi_match   = grep(paste0("^use_phi_", p), trace_names)
    rj_sigma_match = grep(paste0("^use_sigma_", p), trace_names)

    rho_est      = summarizeTrace(trace = trace_quant, vars = trace_names[rho_match] ) 
    phi_est      = summarizeTrace(trace = trace_quant, vars = trace_names[phi_match] ) 
    sigma_est    = summarizeTrace(trace = trace_quant, vars = trace_names[sigma_match] ) 
    rj_phi_est   = summarizeTrace(trace_quant, vars = trace_names[rj_phi_match] )
    rj_sigma_est = summarizeTrace(trace_quant, vars = trace_names[rj_sigma_match] )

    plots_rho    = plotTrace(trace = trace_quant, vars = trace_names[ c(rho_match) ])[[1]]
    plots_phi    = plotTrace(trace = trace_quant, vars = trace_names[ c(phi_match, rj_phi_match) ])
    plots_sigma  = plotTrace(trace = trace_quant, vars = trace_names[ c(sigma_match, rj_sigma_match) ])
    plots        = list()
    
    plots_rho        = plots_rho + ggtitle( paste0("Base rate, rho_", p) )
    plots_phi[[1]]   = plots_phi[[1]] + ggtitle( paste0("Quant. feature effects, phi_", p, "[i]") )
    plots_phi[[2]]   = plots_phi[[2]] + ggtitle( paste0("Quant. feature used, phi_", p, "[i]", " != 0") ) + ylim(0,1)
    plots_sigma[[1]] = plots_sigma[[1]] + ggtitle( paste0("Cat. feature effect, sigma_", p, "[i]") )
    plots_sigma[[2]] = plots_sigma[[2]] + ggtitle( paste0("Cat. feature used, sigma_", p, "[i]", " != 0") ) + ylim(0,1)
    plots = list( plots_rho, plots_phi[[1]], plots_phi[[2]], plots_sigma[[1]], plots_sigma[[2]] )
    

    pdf(plot_fn, width=6, height=9)
    grid.newpage()
    grid.draw( # draw the following matrix of plots
        rbind( # bind together the columns
            ggplotGrob(plots[[1]]),
            ggplotGrob(plots[[2]]),
            ggplotGrob(plots[[3]]),
            ggplotGrob(plots[[4]]),
            ggplotGrob(plots[[5]])
        )
    )
    dev.off()
}

