
library(RevGadgets)
library(coda)
library(ggplot2)
library(ggtree)
library(grid)
library(gridExtra)


args = commandArgs(trailingOnly=T)
model_fn = "./input/results/Kadua_M1_213.model.txt"
if (length(args) == 1) {
    model_fn = args[1]
}
base_plot_fn = "./output/out.param"

param_names = c("rho", "sigma", "phi")
process_names = c("d", "e", "w", "b")
trace_quant = readTrace(path=model_fn, burnin=0.1)
trace_names = names(trace_quant[[1]])

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

    plots_rho = plotTrace(trace = trace_quant, vars = trace_names[ c(rho_match) ])[[1]]
    plots_phi = plotTrace(trace = trace_quant, vars = trace_names[ c(phi_match, rj_phi_match) ])
    plots_sigma = plotTrace(trace = trace_quant, vars = trace_names[ c(sigma_match, rj_sigma_match) ])
    plots = list( plots_rho, plots_phi[[1]], plots_phi[[2]], plots_sigma[[1]], plots_sigma[[2]] )

    pdf(plot_fn)
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
