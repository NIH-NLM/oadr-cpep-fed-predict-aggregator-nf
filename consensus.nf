#!/usr/bin/env nextflow
/*
========================================================================================
  oadr-cpep-fed-predict-aggregator-nf  —  consensus
========================================================================================
  The consensus feature set = the **intersection** of the per-site selections (the
  features every site selected). Provide the per-site files one of two ways:

    --sheet features.csv   a CSV with a `file` column, one path per row (best on
                           Lifebit / CloudOS — one short param; the long s3://… paths
                           live in the file, not the command line).
    --features 'a,b'       an explicit comma-separated list (handy for quick local runs).

  Either way each file is handed to the CLI as its own --features (like
  `oadr-cpep consensus-features`). The other aggregator operation is `aggregate.nf`.
  Only per-site feature lists are read — never subject-level data.
*/

nextflow.enable.dsl = 2

// Output directory — default set here in the entry script (not a nextflow.config params knob)
params.outdir = 'results'

include { consensus_features_process } from './modules/oadr_cpep/consensus_features.nf'

workflow {
    if (params.sheet) {
        files_ch = channel.fromPath(params.sheet, checkIfExists: true)
                          .splitCsv(header: true)
                          .map { row -> file(row.file, checkIfExists: true) }
                          .collect()
    } else if (params.features) {
        def files = (params.features instanceof List ? params.features
                     : params.features.toString().tokenize(',')).collect { f -> f.toString().trim() }
        files_ch = channel.fromPath(files, checkIfExists: true).collect()
    } else {
        error "Provide --sheet <CSV with a 'file' column> or --features '<comma-separated files>'"
    }
    consensus_features_process(files_ch)
}
