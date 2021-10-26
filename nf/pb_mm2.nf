
process pb_mm2 {
    cpus 4
    memory '4 GB'
    publishDir "progress/pb_mm2", mode: "symlink"

    input:
        tuple path(bam), path(mmi)

    output:
        path(aln)

    script:
        aln = bam.name.replace('.bam', '.mm2.bam')
        """
        pbmm2 align $bam $mmi tmp.bam \\
            --num-threads $task.cpus \\
            --preset SUBREAD \\
            --best-n 1
        samtools sort tmp.bam -@$task.cpus -m 1G -O BAM -o $aln
        """
}