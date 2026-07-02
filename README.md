# oadr-cpep-fed-predict-aggregator-nf

The **coordinator (aggregator) workflow** for federated prediction of residual
beta-cell function (C-peptide AUC) in Type 1 Diabetes. It runs on the Lifebit
platform, collects the outputs each institution produced with
**oadr-cpep-fed-predict-site-nf**, and combines them. Only model parameters —
feature lists, coefficient vectors, trained forests — are read. No subject-level
data is ever pooled.

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

## Input — the design file

As with any Lifebit aggregation pipeline, `--design_file` is a CSV whose first
column points at each site job's results folder. `STAGE_FILES` collects those
folders; the phase process then reads the relevant artifacts (`*_selected_features.csv`
for consensus, `*_vector.csv` / `*_rf.pkl` for aggregate) recursively from the
staged tree.

```bash
# Phase 1
nextflow run main.nf --design_file sites.csv --phase consensus

# Phase 2
nextflow run main.nf --design_file sites.csv --phase aggregate --aggregation fedavg
```

## The container

Both workflows share one image, `ghcr.io/nih-nlm/oadr-cpep`, built from
`container/oadr-cpep/` in the **site** repo. It provides `oadr-cpep-cli`; the
aggregator uses its `consensus-features` and `aggregate-vectors` subcommands.

## Parameters

| Param | Default | Meaning |
|---|---|---|
| `--design_file` | — | CSV of per-site result folders (required) |
| `--phase` | `aggregate` | `consensus` (Phase 1) or `aggregate` (Phase 2) |
| `--aggregation` | `fedavg` | vector combine rule: `fedavg` / `median` / `mean` |
| `--min_sites` | majority | consensus threshold (Phase 1) |
| `--oadr_cpep_container` | `ghcr.io/nih-nlm/oadr-cpep:0.1.0` | shared image |
| `--outdir` | `results` | output directory |

## Layout

```
main.nf                       Lifebit entry (paramsSummary, logo, AGGREGATION)
workflows/aggregation.nf      staging + phase gate (consensus vs aggregate)
modules/oadr_cpep/            consensus_features.nf, aggregate_vectors.nf
modules/                      stage_files, generate_report, pipeline_metadata, utils/
nextflow.config              params + shared-container binding
```

This repo keeps the Lifebit platform scaffold (introspection metadata, file
staging, reporting, executor/profile configs) and swaps the analysis step from
the demo federated-CNN aggregator to the oadr-cpep consensus + parameter
aggregation.
