/* --------------------
| Summary              |
--------------------- */

def paramsSummary (){

    def summary = [:]

    if (workflow.revision) summary['Pipeline Release'] = workflow.revision

    summary['Launch dir']                                  = workflow.launchDir
    summary['Working dir']                                 = workflow.workDir
    summary['Script dir']                                  = workflow.projectDir
    summary['User']                                        = workflow.userName
    summary['Output dir']                                  = params.outdir

    return summary
}