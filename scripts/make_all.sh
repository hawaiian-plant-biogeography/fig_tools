#!/usr/bin/env sh

# args
RESULT_PREFIX=$1
CLADE_PREFIX=$2
GEO_PREFIX=$3

if [ -z $1 ]; then
    RESULT_PREFIX="./input/results/Kadua_M1_213"
    CLADE_PREFIX="./input/kadua_data/kadua"
    GEO_PREFIX="./input/hawaii_data"
fi

# files
PHY_FN=${RESULT_PREFIX}.tre
ANC_FN=${RESULT_PREFIX}.states.txt
MCC_FN=${RESULT_PREFIX}.mcc.tre
ASE_FN=${RESULT_PREFIX}.states.tre
RANGE_FN=${CLADE_PREFIX}_range.nex
LABEL_FN=${CLADE_PREFIX}_range_label.csv

# Make MCC and States tree files
if [ -f $PHY_FN ] && [ -f $ANC_FN ]; then
    rb --args ${PHY_FN} ${ANC_FN} --file ./scripts/make_anc.Rev
fi

# Plot MCC tree
if [ -f $MCC_FN ]; then
    Rscript ./scripts/plot_mcc_tree.R ${MCC_FN}
fi

# Plot States tree
if [ -f $MCC_FN ]; then
    Rscript ./scripts/plot_states_tree.R ${ASE_FN}
fi

# Plot range and region counts
if [ -f $RANGE_FN ] && [ -f $LABEL_FN ]; then
    Rscript ./scripts/plot_range_counts.R ${RANGE_FN} ${LABEL_FN}
fi

# ... more plots ...
