# oadr-cpep-fed-predict-aggregator-nf

The **aggregator workflow** for federated prediction of residual
beta-cell function (C-peptide AUC) in Type 1 Diabetes. It collects the outputs produced with
**oadr-cpep-fed-predict-site-nf**, and combines them. Only model parameters —
feature lists, coefficient vectors, trained forests — are read. 

## Where it sits in the round trip

```
Phase 1  site:  SELECT_FEATURES        -> <site>_selected_features.csv
         AGG :  CONSENSUS_FEATURES     -> consensus_features.csv   (broadcast back)
Phase 2  site:  FIT_MODELS             -> <site>_{ridge,lasso}_vector.csv, <site>_rf.pkl
         AGG :  AGGREGATE_VECTORS       -> federated model
```

The aggregator is the `AGG` half. It is invoked twice — once per phase — gated by
`--phase`.

## Two phases (`--phase`)

**Phase 1 — consensus** (`--phase consensus`): tallies the
`*_selected_features.csv` staged from every site and keeps features selected by
at least a threshold number of sites (default: majority, `n/2 + 1`; override with
`--min_sites`). Emits `consensus_features.csv` (which the sites then fit on) plus
`feature_selection_tally.csv` for transparency.

**Phase 2 — aggregate** (`--phase aggregate`): combines the site parameter files:
- Ridge / LASSO coefficient vectors → one federated vector per method, by
  `--aggregation` (`fedavg` weighted by each site's `n_subjects`, or `median` /
  `mean`).
- Random Forests → a union-of-forests ensemble (`federated_rf_union.pkl`).



This repo keeps the Lifebit platform scaffold (introspection metadata, file
staging, reporting, executor/profile configs) and swaps the analysis step from
the demo federated-CNN aggregator to the oadr-cpep consensus + parameter
aggregation.
