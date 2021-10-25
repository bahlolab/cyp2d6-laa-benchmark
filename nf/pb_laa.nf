

process pb_laa {
    cpus 16
    mem '16 GB'
    publishDir "progress/pb_laa", mode: "symlink"

    input:
    tuple path(bam), path(pbi)

    output:
    file("amplicon_analysis.fastq") into fastq
    file("amplicon_analysis_summary.csv") into summary_laa

    script:
    """
    laa $bam \\
        --numThreads 16
    """
}