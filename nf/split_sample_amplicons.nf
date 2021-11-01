

process split_sample_amplicons {
    cpus 2
    memory '4 GB'
    publishDir "progress/bam", mode: 'symlink'

    input:
        path(bam)

    output:
        tuple path("*LB-*.SM-*.AM-*.bam"), path("*LB-*.SM-*.AM-*.bam.count")

    script:
        """
        samtools view -u $bam |
            bam_split_sample_amplicons.py - --lb-tag $params.run_id
        """
}