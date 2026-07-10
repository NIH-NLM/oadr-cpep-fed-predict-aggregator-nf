#!/usr/bin/env nextflow
/*
========================================================================================
  oadr-cpep-fed-predict-aggregator-nf  —  consensus
========================================================================================
  The consensus feature set = the **intersection** of the per-site selections (the
  features every site selected):

    nextflow run consensus.nf --input_files '.../*_selected_features.csv'

  The other aggregator operation is `aggregate.nf`. Only per-site feature lists are
  read — never subject-level data.
*/

nextflow.enable.dsl = 2

include { consensus_features_process } from './modules/oadr_cpep/consensus_features.nf'

workflow {
    if (!params.input_files) error "Please provide --input_files (glob of the per-site *_selected_features.csv)"
    consensus_features_process(channel.fromPath(params.input_files, checkIfExists: true).collect())
}
