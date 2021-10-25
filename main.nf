#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.run_id = "laa-bench"

include { path } from './nf/functions'
include { prep_ref } from './nf/prep_ref'
include { pb_lima } from './nf/pb_lima'
//include { pb_laa } from './nf/pb_laa'

subreads_bam = path(params.subreads_bam)
subreads_pbi = path(params.subreads_bam + '.pbi')
barcodes_fasta = path(params.barcodes_fasta)


workflow {
    // may need to add bwa mode to prep ref for this version
    prep_ref(params.ref_fasta, 'fai')

    Channel.value([subreads_bam, barcodes_fasta]) |
    pb_lima()


}