configfile: 'config/config.yaml'

def get_samples_path(wildcards):
	return ['../data/samples/'+config['samples']+ '_R1_001.fastq.gz',
	'../data/samples/'+config['samples']+ '_R2_001.fastq.gz']



rule bwa_mem:
	input:
        reads=get_samples_path,
        idx=multiext(config['ref_genome'], ".amb", ".ann", ".bwt", ".pac", ".sa"),
    output:
        "../interim/{sample}.bam",
    log:
        "../logs/bwa_mem/{sample}.log",
    params:
        extra=r"-R '@RG\tID:{sample}\tSM:{sample}'",
        sorting="samtools",  # Can be 'none', 'samtools' or 'picard'.
        sort_order="queryname",  # Can be 'queryname' or 'coordinate'.
        sort_extra="",  # Extra args for samtools/picard.
    threads: 8
    wrapper:
        "v1.21.1/bio/bwa/mem"

#rule bam_sorting:
#	input:
#		rules.bwa_mem_alignment.output
#	output:
#		'../interim/{sample}.sorted.bam'
#	log:
#		'../logs/{sample}.bam_sorting.log'
#	threads: config['threads']
#	params:
#        extra="-m 4G"
#	wrapper:
#		'v1.3.2/bio/samtools/sort'


rule mark_duplicates_spark:
	input:
		rules.bwa_mem.output
	output:
		bam = '../interim/{sample}.sorted.markeddup.bam',
		metrics = '../interim/{sample}.metrics.txt'
	log:
		'../logs/{sample}.mark_duplicates.log'
	benchmark:
		'../benchmarks/{sample}.mark_duplicates.txt'
#	container:
#		'docker://docker pull broadinstitute/gatk'
	threads: config['threads']
	wrapper:
		'v1.3.2/bio/gatk/markduplicatesspark'

#		'gatk MarkDuplicatesSpark -I {input} -O {output.bam} -M {output.metrics}'


rule Base_QC_recalibration:
	input:
		bam = rules.mark_duplicates_spark.output.bam,
		ref = config['ref_genome'],
		dict = rules.genome_dict.output
		known = rules.remove_iupac_codes.output,
        known_idx = rules.tabix_known_variants.output,
	output:
		'../interim/{sample}.mark_duplicates_bqsr.grp'
	log: '../logs/{sample}_Base_QC_recalibration.log'
#	resources:
#        mem_mb=1024,
    wrapper:
        "v1.3.2/bio/gatk/baserecalibrator"

rule apply_bqcr:
	input:
		bam = rules.mark_duplicates_spark.output.bam
		reg = config['ref_genome']
		dict = config["ref_dict"]
		recal_table = rules.Base_QC_recalibration.output
	output:
		'../results/{sample}_markdup_bqcr_recal_ready.bam'
	wildcard_constraints:
        sample = 'CPCT12345678R_HJJLGCCXX_S1_L001'
	log: '../logs/{sample}.apply_bqcr.log'
	resources:
        mem_mb=1024,
    wrapper:
        "v1.3.2/bio/gatk/applybqsr"

