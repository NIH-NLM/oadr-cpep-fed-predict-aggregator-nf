#!/usr/bin/env nextflow
/*
========================================================================================
  oadr-cpep-fed-predict-aggregator-nf  —  aggregate
========================================================================================
  Combine the per-site coefficient vectors / forests into the federated model:

    nextflow run aggregate.nf -profile local --input_files '.../*_vector.csv' [--aggregation fedavg]

  FedAvg / median / mean per method + union of forests; the from-/panel tags are
  derived from the files. The other aggregator operation is `consensus.nf`. Only
  fitted parameters are read — never subject-level data.
*/

nextflow.enable.dsl = 2

include { aggregate_vectors_process } from './modules/oadr_cpep/aggregate_vectors.nf'

workflow {
    if (!params.input_files) error "Please provide --input_files (glob of the per-site vectors / forests)"
    aggregate_vectors_process(channel.fromPath(params.input_files, checkIfExists: true).collect())
}
