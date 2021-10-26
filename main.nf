#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.run_id = "laa-bench"

include { path; checkAmps } from './nf/functions'
include { prep_ref } from './nf/prep_ref'
include { pb_lima } from './nf/pb_lima'
include { pb_mm2 } from './nf/pb_mm2'
include { annotate_samples } from './nf/annotate_samples'
include { annotate_amplicons } from './nf/annotate_amplicons'
//include { pb_laa } from './nf/pb_laa'

subreads_bam = path(params.subreads_bam)
//subreads_pbi = path(params.subreads_bam + '.pbi')
barcodes_fasta = path(params.barcodes_fasta)
amplicons_json = checkAmps(params.amplicons_json)



workflow {
    // may need to add bwa mode to prep ref for this version
    ref_files = prep_ref(params.ref_fasta)

    Channel.value([subreads_bam, barcodes_fasta]) |
        pb_lima |
        flatMap { it.transpose() } |
        map { it[0] } |
        combine(ref_files.map { it.mmi }) |
        pb_mm2 |
        combine([barcodes_fasta]) |
        annotate_samples |
        combine([amplicons_json]) |
        annotate_amplicons |
        view
//        combine(prep_ref.out, by:0) |
//        pb_mm2_2 |
//        filter { it[0] == 'CCS' & it[1] } |
//        map { it.drop(2) } |
//        split_sample_amplicons |


}