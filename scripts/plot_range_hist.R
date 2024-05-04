# libraries
library(ape)

# arguments
args = commandArgs()
range_fn = "./input/kadua_data/kadua_range.nex"
label_fn = "./input/kadua_data/kadua_range_label.csv"
region_names = "GNKOMHZ"
if (length(args) == 1) {
    range_fn = args[1]
}
if (length(args) == 2) {
    label_fn = args[2]
}
if (length(args) == 3) {
    region_names  = args[3]
}

# filesystem
plot_fp = "./output/"
plot_region_fn = paste0(plot_fp, "plot_region_histogram.pdf")
plot_range_fn = paste0(plot_fp, "plot_range_histogram.pdf")

# function
bits2regions = function(x) {
    paste(region_names[as.logical(x)], collapse="") 
}

# read range file
dat_ranges  = read.nexus.data(range_fn)
dat_ranges  = lapply(dat_ranges, as.numeric)
df_ranges   = t(data.frame(dat_ranges))
num_regions = ncol(df_ranges)
if (nchar(region_names) == num_regions) {
    region_names = unlist(strsplit(region_names, ""))
} else {
    region_names = LETTERS[1:num_regions]
}
colnames(df_ranges) = region_names

# get label order
df_labels = read.csv(label_fn, sep=",", colClasses=c("character","character"))

# get ranges as sets
df_sets = apply(df_ranges, 1, bits2regions)

# get counts of range-sets
tbl_ranges = table(df_sets)
names_tbl_ranges = names(tbl_ranges)

# reorder range table
ordered_bits = df_labels$range
ordered_ranges = sapply(ordered_bits, function(x) { 
    y = as.numeric(unlist(strsplit(x,"")[[1]]))
    return(bits2regions(y))
})
match_ranges = ordered_ranges[sort(match(names_tbl_ranges, ordered_ranges ))]
tbl_ranges = tbl_ranges[match_ranges]

# get counts of regions
tbl_regions = colSums(df_ranges) 
print(tbl_regions)

# plot ranges histogram
pdf(plot_range_fn, height=7, width=7)
barplot(tbl_ranges, xlab="Range", ylab="Count", las=2)
dev.off()

# plot regions histogram
pdf(plot_region_fn, height=7, width=7)
barplot(tbl_regions, xlab="Region", ylab="Count", las=2)
dev.off()
