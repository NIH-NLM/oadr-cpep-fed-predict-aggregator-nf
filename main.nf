#!/usr/bin/env nextflow
/*
========================================================================================================
|                                  lifebit-platform-federated-aggregation                              |
========================================================================================================
*/

nextflow.enable.dsl = 2


/*---------------------------------------------
| Importing processes and functions as modules|
---------------------------------------------*/

include { paramsSummary } from "./modules/utils/summary_funct.nf"
include { lifebitLogo } from "./modules/utils/lifebit_logo.nf"


include { AGGREGATION } from "./workflows/aggregation.nf"


workflow {

    // Print parameter information
    log.info paramsSummary().collect { k, v -> "${k.padRight(18)}: $v" }.join("\n")
    log.info "-" * 52

    // Print Lifebit logo to stdout
    if ( workflow.userName != "ec2-user" ) {
        print lifebitLogo()
    }

    AGGREGATION()

}
