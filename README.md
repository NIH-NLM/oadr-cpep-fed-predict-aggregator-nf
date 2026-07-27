[![Build and Deploy Sphinx Documentation](https://github.com/NIH-NLM/oadr-cpep-fed-predict-aggregator-nf/actions/workflows/docs.yml/badge.svg)](https://github.com/NIH-NLM/oadr-cpep-fed-predict-aggregator-nf/actions/workflows/docs.yml)
[![Check pull request source branch](https://github.com/NIH-NLM/oadr-cpep-fed-predict-aggregator-nf/actions/workflows/check_branches.yml/badge.svg)](https://github.com/NIH-NLM/oadr-cpep-fed-predict-aggregator-nf/actions/workflows/check_branches.yml)
[![reviewdog misspell](https://github.com/NIH-NLM/oadr-cpep-fed-predict-aggregator-nf/actions/workflows/misspell.yml/badge.svg)](https://github.com/NIH-NLM/oadr-cpep-fed-predict-aggregator-nf/actions/workflows/misspell.yml)

# oadr-cpep-fed-predict-aggregator-nf

The **shared, federated step**. oadr-cpep is split in two: each institution runs
its own site-specific work first with **oadr-cpep-fed-predict-site-nf**, and this
coordinator then does the shared federated work across the sites' results — which
in turn feeds back to improve each site's own model. Only model parameters cross;
subject-level data never moves.

You feed it the per-site outputs, and it does one of two things:

- **aggregate** (`aggregate.nf`) — combine the coefficient vectors / forests into
  one federated model (FedAvg / median / mean, per `--aggregation`, + a union of
  forests).
- **consensus** (`consensus.nf`) — the intersection of the per-site feature
  selections: the features every site agrees on.

Docs: <https://nih-nlm.github.io/oadr-cpep-fed-predict-aggregator-nf>

## Run

Point it at the per-site files **either** way:

**1. A samplesheet** (best on Lifebit / CloudOS — one short param; the long `s3://…`
paths live in the CSV, not the command line). The CSV has a single `file` column,
one path per row:

```
# vectors.csv
file
s3://bucket/…/SDY524_from-SDY524_panelB_ridge_vector.csv
s3://bucket/…/SDY569_from-SDY524_panelB_ridge_vector.csv
s3://bucket/…/SDY524_from-SDY524_panelB_rf.pkl
s3://bucket/…/SDY569_from-SDY524_panelB_rf.pkl
```

```bash
nextflow run aggregate.nf --aggregation fedavg --sheet vectors.csv
nextflow run consensus.nf                      --sheet selections.csv
```

**2. A comma-separated list** (handy for quick local runs):

```bash
nextflow run aggregate.nf --aggregation fedavg \
  --vectors 'SDY524_..._ridge_vector.csv,SDY569_..._ridge_vector.csv,SDY524_..._rf.pkl,SDY569_..._rf.pkl'
nextflow run consensus.nf \
  --features 'SDY524_panelB_selected_features.csv,SDY569_panelB_selected_features.csv'
```

Either way each file is explicit — handed to the CLI as its own `--vector` /
`--features` (like `oadr-cpep`), no directory or glob, so it behaves the same on
local disk or an S3 bucket.

## Test locally on a Mac (no Docker)

`-profile local` disables Docker and runs the `oadr-cpep` CLI from your conda env,
so set that env up **in order** — create it, **activate** it, *then* install the
package into it (installing before activating lands it in `base`):

```bash
conda env create -f environment.yml   # 1. build the env
conda activate oadr-cpep-nf           # 2. ACTIVATE it (before the next step)
pip install -e ../oadr-cpep           # 3. install oadr-cpep INTO the active env

nextflow run aggregate.nf -profile local \
  --vectors 'a_ridge_vector.csv,b_ridge_vector.csv,a_rf.pkl,b_rf.pkl'
```

Drop `-profile local` for the containerized run (Lifebit / the published image).
Note: Nextflow's own options take **one** dash (`-profile`); your params take
**two** (`--vectors`).

## Parameters

| Param | Default | Meaning |
|---|---|---|
| `--sheet` | — | a CSV with a `file` column, one path per row (either workflow) |
| `--vectors` | — | `aggregate.nf`: comma-separated list of per-site vector/forest files |
| `--features` | — | `consensus.nf`: comma-separated list of per-site selection files |
| `--aggregation` | `fedavg` | `aggregate.nf` combine rule: `fedavg` / `median` / `mean` |

## Layout

```
aggregate.nf         aggregate the per-site vectors -> federated model
consensus.nf         intersection of the per-site feature selections
modules/oadr_cpep/   aggregate_vectors_process, consensus_features_process
nextflow.config      params + container + the `local` profile
environment.yml      conda env for local (no-Docker) testing
docs/                Sphinx (auto-generated from the .nf docblocks) → GitHub Pages
```

## Companion repositories

* Main Python Package: [oadr-cpep](https://github.com/NIH-NLM/oadr-cpep) 
* Site specific workflow: [oadr-cpep-fed-predict-site-nf](https://github.com/NIH-NLM/oadr-cpep-fed-predict-site-nf)
* Consensus and Aggregation specific workflow: [oadr-cpep-fed-predict-site-nf](https://github.com/NIH-NLM/oadr-cpep-fed-predict-aggregation-nf) (here)

## Citation

Bhattacharya S, Dunn P, Thomas CG, Smith B, Schaefer H, Chen J, Hu Z, Zalocusky KA, Shankar RD, Shen-Orr SS, Thomson E, Wiser J, Butte AJ. ImmPort, toward repurposing of open access immunological assay data for translational and clinical research. Sci Data. 2018 Feb 27;5:180015. doi: 10.1038/sdata.2018.15. PMID: 29485622; PMCID: PMC5827693.

Kong YM, Dahlke C, Xiang Q, Qian Y, Karp D, Scheuermann RH. Toward an ontology-based framework for clinical research databases. J Biomed Inform. 2011 Feb;44(1):48-58. doi: 10.1016/j.jbi.2010.05.001. Epub 2010 May 10. PMID: 20460173; PMCID: PMC2953614.

The data supporting this publication is available at ImmPort (immport.org) under study accession SDY524, SDY569, SDY797, SDY1737.


