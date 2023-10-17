process DRAGEN {
    tag "$meta.id"
    label 'process_long'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'registry.hub.docker.com/etycksen/dragen4:4.2.4' }"

    input:
    tuple val(meta), path(fastq)
    path reference

    output:
    tuple val(meta), path("*.vcf"), emit: vcf, optional: true
    path "versions.yml"           , emit: versions
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    tuple val(meta) , path("*.bam")                                 , optional: true , emit: bam
    tuple val(meta) , path("*.bai")                                 , optional: true , emit: bai
    tuple val(meta) , path("*.bam.md5sum")                          , optional: true , emit: bam_md5
    tuple val(meta) , path("${prefix}.vcf.gz")                      , optional: true , emit: vcf_gzip
    tuple val(meta) , path("${prefix}.vcf.gz.tbi")                  , optional: true , emit: vcf_gzip_tbi
    tuple val(meta) , path("${prefix}.vcf.gz.md5sum")               , optional: true , emit: vcf_gzip_md5
    tuple val(meta) , path("${prefix}.hard-filtered.vcf.gz")        , optional: true , emit: hard_filtered_vcf_gzip
    tuple val(meta) , path("${prefix}.hard-filtered.vcf.gz.tbi")    , optional: true , emit: hard_filtered_vcf_gzip_tbi
    tuple val(meta) , path("${prefix}.hard-filtered.vcf.gz.md5sum") , optional: true , emit: hard_filtered_vcf_gzip_md5
    tuple val(meta) , path("*_coverage_metrics.csv")                , optional: true , emit: coverage_metrics
    tuple val(meta) , path("*_overall_mean_cov.csv")                , optional: true , emit: overall_mean_cov
    tuple val(meta) , path("*_contig_mean_cov.csv")                 , optional: true , emit: contig_mean_cov
    tuple val(meta) , path("*.insert-stats.tab")                    , optional: true , emit: insert_stats
    tuple val(meta) , path("*.mapping_metrics.csv")                 , optional: true , emit: mapping_metrics
    tuple val(meta) , path("*.g.vcf.gz")                            , optional: true , emit: gvcf_gzip
    tuple val(meta) , path("*.g.vcf.gz.tbi")                        , optional: true , emit: gvcf_gzip_§tbi
    // TODO nf-core: List additional required output channels/values here
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def enable_variant_caller = task.ext.enable_variant_caller ? '--enable-variant-caller true' : '' // might not be necessary

    def input = ''
    // from fastq
    if (fastq) {
        if (fastq.size() > 2) {
            error "Error: cannot have more than 2 fastq files as input."
        } else {
            input = '-1 ' + fastq.join(' -2 ')
        }
    }

    """
    #dragen_reset

    #dragen \\
    echo \\
        $args \\
        $input \\
        -n $task.cpus \\
        -r $reference \\
        --output-file-prefix $prefix \\
        --output-directory \$(pwd) \\
        $enable_variant_caller

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(dragen --version 2>&1) | sed 's/^dragen Version //' ))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        : \$(echo \$(dragen --version 2>&1) | sed 's/^dragen Version //' ))
    END_VERSIONS
    """
}
