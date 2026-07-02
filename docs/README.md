# Pipeline documentation

Table of contents

- [Pipeline documentation](#pipeline-documentation)
  - [Pipeline description](#pipeline-description)
    - [Pipeline overview](#pipeline-overview)
    - [Input](#input)
      - [--design_file]
    - [Processes](#processes)
    - [Output](#output)
  - [Options](#options)
    - [General Options](#general-options)

## Pipeline description

### Pipeline overview

- Name: **lifebit-platform-federated-aggregation**
- Tools: [Rmarkdown](https://rmarkdown.rstudio.com/)
- Versions: see docker containers tags in: [`conf/containers/quay.config`](https://github.com/lifebit-ai/<repository_name>/blob/dev/conf/containers/quay.config)

This is the default aggregation pipeline for federated analysis. It is a very simple pipeline that copies all the results from each input federated analysis to its own results folder. Federated analyses share their results via short-lived airlock buckets. Therefore, this pipeline copies that data so it will be available in a longer-lasting s3 bucket from the job run.

The input is provided using the only pipeline parameter `--design_file` which expects a CSV file with the federated analyses airlock bucket links to the desired files.

This pipeline assumes the following: Each filepath is coming from airlock, so it will contain a folder structure as follows: `s3://airlock-bucket/path/to/**jobs**/a-job-id/**results**/results-folder-of-the-federated-run/another-path/file.txt`. The most important parts are **jobs** followed by the jobID and then **results** folder. The pipeline will take the path from the beginning to the first **results** subfolder (so `s3://airlock-bucket/path/to/**jobs**/a-job-id/**results**/ ` and copy everything under it to a new folder called `**a-job-id**`, in the results folder of this pipeline. It will do the same once per row in `--design_file` so it doesn't really matter how many files the user specifies per federated job: while at least one file is specified, the whole results folder of that job will be copied.

Additionally, the pipeline will also update the specific file paths contained in `--design_file` to point to the newly copied versions of these files in the results folder of this pipeline.

Finally, this pipeline also produces a report, which is the new updated design file as a table.

### Input

#### --design_file

It is a CSV file containing the airlock file paths to the required user files. It is expected to have a header, with the parameter names. It will contain one column per parameter and one row per federated analysis. Each CSV field could contain more than one file path, separated by `;` (semi-colon). In addition, if a file is not found in the federated analysis, the string "MISSING_FILE" will be used.

Example of input file:

```
param1,param2
s3://eu-west-1-lb-featured-datasets/pipelines/lifebit-platform-federated-aggregation/jobs/1/results/another_results/file1.txt;s3://eu-west-1-lb-featured-datasets/pipelines/lifebit-platform-federated-aggregation/jobs/1/results/another_results/file1.1.txt,s3://eu-west-1-lb-featured-datasets/pipelines/lifebit-platform-federated-aggregation/jobs/1/results/another_results/file2.txt
MISSING_FILE,MISSING_FILE
s3://eu-west-1-lb-featured-datasets/pipelines/lifebit-platform-federated-aggregation/jobs/2/results/results/file3.txt,s3://eu-west-1-lb-featured-datasets/pipelines/lifebit-platform-federated-aggregation/jobs/2/results/results/file4.txt
MISSING_FILE,s3://eu-west-1-lb-featured-datasets/pipelines/lifebit-platform-federated-aggregation/jobs/3/results/results/file5.txt
```

### Processes

Here is the list of steps performed by this pipeline.

1. `STAGE_FILES` - this process performs the copy of the **whole** results folder of each federated analysis into its new location in the results folder of the current job.
2. `GENERATE_REPORT` - this process updates the input design file with the new file paths and also generates the report.

### Output

- `results/new_design_file.csv` - it is the same input design file, but with the filepaths updated to point to the newly copied versions of each file.
- `results/MultiQC/multiqc_report.html` - it is a report in HTML containing the new_design_file.csv as a table.

Additionally, the pieline creates one subfolder per input federated analysis:
- job_id_1/whole_results_with_the_original_folder_structure
- job_id_2/whole_results_with_the_original_folder_structure
- ...


## Options


### General Options

| param | default_value | description                          |
| ----- | ------------- | ------------------------------------ |
| design_file | false   | madatory, the input CSV design file  |
