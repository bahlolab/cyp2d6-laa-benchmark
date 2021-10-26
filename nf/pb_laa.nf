
process pb_laa {
    cpus 4
    memory '8 GB'
    publishDir "progress/pb_laa", mode: "symlink"

    input:
    tuple val(sample), path(bam)

    output:
    tuple val(sample), path("${sample}.laa.fq.gz")

    script:
    """
    laa $bam \\
        --minLength 6000 \\
        --maxReads 800 \\
        --minSnr 4.5 \\
        --noClustering \\
        --Phasing \\
        --ignoreEnds 21 \\
        --trimEnds 21 \\
        --numThreads $task.cpus
    bgzip -c amplicon_analysis.fastq ? ${sample}.laa.fq.gz
    """
}