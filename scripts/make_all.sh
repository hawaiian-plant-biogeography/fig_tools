#!/usr/bin/env sh

# args
REGION_NAMES="GNKOMHZ"

# files
PHY_FN="./example_input/results/divtime_timefig.tre"
ANC_FN="./example_input/results/divtime_timefig.states.txt"
MODEL_FN="./example_input/results/divtime_timefig.model.txt"
RANGE_FN="./example_input/kadua_data/kadua_range_n7.nex"
LABEL_FN="./example_input/kadua_data/kadua_range_label.csv"
MCC_FN="./output/out.mcc.tre"
ASE_FN="./output/out.states.tre"


# Verify input files
FILE_MISSING=0
for i in $PHY_FN $ANC_FN $MODEL_FN $RANGE_FN $LABEL_FN; do
    if [ ! -f $i ]; then
        echo "ERROR: ${i} not found"
        FILE_MISSING=1
    fi
done

if [ $FILE_MISSING == 1 ]; then
    echo "ERROR: exit due to missing files"
    exit
fi


# Create RevBayes summary tree files
#
# Example:
# > rb --args ./example_input/results/divtime_timefig.tre ./example_input/results/divtime_timefig.states.txt --file ./scripts/make_tree.rev

rb --args ${PHY_FN} ${ANC_FN} --file ./scripts/make_tree.Rev


# Plot MCC tree
#
# Example: 
# > Rscript ./scripts/plot_mcc_tree.R ./output/out.mcc.tre

Rscript ./scripts/plot_mcc_tree.R ${MCC_FN}


# Plot States tree
#
# Example:
# > Rscript ./scripts/plot_states_tree.R ./output/out.states.tre ./example_input/kadua_data/kadua_range_label.csv GNKOMHZ

Rscript ./scripts/plot_states_tree.R ${LABEL_FN} ${REGION_NAMES}


# Plot range and region counts
#
# Example:
# > Rscript ./scripts/plot_range_counts.R ./example_input/kadua_data/kadua_range_n7.nex ./example_input/kadua_data/kadua_range_label.csv GNKOMHZ

Rscript ./scripts/plot_range_counts.R ${RANGE_FN} ${LABEL_FN} ${REGION_NAMES}


# Plot FIG param posteriors
#
# Example:
# > 

Rscript ./scripts/plot_model_posterior.R ${MODEL_FN}

# Plot RJ prob effects
Rscript ./scripts/plot_rj_effects.R ${MODEL_FN}

# Plot region features vs. time
Rscript ./scripts/plot_features_vs_time_grid.R

# Plot region rates vs. time
Rscript ./scripts/plot_rates_vs_time_grid.R

# Plot rates vs. features
Rscript ./scripts/plot_feature_to_rate.R

# ... more plots ...
