# oadr-cpep-fed-predict-aggregator-nf
=======
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
`*_selected_features.csv` from every site and keeps features selected by at least a
threshold number of sites (default: majority, `n/2 + 1`; override with
`--min_sites`). Emits `consensus_features.csv` (which the sites then fit on) plus
`feature_selection_tally.csv` for transparency. `--from_site SDY524` instead uses
one site's selection *as* the consensus (single-site, bespoke).

**Phase 2 — aggregate** (`--phase aggregate`): combines the site parameter files:
- Ridge / LASSO coefficient vectors → one federated vector per method, by
  `--aggregation` (`fedavg` weighted by each site's `n_subjects`, or `median` /
  `mean`).
- Random Forests → a union-of-forests ensemble (`federated_rf_union.pkl`).

The `from-<src>` and `panel` tags of the output are **derived from the input
files' own provenance columns**; panels and feature sources are never mixed
(mismatched inputs are an error). Non-vector CSVs among the inputs (e.g. a
`*_fit_metrics.csv`) are ignored.

## Input

`--input_files` is a glob Nextflow uses only to **gather** the per-site files into
a channel; each file is then handed to the CLI **explicitly** — one
`--features <file>` (consensus) or `--vector <file>` (aggregate) per file, so no
directory ever reaches the CLI. Point it at the per-site selections (consensus) or
the per-site vectors/forests (aggregate):

```bash
# Phase 1 — consensus (per-site *_selected_features.csv)
nextflow run main.nf -profile local --phase consensus --min_sites 1 \
  --input_files 'results/**/*_selected_features.csv'

# Phase 2 — aggregate (per-site *_vector.csv + *_rf.pkl; metrics CSVs are ignored)
nextflow run main.nf -profile local --phase aggregate --aggregation fedavg \
  --input_files 'results/**/*_from-SDY524_panelB_*'
```

## Test locally on a Mac (no Docker)

```bash
conda env create -f environment.yml
conda activate oadr-cpep-nf
pip install -e ../oadr-cpep          # the sibling package (editable)
nextflow run main.nf -profile local --phase aggregate --input_files '.../*_vector.csv'
```

`-profile local` disables Docker and runs the `oadr-cpep` CLI from the env; drop
it for the containerized run (Lifebit / the published image).

## The container

Every process runs the shared **`ghcr.io/nih-nlm/oadr-cpep`** image (the same one
the site workflow uses), which provides the `oadr-cpep` CLI — here the
`consensus-features` and `aggregate-vectors` subcommands. The image is built and
published by the [oadr-cpep](https://github.com/NIH-NLM/oadr-cpep) package repo;
this workflow only references it (`params.container`).

## Parameters

| Param | Default | Meaning |
|---|---|---|
| `--input_files` | — | glob of the per-site result files, staged flat (required) |
| `--phase` | `aggregate` | `consensus` (Phase 1) or `aggregate` (Phase 2) |
| `--aggregation` | `fedavg` | vector combine rule: `fedavg` / `median` / `mean` |
| `--min_sites` | majority | consensus threshold (Phase 1) |
| `--from_site` | false | consensus from one site's selection (single-site, bespoke) |
| `--container` | `ghcr.io/nih-nlm/oadr-cpep:latest` | shared package image |
| `--outdir` | `results` | output directory |
| `--publish_mode` | `copy` | `publishDir` mode |

## Layout

```
main.nf              phase gate (consensus / aggregate), calls the two modules directly
modules/oadr_cpep/   consensus_features.nf, aggregate_vectors.nf  (build explicit --features/--vector)
nextflow.config      params + shared-container binding + the `local` profile
environment.yml      conda env for local (no-Docker) testing
```
