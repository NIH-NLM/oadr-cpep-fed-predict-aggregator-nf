/**
 * Phase 2 (aggregator) — combine the per-site model parameters.
 *
 * Runs oadr-cpep-cli aggregate-vectors over the staged per-site outputs:
 *   - Ridge / LASSO coefficient vectors -> one federated vector per method
 *     (FedAvg weighted by n_subjects, or median / mean).
 *   - Random Forests -> a union-of-forests ensemble.
 * Only fitted parameters are read — never subject-level data.
 *
 * Input : path("*") — the staged site result folders
 * Output: path federated_* — federated vectors (.csv) and forest union (.pkl)
 */
process AGGREGATE_VECTORS {
    tag "aggregate_vectors_${params.aggregation}"
    label 'oadr_cpep'
    publishDir "${params.outdir}/federated_model", mode: params.publish_mode

    input:
    path "*"

    output:
    path "federated_*", emit: federated

    script:
    """
    oadr-cpep-cli aggregate-vectors \\
        --input_dir . \\
        --method ${params.aggregation} \\
        --outdir .
    """
}
