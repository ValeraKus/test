configfile: 'config/config.yaml'

def get_samples_path(wildcards):
	for i in config['samples']:
		return ['../data/'+i+ '_R1_001.fastq.gz', '../data/'+i+ '_R2_001.fastq.gz']

def index_files(wildcards):
	genome=str(config["ref_genome"])
	return [genome + x for x in [".amb", ".ann", ".bwt", ".pac", ".sa"]]

#print([config["ref_genome"] + x for x in [".amb", ".ann", ".bwt", ".pac", ".sa"]])

#rule all:
#    input:
#        "../interim/CPCT12345678R_HJJLGCCXX_S1_L001.dedup.bam"

rule bwa_mem:
    input:
        reads = get_samples_path,
        idx = index_files,
    output:
        "../interim/{sample}.bam",
    wildcard_constraints:
    	sample="[\w]+[\d]+[\w]_[\w]+_S[\d]_L[\d]+"
    log:
        "../logs/bwa_mem/{sample}.log",
    params:
        extra=r"-R '@RG\tID:{sample}\tSM:{sample}\tLB:{sample}\tPL:ILLUMINA'",
        sorting="samtools",  # Can be 'none', 'samtools' or 'picard'.
        sort_order="queryname",  # Can be 'queryname' or 'coordinate'.
        sort_extra="",  # Extra args for samtools/picard.
    threads: 8
    wrapper:
        "v1.21.1/bio/bwa/mem"


rule mark_duplicates_spark:
	input:
		rules.bwa_mem.output
	output:
		bam="../interim/{sample}.dedup.bam",
		metrics="../interim/{sample}.metrics.txt",
	log:
		"../logs/dedup/{sample}.log",
	params:
#        extra="",  # optional
#        java_opts="",  # optional
        #spark_runner="",  # optional, local by default
        #spark_v1.21.1="",  # optional
        #spark_extra="", # optional
	resources:
		mem_mb=1024,
	threads: 8
	wrapper:
		"v1.21.1/bio/gatk/markduplicatesspark"



rule gatk_baserecalibrator:
    input:
        bam=rules.mark_duplicates_spark.output.bam,
        ref=config["ref_genome"],
        dict=config["ref_dict"],
        known=config["known_variation"],  # optional known sites - single or a list
    output:
        recal_table="../interim/{sample}.grp",
    log:
        "../logs/gatk_baserecalibrator/{sample}.log",
    params:
        extra="",  # optional
        java_opts="",  # optional
    resources:
        mem_mb=1024,
    wrapper:
        "v1.21.1/bio/gatk/baserecalibrator"


rule gatk_applybqsr:
    input:
        bam=rules.mark_duplicates_spark.output.bam,
        ref=config["ref_genome"],
        dict=config["ref_dict"],
        recal_table=rules.gatk_baserecalibrator.output.recal_table,
    output:
        bam="../data/preprocessed/{sample}.bam",
    log:
        "../logs/gatk_applybqsr/{sample}.log",
    params:
        extra="",  # optional
        java_opts="",  # optional
        embed_ref=True,  # embed the reference in cram output
    resources:
        mem_mb=1024,
    wrapper:
        "v1.21.1/bio/gatk/applybqsr"

