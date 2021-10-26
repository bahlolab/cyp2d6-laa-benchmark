#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.run_id = "laa-bench"
params.min_reads = 25
params.amplicons = ['CYP2D6_6k_v1']

include { path; checkAmps } from './nf/functions'
include { prep_ref } from './nf/prep_ref'
include { pb_lima } from './nf/pb_lima'
include { pb_mm2 } from './nf/pb_mm2'
include { annotate_samples } from './nf/annotate_samples'
include { annotate_amplicons } from './nf/annotate_amplicons'
include { split_sample_amplicons } from './nf/split_sample_amplicons'
include { pb_laa } from './nf/pb_laa'

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
        split_sample_amplicons |
        flatMap { it[0] instanceof List ? it.transpose() : [it] } |
        map { (it[0] =~ /LB-(.+)\.SM-(.+)\.AM-(.+)\.bam/)[0][2..3] +
                [it[1].toFile().text as int, it[0]] } |
        filter { params.amplicons.contains(it[1]) } |
        filter { it[2] >= params.min_reads } |
        map { it[[0,3]] } |
        pb_laa |
        view

}