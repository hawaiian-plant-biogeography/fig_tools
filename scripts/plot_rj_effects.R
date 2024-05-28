
library(RevGadgets)
library(coda)
library(ggplot2)
library(ggtree)
library(grid)
library(gridExtra)
library(reshape2)


args = commandArgs(trailingOnly=T)
model_fn = "./input/results/Kadua_M1_213.model.txt"
if (length(args) == 1) {
    model_fn = args[1]
}
base_plot_fn = "./output/out.param"

param_names = c("sigma", "phi")
process_names = c("d", "e", "w", "b")
trace_quant = readTrace(path=model_fn, burnin=0.1)
trace_names = names(trace_quant[[1]])
#print(trace_quant)

for (p in process_names) {
    
    plot_fn = paste0(base_plot_fn, "_rj_", p, ".pdf")

    #phi_match   = grep(paste0("^use_*", p), trace_names)
    rj_match = grep(paste0("^use_[a-z]*_", p), trace_names)
    #print(rj_match)

    z = lapply(rj_match, function(i) { as.vector(trace_quant[[1]][[i]]) })
    names(z) = trace_names[rj_match]
    df_rj = data.frame(z)

    res = list()
    num_param = ncol(df_rj)
    for (i in 1:num_param) {
        for (j in 1:num_param) {
            if (i > j) {
                # rj prob of 2x2 feature effects?
                m = matrix(0, ncol=2, nrow=2)
                m[1,1] = sum( !df_rj[,i] & !df_rj[,j] )
                m[1,2] = sum( !df_rj[,i] &  df_rj[,j] )
                m[2,1] = sum(  df_rj[,i] & !df_rj[,j] )
                m[2,2] = sum(  df_rj[,i] &  df_rj[,j] )
                rownames(m) = paste0( colnames(df_rj)[i], " ", c("=0", "=1") )
                colnames(m) = paste0( colnames(df_rj)[j], " ", c("=0", "=1") )
                # non-independence between feature effects?
                chisq = chisq.test(m)
                # normalize
                m_norm = m / sum(m)
                m_norm = round(m_norm, digits=2)
                res[[ length(res)+1 ]] = list(m=m_norm, chisq=chisq)
            }
        }
    }

   
    pdf(plot_fn)
    plt = list()
    for (i in 1:length(res)) {
        m = melt(res[[i]]$m)
        colnames(m) = c("x", "y", "value")
        #br = seq(0,1,by=0.1)
        #col = rainbow(length(br)+1, start=0, end=0.5)
        p = ggplot(m, aes(x=x, y=y, fill=value))
        p = p + geom_tile(color="white", lwd=1.5, linetype=1)
        p = p + geom_text(aes(label=value), color="black", size=4)
        p = p + scale_fill_gradient(low="white", high="blue", limits=c(0,1))
        p = p + coord_fixed()
        plt[[i]] = p
        print(p)

    }
    dev.off()

    #print(trace_quant[[1]][[ trace_names[rj_match[1]] ]])
    #colnames(df_rj) = trace_names[df_rj]
    #print(head(df_rj))

    # rj_est   = summarizeTrace(trace_quant, vars = trace_names[rj_match] )
    # print(rj_est)

    #plots_phi = plotTrace(trace = trace_quant, vars = trace_names[ c(phi_match, rj_phi_match) ])
    #plots_sigma = plotTrace(trace = trace_quant, vars = trace_names[ c(sigma_match, rj_sigma_match) ])
    #plots = list( plots_rho, plots_phi[[1]], plots_phi[[2]], plots_sigma[[1]], plots_sigma[[2]] )

    #pdf(plot_fn)
    #dev.off()
}
