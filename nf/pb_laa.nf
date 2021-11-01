
process pb_laa {
    cpus 8
    memory '16 GB'
    time '1 h'
    publishDir "progress/pb_laa", mode: "symlink"
    tag { sample }

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
    bgzip -c amplicon_analysis.fastq > ${sample}.laa.fq.gz
    """
}