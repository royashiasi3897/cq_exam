//Weiterbildung (not graded)
//Things to remember:
//You have until 18:00 on Friday 19.05.2023 to submit the scripts that do these tasks
//For any questions, if I can clarify anything, I am around for email support and in contact with
//Wedad and my former colleagues who have gone on to use this language.
//My email is billyasser@hotmail.co.uk
//Part 1) Nextflow scripting
//Please write a directory with the scripts yourselves (minimum) or the whole pipeline (so we don't
//limit people)
//sra-toolkit, user repository: home/cq/NGS/cq-examples/exam/SRA_data

nextflow.enable.dsl = 2

params.accession = null
params.outdir = "SRA_data"
params.fastqdir = "SRA_data/sra/${params.accession}_fastq/"


include { prefetch } from "./modules"
include { convertfastq } from "./modules"
include { fastqc } from "./modules"
include { fastp } from "./modules"



//This directory should contain the following pipeline steps:
//- prefetch to download sra data (include what the user repository of the sra toolkit is set to, in a comment in prefetch)
//- fastq-dump to assess the quality of our .sra
//- fastqc of any fastq data in the directory, generate a fastqc report output
//- fastp to run trimming algorithms on raw fastq files

workflow {
    srafile = prefetch(Channel.of(params.accession))
    converted = convertfastq(Channel.of(params.accession), srafile)
    converted_flat = converted.flatten()
    reports_channel = Channel.empty()
    fastqc_outputchannel = fastqc(converted_flat)
    reports_channel = reports_channel.concat(fastqc_outputchannel)
    reports_channel_collected = reports_channel.collect()
    fastp(Channel.of(params.accession), reports_channel_collected)

}