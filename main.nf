#!/usr/bin/env nextflow
/*
========================================================================================
  oadr-cpep-fed-predict-aggregator-nf  —  aggregate
========================================================================================
  Combine the per-site coefficient vectors / forests into the federated model.
  Provide the per-site files one of two ways:

    --sheet vectors.csv    a CSV with a `file` column, one path per row (best on
                           Lifebit / CloudOS — one short param; the long s3://… paths
                           live in the file, not the command line).
    --vectors 'a,b,c'      an explicit comma-separated list (handy for quick local runs).

  Either way each file is handed to the CLI as its own --vector (exactly like
  `oadr-cpep aggregate-vectors`). FedAvg / median / mean per method + union of forests;
  the from-/panel tags are derived from the files. The other aggregator operation is
  `consensus.nf`. Only fitted parameters are read — never subject-level data.
*/

nextflow.enable.dsl = 2

// Output directory — default set here in the entry script (not a nextflow.config params knob)
params.outdir = 'results'

include { aggregate_vectors_process } from './modules/oadr_cpep/aggregate_vectors.nf'

workflow {
    if (params.sheet) {
        files_ch = channel.fromPath(params.sheet, checkIfExists: true)
                          .splitCsv(header: true)
                          .map { row -> file(row.file, checkIfExists: true) }
                          .collect()
    } else if (params.vectors) {
        def files = (params.vectors instanceof List ? params.vectors
                     : params.vectors.toString().tokenize(',')).collect { f -> f.toString().trim() }
        files_ch = channel.fromPath(files, checkIfExists: true).collect()
    } else {
        error "Provide --sheet <CSV with a 'file' column> or --vectors '<comma-separated files>'"
    }
    aggregate_vectors_process(files_ch)
}
