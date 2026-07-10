/**
 * Phase 1 (aggregator) — build the consensus feature set.
 *
 * Runs `oadr-cpep consensus-features` over the staged per-site
 * *_selected_features.csv files, passed EXPLICITLY as one `--features <file>` per
 * file (no directory, no glob): a multi-site tally (keep features chosen by >= a
 * threshold number of sites), or one site's selection as the consensus
 * (--from-site). The panel is derived from the files. Only feature lists are read.
 *
 * Input : path features_files — the staged per-site *_selected_features.csv
 * Output: consensus -> consensus*features.csv ; tally (optional)
 */
process CONSENSUS_FEATURES {
    tag "consensus_features"
    label 'oadr_cpep'
    containerOptions '--entrypoint ""'
    publishDir "${params.outdir}/consensus", mode: params.publish_mode

    input:
    path features_files

    output:
    path "consensus*features.csv",       emit: consensus
    path "feature_selection_tally*.csv", emit: tally, optional: true

    script:
    def files     = features_files instanceof List ? features_files : [features_files]
    def feat_args = files.collect { f -> "--features ${f}" }.join(' ')
    def min_sites = params.min_sites ? "--min-sites ${params.min_sites}" : ""
    def from_site = params.from_site ? "--from-site ${params.from_site}" : ""
    """
    oadr-cpep consensus-features \
        ${feat_args} \
        ${min_sites} \
        ${from_site}
    """
}
