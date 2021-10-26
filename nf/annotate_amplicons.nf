

process annotate_amplicons {
    cpus 2
    memory '4 GB'
    publishDir "progress/annotate_amplicons", mode: "symlink"

    input:
        tuple path(bam), path(amplicons)

    output:
        path(out)

    script:
        out = params.run_id + ".sm_am_annot.bam"
        """
        samtools view -u $bam |
            bam_annotate_amplicons.py - \\
                --window 500 \\
                --max-dist 2 \\
                --amplicons $amplicons \\
                --out $out
        """
}