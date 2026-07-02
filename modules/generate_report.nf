process GENERATE_REPORT {
    label "process_small"
    label "report"
    publishDir "${params.outdir}/MultiQC", mode: "copy", pattern: "*.html"
    publishDir "${params.outdir}", mode: "copy", pattern: "*.csv"

    input:
    path report_dir
    path design_file
    
    output:
    path "multiqc_report.html"
    path "new_design_file.csv"

    script:
    if (params.lifebit_platform_executor == "awsbatch") {
        user_dir = workflow.workDir.toString().split('/')[1]
        final_project_bucket = workflow.workDir.subpath(0,9).toString()
        outdir = params.outdir.toString() == "." ? "" : "/${params.outdir}"
        project_bucket = 's3://' + user_dir + '/' + final_project_bucket + '/results' + outdir + '/'
    } else if (params.lifebit_platform_executor == "azurebatch") {
        user_dir = workflow.workDir.toString().split('/')[1]
        final_project_bucket = workflow.workDir.subpath(0,6).toString()
        outdir = params.outdir.toString() == "." ? "" : "/${params.outdir}"
        project_bucket = 'az://' + final_project_bucket + '/results' + outdir + '/'
    } else {
        user_dir = "$projectDir"
        final_project_bucket = "${params.outdir}"
        project_bucket = user_dir + '/' + final_project_bucket + '/'
    }
    """
    cp -r ${report_dir}/* .
    replace_folder.R "${design_file}" "${project_bucket}"
    Rscript -e "rmarkdown::render('report.Rmd', params = list(res_table='new_design_file.csv'))"
    mv report.html multiqc_report.html
    """
}
