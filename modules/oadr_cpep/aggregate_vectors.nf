/**
 * Phase 2 (aggregator) — combine the per-site model parameters.
 *
 * Runs `oadr-cpep aggregate-vectors` over the staged per-site outputs, passed
 * EXPLICITLY as one `--vector <file>` per file (coefficient vector CSVs and RF
 * .pkl forests; no directory, no glob). The CLI dispatches each by type:
 *   - Ridge / LASSO vectors -> one federated vector per method (FedAvg / median / mean).
 *   - Random Forests        -> a union-of-forests ensemble.
 * The from-/panel tags of the output are derived from the files' provenance
 * columns; panels and feature sources never mix. Only fitted parameters are read.
 *
 * Input : path vector_files — the staged per-site vectors / forests
 * Output: path federated_* — federated vectors (.csv) and forest union (.pkl)
 */
process AGGREGATE_VECTORS {
    tag "aggregate_vectors_${params.aggregation}"
    label 'oadr_cpep'
    containerOptions '--entrypoint ""'
    publishDir "${params.outdir}/federated_model", mode: params.publish_mode

    input:
    path vector_files

    output:
    path "federated_*", emit: federated

    script:
    def files    = vector_files instanceof List ? vector_files : [vector_files]
    def vec_args = files.collect { f -> "--vector ${f}" }.join(' ')
    """
    oadr-cpep aggregate-vectors \
        ${vec_args} \
        --method ${params.aggregation}
    """
}
