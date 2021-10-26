import groovy.json.JsonSlurper

Path path(filename) {
    file(filename, checkIfExists: true)
}

Path checkAmps(String amplicons_json) {
    amplicons_path = path(amplicons_json)
    amplicons = (new JsonSlurper().parse(amplicons_path.toFile())) as Map
    amplicons.each { k, v ->
        assert (v as Map).keySet()
                .containsAll(['chrom', 'start', 'end', 'strand', 'fwd_primer', 'rvs_primer'])
    }
    amplicons_path
}
