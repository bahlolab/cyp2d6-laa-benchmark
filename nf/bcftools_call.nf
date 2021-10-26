
process bcftools_call {
    cpus 1
    memory '2 GB'
    time '1 h'
    publishDir "progress/bcftools_call", mode: 'symlink'

    input:
    tuple val(sm), path(bam), path(bai), path(ref), path(fai)

    output:
    tuple path(vcf), path("${vcf}.tbi")

    script:
    vcf = bam.name.replaceAll('.bam', '.vcf.gz')
    """
    bcftools mpileup $bam -A -f $ref -Ou |
        bcftools call -m -P 0.99 -p 0.99 -Ou |
        bcftools norm -m -both -Oz -o $vcf
    bcftools index -t $vcf
    """
}