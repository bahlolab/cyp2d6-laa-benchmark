#!/usr/bin/env nextflow
import groovy.json.JsonSlurper

nextflow.enable.dsl=2

params.run_id = "laa-bench"
params.min_reads = 25
params.amplicon = 'CYP2D6_6k_v1'
params.vep_cache_ver = '104'
params.vep_assembly = 'GRCh38'

include { path; checkAmps } from './nf/functions'
include { prep_ref } from './nf/prep_ref'
include { pb_lima } from './nf/pb_lima'
include { pb_mm2 } from './nf/pb_mm2'
include { annotate_samples } from './nf/annotate_samples'
include { annotate_amplicons } from './nf/annotate_amplicons'
include { split_sample_amplicons } from './nf/split_sample_amplicons'
include { pb_laa } from './nf/pb_laa'
include { bwa_mem } from './nf/bwa_mem'
include { bcftools_call } from './nf/bcftools_call'
include { bcftools_merge } from './nf/bcftools_merge'
include { vep } from './nf/vep'
include { pharmvar_star_allele } from './nf/pharmvar_star_allele'

subreads_bam = path(params.subreads_bam)
barcodes_fasta = path(params.barcodes_fasta)
amplicons_json = checkAmps(params.amplicons_json)
pharmvar_vcf = path(params.pharmvar_vcf)
amp_map = ((new JsonSlurper().parse(amplicons_json.toFile())) as Map)[params.amplicon]
amp_map['pharmvar_gene'] = 'CYP2D6'

workflow {
    ref_files = prep_ref(params.ref_fasta)

    split_fq =
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
        map {
            (it[0] =~ /LB-(.+)\.SM-(.+)\.AM-(.+)\.bam/)[0][2..3] +
                [it[1].toFile().text as int, it[0]]
        } |
        filter { it[1] == params.amplicon } |
        filter { it[2] >= params.min_reads } |
        map { it[[0,3]] } |
        pb_laa |
        splitFastq(compress: true, file:true)

    split_fq |
        combine(ref_files.map { [it.fa, it.fai, it.bwa]} ) |
        bwa_mem |
        combine(ref_files.map { [it.fa, it.fai]} ) |
        bcftools_call |
        toSortedList() |
        map { it.transpose() } |
        bcftools_merge |
        vep |
        map { [it[0], pharmvar_vcf, amp_map] } |
        pharmvar_star_allele

    split_fq |
        map { [it[0], it[1].fileName.toString(), it[1]]} |
        splitFastq(record:true) |
        map { (it[0..1] + [it[2].readHeader]).join(',') } |
        collectFile(name: 'sample_phases.csv', storeDir: './output/',
                    newLine: true, seed: 'sample,fq_name,phase_info')
}
