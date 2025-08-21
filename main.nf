#!/usr/bin/env nextflow

process SAMTOOLS_INDEX {
    tag "${input.getSimpleName()}"
    conda "bioconda::samtools=1.19.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.19.2--h50ea8bc_0' :
        'quay.io/biocontainers/samtools:1.19.2--h50ea8bc_0' }"

    input:
    path(input)

    output:
    path("*.bai") , optional:true, emit: bai
    path("*.csi") , optional:true, emit: csi
    path("*.crai"), optional:true, emit: crai
    
    script:
    """
    samtools \\
        index \\
        -@ 1 \\
        $input

    """
}

process SAMTOOLS_STATS {
    tag "${input.getSimpleName()}"
    conda "bioconda::samtools=1.19.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.19.2--h50ea8bc_0' :
        'quay.io/biocontainers/samtools:1.19.2--h50ea8bc_0' }"

    input:
    tuple path(input), path(input_index)
    
    output:
    path("*.stats"), emit: stats
    
    script:
    """
    samtools \\
        stats \\
        --threads 1 \\
        ${input} \\
        > ${input.getSimpleName()}.stats

    """
}

process MULTIQC {
    tag "all-run"

    conda "bioconda:: multiqc=1.30"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/multiqc:1.30--pyhdfd78af_1' :
        'biocontainers/multiqc:1.30--pyhdfd78af_1' }"

    input:
    path  multiqc_files, stageAs: "?/*"
    
    output:
    path "*multiqc_report.html", emit: report
    
    when:
    task.ext.when == null || task.ext.when

    script:
    """
    multiqc \\
        --force \\
        .
    """
}

workflow {
  Channel.fromPath("${params.bams}").set{input_ch}

  SAMTOOLS_INDEX(
    input_ch
  )

  SAMTOOLS_STATS(
    input_ch.map{
      [it.getSimpleName(), it]
    }.join(
      SAMTOOLS_INDEX.out.bai.map{[it.getSimpleName(), it]}
    ).map{[it[1], it[2]]}
  )

  MULTIQC(
    SAMTOOLS_STATS.out.stats.collect()
  )


}
