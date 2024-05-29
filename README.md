# FIG_tools

Tools to assist with Feature-Informed GeoSSE (FIG) analyses in RevBayes. Currently, this repo only contains plotting tools.

## Quick use:

```
# get repo
git clone git@github.com:hawaiian-plant-biogeography/FIG_tools.git

# enter repo
cd FIG_tools

# build figures
./scripts/make_all.sh

# view figure directory
open ./output
```

## Contents:
- `scripts` contains scripts to process FIG input/output
- `example_input` contains example data to process with `scripts`
- `output` contains example output produced by `scripts` against `example_input`

## Figures:
- Per-region species richness: [link](output/plot_region_histogram.pdf)
- Per-range species richness: [link](output/plot_range_histogram.pdf)
- Maximum clade credibility tree:  [link](output/out.mcc.pdf)
- Ancestral state trees:  [link](output/out.states_prob.pdf)
- Feature-rate network:  [link](output/plot_feature_to_rate_network.pdf)
- Regional features over time: [link](output/out.feat_vs_time.idx_1.rel_within.typ_quantitative.pdf)
- Biogeographic rates over time: [link](output/rate_vs_time_process_w.pdf)
- Biogeographic parameter plots:  [link](output/out.param_d.pdf)
- Biogeographic reversible jump probabilities:  [link](output/out.param_rj_d.pdf)

This collaborative project was supported by the "Origin and Evolution of Hawaiian Plants" project (NSF DEB 2040347).
