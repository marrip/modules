#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { DRAGEN } from '../../../../modules/nf-core/dragen/main.nf'

workflow test_dragen {
    
    input = [
        [ id:'test', single_end:false ], // meta map
        file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true)
    ]

    DRAGEN ( input )
}