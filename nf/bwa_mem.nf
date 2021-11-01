
process bwa_mem {
    cpus 1
    memory '4 GB'
    time '1 h'
    publishDir "progress/bwa_mem", mode: "symlink"
    tag { sample }

    input:
        tuple val(sample), path(fastq), path(ref), path(fai), path(bwa_files)

    output:
        tuple val(sample), path(out), path("${out}.bai")

    script:
        out = fastq.name.replaceAll('.fq.gz', '.bam')
        """
        bwa mem -M $ref $fastq | samtools view -b -o $out
        samtools index $out
        """
}