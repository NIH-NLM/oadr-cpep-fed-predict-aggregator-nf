include { OBTAIN_PIPELINE_METADATA } from "../modules/pipeline_metadata.nf"
include { replaceBucket } from "../modules/utils/replace_bucket.nf"
include { helpMessage } from "../modules/utils/help_message.nf"
include { collectFolders } from "../modules/utils/collect_folders.nf"

include { STAGE_FILES } from "../modules/stage_files.nf"
include { GENERATE_REPORT } from "../modules/generate_report.nf"
include { CONSENSUS_FEATURES } from "../modules/oadr_cpep/consensus_features.nf"
include { AGGREGATE_VECTORS } from "../modules/oadr_cpep/aggregate_vectors.nf"


workflow AGGREGATION {

    main:

    // Show help message
    if (params.help) {
        helpMessage()
        exit 0
    }


    /*---------------------------------------------------
    | Setting up introspection variables and channels    |
    ----------------------------------------------------*/
    ch_repository = channel.of(workflow.manifest.homePage)
    ch_commit_id = channel.of(workflow.commitId ?: "Not available is this execution mode. Please run 'nextflow run ${workflow.manifest.homePage} [...]' instead of 'nextflow run main.nf [...]'")
    ch_revision = channel.of(workflow.manifest.version)
    ch_script_name = channel.of(workflow.scriptName)
    ch_script_file = channel.of(workflow.scriptFile)
    ch_project_dir = channel.of(workflow.projectDir)
    ch_launch_dir = channel.of(workflow.launchDir)
    ch_work_dir = channel.of(workflow.workDir)
    ch_user_name = channel.of(workflow.userName)
    ch_command_line = channel.of(workflow.commandLine)
    ch_config_files = channel.of(workflow.configFiles)
    ch_profile = channel.of(workflow.profile)
    ch_container = channel.of(workflow.container)
    ch_container_engine = channel.of(workflow.containerEngine)


    /*------------------------------------------------------------------
    | Setting up additional variables used for documentation purposes   |
    -------------------------------------------------------------------*/
    ch_raci_owner = channel.of(params.raci_owner) 
    ch_domain_keywords = channel.of(params.domain_keywords)


    /*------------------------
    | Setting up input data   |
    -------------------------*/
    // Define channels from input
    ch_report_dir = channel.value(file("${projectDir}/bin/report"))

    ch_folders_to_stage = channel.fromPath(params.design_file)
        .splitCsv(header: false, sep: ',', skip: 1)
        .map { row ->
            // First column that is not "MISSING_FILE" is the file path
            def filepath = row.find { col -> col != "MISSING_FILE" } ?: "MISSING_FILE"
            if (filepath != "MISSING_FILE") {
                // Check if this is a cloud path or local path
                if (filepath.contains("/jobs/") && filepath.contains("/results/")) {
                    // Cloud path - use existing logic
                    def collected_folders = collectFolders(filepath)
                    def job_id = collected_folders[0]
                    def path_to_results = collected_folders[1]
                    [job_id, file(path_to_results)]
                } else {
                    // Local path - extract study ID from the path
                    def study_id = filepath.tokenize('/').last()
                    [study_id, file(filepath)]
                }
            }
        }
    ch_input_design_file = channel.fromPath(params.design_file)


    /*--------------
    | Processes    |
    --------------*/
    // Do not delete this process
    // Create introspection report
    if (params.obtain_pipeline_metadata) {
        OBTAIN_PIPELINE_METADATA(
            ch_repository,
            ch_commit_id,
            ch_revision,
            ch_script_name,
            ch_script_file,
            ch_project_dir,
            ch_launch_dir,
            ch_work_dir,
            ch_user_name,
            ch_command_line,
            ch_config_files,
            ch_profile,
            ch_container,
            ch_container_engine,
            ch_raci_owner,
            ch_domain_keywords
        )
    }

    STAGE_FILES(
        ch_folders_to_stage
    )

    // Aggregate the staged per-site outputs. Two phases, gated by --phase:
    //
    //   consensus  — tally the *_selected_features.csv from every site and
    //                broadcast consensus_features.csv (sites then fit on it).
    //   aggregate  — combine the site coefficient vectors / forests into the
    //                federated model.
    //
    // Only site-level parameters are read; no subject-level data is pooled.
    if (params.phase == "consensus") {
        CONSENSUS_FEATURES(
            STAGE_FILES.out.collect()
        )
    } else if (params.phase == "aggregate") {
        AGGREGATE_VECTORS(
            STAGE_FILES.out.collect()
        )
    } else {
        error "Unknown --phase '${params.phase}'. Use 'consensus' or 'aggregate'."
    }

    // Optional Lifebit report
    if (params.generate_report) {
        GENERATE_REPORT(
            ch_report_dir,
            ch_input_design_file
        )
    }

}
