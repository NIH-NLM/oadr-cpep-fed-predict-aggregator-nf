
/* --------------------
| Help Message         |
--------------------- */

include { lifebitLogo } from './lifebit_logo.nf'

def helpMessage() {
    if ( workflow.userName != "ec2-user" ) {
        log.info lifebitLogo()
    }
    log.info """
    Usage:
    The typical command for running the pipeline is as follows:

    Mandatory:
    --input                Input csv file

    Resource Options:
    --max_cpus            Maximum number of CPUs (int)
                        (default: $params.max_cpus)  
    --max_memory          Maximum memory (memory unit)
                        (default: $params.max_memory)
    --max_time            Maximum time (time unit)
                        (default: $params.max_time)

    """.stripIndent()
}
