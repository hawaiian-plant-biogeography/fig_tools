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

## Figure gallery

Per-region species richness:
<img src="assets/plot_region_histogram.png" width="50%"/>

Per-range species richness:
<img src="assets/plot_range_histogram.png" width="50%"/>

Maximum clade credibility tree:
<img src="assets/plot_mcc_tree.png" width="50%"/>

Ancestral state tree:
<img src="assets/plot_states_prob.png" width="50%"/>

Feature-rate network:
<img src="assets/plot_feature_rate_network.png" width="50%"/>

Regional features over time:
<img src="assets/plot_features_vs_time.feat_cw1.png" width="50%"/>

Biogeographic rates over time
<img src="assets/plot_rate_vs_time.process_w.png" width="50%"/>

Biogeographic parameter estimates
<img src="assets/plot_param.process_w.png" width="50%"/>

Biogeographic reversible jump probabilities
<img src="assets/plot_param_rj.process_w.png" width="50%"/>


This collaborative project was supported by the "Origin and Evolution of Hawaiian Plants" project (NSF DEB 2040347).
