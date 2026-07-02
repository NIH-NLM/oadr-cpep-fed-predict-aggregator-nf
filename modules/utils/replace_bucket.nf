def replaceBucket(file, bucket="${params.reference_data_bucket}", pattern="${params.bucket_pattern}") {
    def reg_exp = "s3://[a-zA-Z0-9\\-]*${pattern}"
    file = file.toString()
    if (file =~ reg_exp) {
        file = file.replaceAll(reg_exp, bucket)
    }
    return file
}
