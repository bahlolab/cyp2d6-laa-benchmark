
process bcftools_merge {
    cpus 2
    memory '4 GB'
    time '1 h'
    publishDir "progress/bcftools_merge", mode: 'copy'

    input:
        tuple path(vcf), path(tbi)

    output:
        tuple path(out_vcf), path("${out_vcf}.tbi")

    script:
        out_vcf = "${params.run_id}_merged.vcf.gz"
        """
        bcftools merge --missing-to-ref  ${vcf.join(' ')} -Ou |
            bcftools norm -m-any --do-not-normalize -Oz -o $out_vcf
        bcftools index -t $out_vcf
        """
}