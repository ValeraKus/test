configfile: 'config/config.yaml'

intervals=str(config['intervals'])

def get_pon_samples_path(wildcards):
    for i in config['PON_samples']:
        return '../data/preprocessed/'+i+ '.bam'


rule mutect2_pon:
    input:
        fasta=config['ref_genome'],
        map=get_pon_samples_path,
    output:
        vcf="../data/pon/{sample}.vcf"
    threads: 1
    resources:
        mem_mb=1024,
    params:
        extra="-L " + intervals + " --max-mnp-distance 0"
    log:
        vcf="../logs/mutect_{sample}.log"
    wrapper:
        "v1.21.1/bio/gatk/mutect"


rule genomics_db_import:
    input:
        gvcfs=expand("../data/pon/{sample}.vcf",sample=config["PON_samples"]),
    output:
        db=directory("../data/pon/db"),
    log:
        "../logs/gatk/genomicsdbimport.log",
    params:
        intervals=intervals,
        db_action="create",  # optional
        extra="",  # optional
        java_opts="",  # optional
    resources:
        mem_mb=1024,
    wrapper:
        "v1.21.1/bio/gatk/genomicsdbimport"


rule create_somatic_panel_of_normals:
    input:
        # Required input.
        # Try `expand`-ing your normal samples for PoN generation.
        #expand("../data/pon/{sample}.vcf",sample=config["PON_samples"])
        db="../data/pon/db",
        fasta=config['ref_genome'],
    output:
        '../data/pon/pon.vcf.gz'
    threads: 1
    log: '../logs/gatk/create-somatic-panel-of-normals/PON.log'
 #   wrapper:
 #       'http://dohlee-bio.info:9193/gatk/variant-filtering/create-somatic-panel-of-normals'
    shell:
        'gatk CreateSomaticPanelOfNormals -R {input.fasta} -V gendb://{input.db} --output {output} 2> {log}'




