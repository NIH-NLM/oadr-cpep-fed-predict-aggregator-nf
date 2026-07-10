#!/usr/bin/env nextflow
/*
========================================================================================
  oadr-cpep-fed-predict-aggregator-nf  —  the coordinator (aggregator) workflow
========================================================================================
  Two phases, one reusable workflow, gated by --phase. Each step is a single-function
  Nextflow module calling the oadr-cpep CLI, invoked directly from here (same shape as
  the per-site workflow). The per-site result files — parameters only, never subject-
  level data — are given as a glob (--input_files) and staged FLAT into the process
  work dir, so nothing depends on a directory layout on AWS spot nodes.

    --phase consensus  : CONSENSUS_FEATURES tallies the per-site *_selected_features.csv
                         into consensus_features.csv (sites then fit on it).
    --phase aggregate  : AGGREGATE_VECTORS combines the per-site coefficient vectors /
                         forests into the federated model (FedAvg / median / mean).

  Every step runs the shared ghcr.io/nih-nlm/oadr-cpep container. Only fitted
  parameters and scalar summaries are read — no subject-level data is pooled.
*/

nextflow.enable.dsl = 2

include { CONSENSUS_FEATURES } from './modules/oadr_cpep/consensus_features.nf'
include { AGGREGATE_VECTORS }  from './modules/oadr_cpep/aggregate_vectors.nf'

workflow {
    if (!params.input_files) error "Please provide --input_files (glob of the per-site result files, e.g. 's3://bucket/results/*')"

    // Collect every matching per-site result file into one bundle (a value channel)
    // so Nextflow stages them all FLAT into the work dir.
    input_ch = channel.fromPath(params.input_files, checkIfExists: true).collect()

    if (params.phase == "consensus") {
        CONSENSUS_FEATURES(input_ch)
    } else if (params.phase == "aggregate") {
        AGGREGATE_VECTORS(input_ch)
    } else {
        error "Unknown --phase '${params.phase}'. Use 'consensus' or 'aggregate'."
    }
}
