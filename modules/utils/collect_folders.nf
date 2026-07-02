def collectFolders(filepath) {
/* Collects Folders to stage as well as Job IDs

    Input:
    filepath : a filepath of the CloudOS type, from s3 or az buckets.
        E.g.:
            - "s3://airlock-bucket-aa-dev/660feb3683c02e208316d581-approved-results-ec404eda58d0cb6b/deploit/teams/660feb3683c02e208316d581/users/5da8548244e75e00e1974d2f/projects/67ee53c667b83eee6c7f0b40/jobs/67eff688150aa082d1fb2694/results/flowchart.png"

    Return:
    An array with the following elements:
        job_id : string with the job ID
        path_to_results : full path to results folder to stage
*/
    filepath = filepath.toString()

    def j_index = filepath.indexOf("jobs")
    def r_index = filepath.indexOf("/results/")

    def job_id = filepath.substring(j_index + 5, r_index)
    def path_to_results = filepath.substring(0, r_index + 9)

    return [job_id, path_to_results]
}
