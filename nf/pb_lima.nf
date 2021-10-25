

process pb_lima {
    cpus 16
    mem '16 GB'
    publishDir "progress/pb_lima", mode: "symlink"

    input:
        tuple path(bam), path(bc_fasta)

    output:
        path(out)

    script:
        out = "${params.run_id}.bam"
        """
        lima $bam $bc_fasta $out \\
            --same \\
            --num-threads $task.cpus \\
            --split-named
        """
}
