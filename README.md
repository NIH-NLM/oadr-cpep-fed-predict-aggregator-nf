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
| `--outdir` | `results` | publishDir destination |

## Layout

```
aggregate.nf         aggregate the per-site vectors -> federated model
consensus.nf         intersection of the per-site feature selections
modules/oadr_cpep/   aggregate_vectors_process, consensus_features_process
nextflow.config      params + container + the `local` profile
environment.yml      conda env for local (no-Docker) testing
docs/                Sphinx (auto-generated from the .nf docblocks) → GitHub Pages
```
