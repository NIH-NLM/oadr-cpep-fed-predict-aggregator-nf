#!/usr/bin/env Rscript

########################################################################
# Replace Folder
#
# This is a very simple script to replace the initial path of a string by
# another supplied by the user.
#
# Input:
#   first input -> design_file.csv: this is a CSV file, with header.
#       All the elements should be filepaths that, at least, contain
#       "jobs/" folder once.
#   second input -> new path: new path to use in substitutions.
#
# Output:
#   new_design_file.csv: same as the input file, but with the filepaths
#       until "jobs/" folder substituted by the user input string.
#
# Author: David Piñeyro <david.pineyro@lifebit.ai>
# Version: 1.0.0
# Date: 27-03-2025
##########################################################################

args <- commandArgs(trailingOnly = TRUE)

design_file <- read.csv(args[1], check.names=FALSE)
substitution_pattern <- "^.*?\\/jobs\\/"
new_pattern <- args[2]

sub_2 <- function(string, pattern, replacement) {
    splt <- unlist(strsplit(string, ";", fixed=TRUE))
    substituted <-  gsub(pattern, replacement, splt)
    new_string <- paste(substituted, collapse = ";")
}

substitute_pattern <- function(x, pattern, replacement) {
    new_string <- unlist(lapply(x, sub_2, pattern, replacement))
    return(new_string)
}

design_file[] <- lapply(design_file, substitute_pattern, substitution_pattern, new_pattern)
write.csv(design_file, "new_design_file.csv", quote=FALSE, row.names=FALSE)
