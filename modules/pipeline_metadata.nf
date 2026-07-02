process OBTAIN_PIPELINE_METADATA {

    label "report"
    label "process_micro"
    publishDir "${params.tracedir}", mode: "copy"

    input:
    val repository
    val commit
    val revision
    val script_name
    val script_path
    val project_dir
    val launch_dir
    val work_dir
    val user_name
    val command_line
    val config_paths
    val propath
    val container
    val container_engine
    val raci_owner
    val domain_keywords

    output:
    path("pipeline_metadata_report.tsv"), emit: ch_pipeline_metadata_report

    shell:
    '''
    echo "Repository\t!{repository}"                  > temp_report.tsv
    echo "Commit\t!{commit}"                         >> temp_report.tsv
    echo "Revision\t!{revision}"                     >> temp_report.tsv
    echo "Script name\t!{script_name}"               >> temp_report.tsv
    echo "Script path\t!{script_path}"               >> temp_report.tsv
    echo "Project directory\t!{project_dir}"         >> temp_report.tsv
    echo "Launch directory\t!{launch_dir}"           >> temp_report.tsv
    echo "Work directory\t!{work_dir}"               >> temp_report.tsv
    echo "User name\t!{user_name}"                   >> temp_report.tsv
    echo "Command line\t!{command_line}"             >> temp_report.tsv
    echo "Configuration path(s)\t!{config_paths}"    >> temp_report.tsv
    echo "Propath\t!{propath}"                       >> temp_report.tsv
    echo "Container\t!{container}"                   >> temp_report.tsv
    echo "Container engine\t!{container_engine}"     >> temp_report.tsv
    echo "RACI owner\t!{raci_owner}"                 >> temp_report.tsv
    echo "Domain keywords\t!{domain_keywords}"       >> temp_report.tsv

    awk 'BEGIN{print "Metadata_variable\tValue"}{print}' OFS="\t" temp_report.tsv > pipeline_metadata_report.tsv
    '''
}
