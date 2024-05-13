#!/usr/bin/env sh

# args
RESULT_PREFIX=$1
CLADE_PREFIX=$2
GEO_PREFIX=$3
REGION_NAMES=$4

if [ -z $1 ]; then
    RESULT_PREFIX="./input/results/Kadua_M1_213"
    CLADE_PREFIX="./input/kadua_data/kadua"
    GEO_PREFIX="./input/hawaii_data"
    REGION_NAMES="GNKOMHZ"
fi

# files
PHY_FN=${RESULT_PREFIX}.tre
ANC_FN=${RESULT_PREFIX}.states.txt
MODEL_FN=${RESULT_PREFIX}.model.txt
RANGE_FN=${CLADE_PREFIX}_range.nex
LABEL_FN=${CLADE_PREFIX}_range_label.csv
MCC_FN="./output/out.mcc.tre"
ASE_FN="./output/out.states.tre"

# Make MCC and States tree files
if [ -f $PHY_FN ] && [ -f $ANC_FN ]; then
    rb --args ${PHY_FN} ${ANC_FN} --file ./scripts/make_tree.Rev
fi

# Plot MCC tree
if [ -f $MCC_FN ]; then
    Rscript ./scripts/plot_mcc_tree.R # ${MCC_FN}
fi

# Plot States tree
if [ -f $ASE_FN ]; then
    Rscript ./scripts/plot_states_tree.R ${LABEL_FN} ${REGION_NAMES}
fi

# Plot range and region counts
if [ -f $RANGE_FN ] && [ -f $LABEL_FN ]; then
    Rscript ./scripts/plot_range_counts.R ${RANGE_FN} ${LABEL_FN} ${REGION_NAMES}
fi

# Plot FIG param posteriors
if [ -f $MODEL_FN ]; then
    Rscript ./scripts/plot_model_posterior.R ${MODEL_FN}
fi

# Plot RJ prob effects
if [ -f $MODEL_FN ]; then
    Rscript ./scripts/plot_rj_effects.R ${MODEL_FN}
fi

# Plot region rates vs. time

# Plot region features vs. time

# Plot region rates vs. features


# ... more plots ...
