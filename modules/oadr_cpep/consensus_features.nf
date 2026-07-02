/**
 * Phase 1 (aggregator) — build the consensus feature set.
 *
 * Runs oadr-cpep-cli consensus-features over the staged per-site
 * *_selected_features.csv files, keeping features selected by at least a
 * threshold number of sites. Broadcasts consensus_features.csv (which each site
 * then fits on in Phase 2) plus a transparency tally. Only feature lists are
 * read — never subject-level data.
 */
process CONSENSUS_FEATURES {
    tag "consensus_features"
    label 'oadr_cpep'
    publishDir "${params.outdir}/consensus", mode: params.publish_mode

    input:
    path "*"

    output:
    path "consensus_features.csv",      emit: consensus
    path "feature_selection_tally.csv", emit: tally

    script:
    def min_sites = params.min_sites ? "--min-sites ${params.min_sites}" : ""
    """
    oadr-cpep-cli consensus-features \\
        --input_dir . \\
        ${min_sites} \\
        --outdir .
    """
}
