configfile: 'config/config.yaml'

intervals=str(config['intervals'])

rule mutect2:
    input:
        fasta=config['ref_genome'],
        map=rules.gatk_applybqsr.output.bam,
    output:
        vcf="../data/mutect2/{sample}_unfiltered.vcf",
#    message:
#        "Testing Mutect2 with {wildcards.sample}"
    threads: 1
    resources:
        mem_mb=1024,
    params:
    	extra="-pon ../data/pon/pon.vcf.gz " + "-L " + intervals + 
    	" --germline-resource " + str(config["known_variation"]) +
    	" --f1r2-tar-gz ../interim/f1r2.tar.gz"
    log:
        "logs/mutect2_{sample}.log",
    wrapper:
        "v1.21.1/bio/gatk/mutect"


rule gatk_learnreadorientationmodel:
    input:
        f1r2="../interim/f1r2.tar.gz",
    output:
        "../interim/read-orientation-model.tar.gz",
    resources:
        mem_mb=1024,
    params:
        extra="",
    log:
        "../logs/learnreadorientationbias.log",
    wrapper:
        "v1.21.1/bio/gatk/learnreadorientationmodel"



rule test_gatk_get_pileup_summaries:
    input:
        bam=rules.gatk_applybqsr.output.bam,
        intervals=intervals,
        variants=config["known_variation"],
    output:
        "../interim/{sample}_summaries.table",
    threads: 1
    resources:
        mem_mb=1024,
    params:
        extra="",
    log:
        "../logs/{sample}_summary.log",
    wrapper:
        "v1.21.1/bio/gatk/getpileupsummaries" 


rule contamination_table:
	input:
		pileup_table=rules.test_gatk_get_pileup_summaries.output
	output:
		"../interim/calculatecontamination.table"
	log:
		"../logs/contamination_table.log"
	shell:
		'gatk CalculateContamination -I {input.pileup_table} -tumor-segmentation ../interim/segments.table -O {output} 2> {log}'



rule gatk_filtermutectcalls:
    input:
        vcf=rules.mutect2.output.vcf,
        ref=config["ref_genome"],
        bam=rules.gatk_applybqsr.output.bam,
        intervals=intervals,
        contamination=rules.contamination_table.output, # from gatk CalculateContamination
        segmentation="../interim/segments.table", # from gatk CalculateContamination
        f1r2=rules.gatk_learnreadorientationmodel.output, # from gatk LearnReadOrientationBias
    output:
        vcf="../data/mutect2/{sample}.vcf",
    log:
        "../logs/gatk/filter/{sample}_snvs.log",
    params:
        extra="--max-alt-allele-count 3",  # optional arguments, see GATK docs
        java_opts="",  # optional
    resources:
        mem_mb=1024,
    wrapper:
        "v1.21.1/bio/gatk/filtermutectcalls"