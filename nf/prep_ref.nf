
workflow prep_ref {
    take:
        ref_fasta
    main:
        ref = ref_fasta ==~ '^(ftp|https?)://.+' ?
            wget(ref_fasta) :
            Channel.from(path(ref))

        out = ref | fai_dict | bwa_index |
            map { [it[0], it[1..7]] }
    emit:
        out
}

process wget {
    label 'S_L'
    publishDir "progress/ref", mode: params.intermediate_pub_mode

    input:
        val url

    output:
        path name

    script:
        name_gz = new File(url).name
        is_gz = name_gz ==~ '.+\\.b?gz$'
        name = name_gz.toString().replaceAll('\\.b?gz$', '')
        if (is_gz)
            """
            wget $url -O $name_gz
            zcat $name_gz > $name
            """
        else
            """
            wget $url -O $name
            """
}

process fai_dict {
    label 'S'
    publishDir "progress/ref", mode: params.intermediate_pub_mode

    input:
        path ref

    output:
        tuple path(ref), path("${ref}.fai"), path(dict)

    script:
        dict = ref.toString().replaceAll('.fa(sta)?$', '.dict')
        """
        samtools faidx $ref
        samtools dict $ref > $dict
        """
}

process bwa_index {
    label 'M'
    publishDir "progress/ref", mode: params.intermediate_pub_mode

    input:
        tuple path(ref), path(fai), path(dict)

    output:
        tuple path(ref), path(fai), path(dict), path("${ref}.sa"), path("${ref}.amb"),
            path("${ref}.ann"), path("${ref}.pac"), path("${ref}.bwt")

    script:
        """
        bwa index $ref
        """
}
