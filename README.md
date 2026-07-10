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

```bash
nextflow run aggregate.nf --aggregation fedavg --input_files 'results/**/*_vector.csv'
nextflow run consensus.nf                      --input_files 'results/**/*_selected_features.csv'
```

`--input_files` is a glob Nextflow uses to gather the per-site files; each is handed
to the CLI explicitly (one `--vector` / `--features` per file). Add `-profile local`
to run without Docker (see `environment.yml`).

## Parameters

| Param | Default | Meaning |
|---|---|---|
| `--input_files` | — | glob of the per-site files to gather (required) |
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
