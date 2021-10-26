
process annotate_samples {
    cpus 2
    memory '4 GB'
    publishDir "progress/annotate_samples", mode: "symlink"

    input:
        tuple path(bam), path(barcodes_fa)

    output:
        path(out)

    script:
        out = params.run_id + '.sm_annot.bam'
        """
        samtools view -u $bam |
            bam_annotate_samples.py - \\
                --barcodes $barcodes_fa \\
                --out $out
        """
}