process JACKHMMER_COLABFOLDSEARCH {
    tag "$meta.id"
    label 'process_high_memory'

    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error("Local JACKHMMER_COLABFOLDSEARCH module does not support Conda. Please use Docker / Singularity / Podman instead.")
    }

    container "nf-core/proteinfold_colabfold:1.1.0"

    input:
    tuple val(meta), path(fasta)
    path colabfold_db

    output:
    tuple val(meta), path("${meta.id}.a3m"), emit: a3m
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def VERSION = '0.1.0' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.

    """
    ls -l /
    ls -l /hh-suite
    ls -l /hh-suite/scripts
    mkdir -p results
    jackhmmer -A results/${meta.id}.hmm.sto -o results/${meta.id}.hmm.out ${fasta} $colabfold_db
    /hh-suite/scripts/reformat.pl sto a3m results/${meta.id}.hmm.sto results/${meta.id}.hmm.a3m



    cp results/${meta.id}.hmm.a3m ${meta.id}.a3m

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        jackhmmer_colabfold_search: $VERSION
    END_VERSIONS
    """

    stub:
    def VERSION = '0.1.0' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    touch ${meta.id}.a3m

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        jackhmmer_colabfold_search: $VERSION
    END_VERSIONS
    """
}
