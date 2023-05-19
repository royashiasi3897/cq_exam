
nextflow.enable.dsl = 2

params.accession = null
params.outdir = "SRA_data" 

process prefetch {

  storeDir "${params.outdir}"

  container "https://depot.galaxyproject.org/singularity/sra-tools%3A3.0.3--h87f3376_0"

  input:
    val accession

  output:
    path "sra/${accession}.sra" 

  script:
    """
    prefetch $accession 
    """
}


process convertfastq {
    storeDir "${params.outdir}/sra/${accession}_fastq/raw_fastq"

    container "https://depot.galaxyproject.org/singularity/sra-tools%3A3.0.3--h87f3376_0"

    input:
        val accession
        path srafile

    output:
        path "*.fastq", emit: fastqfiles 

    script:
        """
        fastq-dump --split-files ${srafile}
        """
}

process fastqc {
    publishDir "${params.outdir}/sra/${params.accession}_fastq/fastqc_results/"
    container "https://depot.galaxyproject.org/singularity/fastqc:0.12.1--hdfd78af_0"

    input:

      path fastqfiles

    output:
      path "*.html"
      path "*.zip"


    script:
      """
      fastqc ${fastqfiles}
      """
}

process fastp {
  publishDir "${params.fastqdir}", mode: 'copy', overwrite: true

  container "https://depot.galaxyproject.org/singularity/fastp:0.20.1--h8b12597_0"

  input:
    val accession
    path fastqfiles

  output: 
    path "fastp_fastq/*.fastq"
    path "fastp_report"

  script:

      if(fastqfiles instanceof List) {
      """
      mkdir fastp_fastq
      mkdir fastp_report
      fastp -i ${fastqfiles[0]} -I ${fastqfiles[1]} -o fastp_fastq/${fastqfiles[0].getSimpleName()}_fastp.fastq -O fastp_fastq/${fastqfiles[1].getSimpleName()}_fastp.fastq -h fastp_report/fastp.html -j fastp_report/fastp.json
      """
    } else {
      """
      mkdir fastp_fastq
      mkdir fastp_report
      fastp -i ${fastqfiles} -o fastp_fastq/${fastqfiles.getSimpleName()}_fastp.fastq -h fastp_report/fastp.html -j fastp_report/fastp.json
      """
    }
}