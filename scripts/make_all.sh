#!/usr/bin/env sh

# args
BASE_NAME=$1

# files
PHY_FN=${BASE_NAME}.tre
ANC_FN=${BASE_NAME}.states.txt
MCC_FN=${BASE_NAME}.mcc.tre
ASE_FN=${BASE_NAME}.states.tre

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

# ... more plots ...
