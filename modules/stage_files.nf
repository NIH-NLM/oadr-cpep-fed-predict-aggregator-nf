process STAGE_FILES {
    label "process_micro"
    label "report"
    publishDir "${params.outdir}", mode: "copy"

    input:
    tuple val(id), path(folder)
    
    output:
    path "*"

    script:
    """
    # Create output directory with different name to avoid conflicts
    output_dir="${id}_staged"
    mkdir -p "\$output_dir"
    
    # Get the real path of the input folder (works on macOS)
    if [ -L "$folder" ]; then
        # If it's a symlink, get the target
        actual_path=\$(readlink "$folder")
        # If target is relative, make it absolute
        if [[ "\$actual_path" != /* ]]; then
            actual_path="\$(dirname "$folder")/\$actual_path"
        fi
    else
        actual_path="$folder"
    fi
    
    # Copy contents from the actual source directory
    if [ -d "\$actual_path" ]; then
        # Copy all contents except any existing staged directories
        find "\$actual_path" -mindepth 1 -maxdepth 1 ! -name "*_staged" -exec cp -r {} "\$output_dir/" \\;
    else
        cp -r "\$actual_path" "\$output_dir/"
    fi
    
    # Create symlink with the expected name
    ln -sf "\$output_dir" "$id"
    """
}
