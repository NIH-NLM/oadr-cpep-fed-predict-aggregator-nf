<!-- Note: None of the template header sections should be removed and each should be addressed -->

## Overview

<!-- Does this... -->

## Purpose

<!-- To achieve... -->

## Acceptance Criteria/Jira Ticket

<!-- Replace ticket code in square brackets [] and link in parentheses () -->
[LIF-XXXX]()

## Changes

<!-- Delete, prepend, amend and append as appropriate -->
- Implements X
- Refactors Y
- Adds/Removes Z
- Fixes/Mentions Issue/s #

## Relevant CloudOS Tests
<!-- These are tests relevant to show the point of the PR. Ideally, you can add screenshots and links to the jobs to help the reviewer. -->

## PR Checklist

#### Author to check:
<!-- These should be checked by author, review should not be requested until all are addressed -->
- [ ] The PR title is informative and begins with appropriate `[Fix:|Feat:|Docs:]` based on PR type
- [ ] This PR is raised to `dev` branch
- [ ] The description contains the acceptance criteria or link to the associated Jira ticket
- [ ] The description contains links to CloudOS tests covering all test cases in client environment

#### Reviewer to check:
<!-- These should be checked of by the reviewer only, check off even if NA for PR for completion -->
- [ ] A new test profile covering new functions for acceptance criteria is created if it does not already exist
- [ ] Nextflow configs have associated profiles named to match the config basename
- [ ] The [internal_lifebit_cloudos_ci.yml](https://github.com/lifebit-ai/<target_repo_name>/blob/dev/.github/workflows/internal_lifebit_cloudos_ci.yml) (and [Jenkinsfile](https://github.com/lifebit-ai/<target_repo_name>/blob/dev/Jenkinsfile), if it exists) has been updated to run all current Nextflow profiles
- [ ] Redundant tests have been removed
- [ ] The [README.md](https://github.com/lifebit-ai/<target_repo_name>/blob/dev/docs/README.md) has been updated with parameter changes and current `results/` and conforms to the README.md guidelines
- [ ] The code is logical, readable, reasonably optimal and meets the acceptance criteria
