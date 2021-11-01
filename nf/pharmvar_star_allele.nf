import groovy.json.JsonOutput

process pharmvar_star_allele {
    label 'R'
    cpus 1
    memory '4 GB'
    time '1 h'
    publishDir "output", mode: 'copy'

    input:
        tuple path(sm_vcf), path(pv_vcf), val(amplicon)


    output:
        tuple path("${params.run_id}.allele_definition.csv"), path("${params.run_id}out.sample_phase_alleles.csv")

    script:
        json = JsonOutput.toJson(amplicon)
        """
        pharmvar_star_allele.R $sm_vcf $pv_vcf \\
            --amplicon '$json' \\
            --out-pref $params.run_id
        """
}