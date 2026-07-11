/**
 * Aggregator — consensus feature set = the intersection of the per-site selections.
 *
 * Runs `oadr-cpep consensus-features` over the staged per-site *_selected_features.csv,
 * passed EXPLICITLY as one `--features <file>` per file (no directory, no glob). The
 * consensus is the intersection — the features every site selected. Only feature lists
 * are read, never subject-level data.
 *
 * Input : path features_files — the staged per-site *_selected_features.csv
 * Output: consensus -> consensus*features.csv
 */
process consensus_features_process {
    tag "consensus_features"
    label 'oadr_cpep'
    containerOptions '--entrypoint ""'
    publishDir "${params.outdir}", mode: params.publish_mode

    input:
    path features_files

    output:
    path "consensus*features.csv", emit: consensus

    script:
    def files     = features_files instanceof List ? features_files : [features_files]
    def feat_args = files.collect { f -> "--features ${f}" }.join(' ')
    """
    oadr-cpep consensus-features ${feat_args}
    """
}
