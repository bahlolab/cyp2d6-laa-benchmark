
process vep {
    cpus 1
    memory '4 GB'
    time '1 h'
    publishDir "output", mode: "copy"

    input:
        tuple path(vcf), file(tbi)

    output:
        tuple path(out_vcf), file("${out_vcf}.tbi")

    script:
        out_vcf = "${params.run_id}_vep.vcf.gz"
        """
        vep --input_file $vcf \\
            --database \\
            --format vcf \\
            --vcf \\
            --everything \\
            --allele_number \\
            --variant_class \\
            --dont_skip \\
            --assembly $params.vep_assembly \\
            --cache_version $params.vep_cache_ver \\
            --allow_non_variant \\
            --pick_allele_gene \\
            --output_file STDOUT |
            bcftools view --no-version -Oz -o $out_vcf
        bcftools index -t $out_vcf
        """
}