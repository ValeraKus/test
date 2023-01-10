#!/bin/bash
#SBATCH --job-name=func
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 60G
#SBATCH --time 05:00:00
#SBATCH --mail-user=valeriia.timonina@epfl.ch
#SBATCH --mail-type=END
#SBATCH --output=/work/gr-fe/vtimonin/log/func.%A_%a.ou
#SBATCH --error=/work/gr-fe/vtimonin/log/func.%A_%a.err


echo "START AT $(date)"
set -e
cd /work/gr-fe/vtimonin/CHIPinHIV_UKB/data/mutect2_output/

all_files=($(<vcf.list))
REF="/CHIPinHIV_UKB/resources/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta"
DOCKER_IMAGE="/work/gr-fe/vtimonin/docker_images/gatk_latest.sif"
FUNC_RESOURCES="/CHIPinHIV_UKB/resources/funcotator_dataSources.v1.7.20200521s"


sample_id=${all_files[$SLURM_ARRAY_TASK_ID]}

echo $sample_id

singularity exec --bind /work/gr-fe/vtimonin/CHIPinHIV_UKB/:/CHIPinHIV_UKB $DOCKER_IMAGE gatk Funcotator \
     --variant "/CHIPinHIV_UKB/data/mutect2_output/$sample_id.normalized.vcf" \
     --reference $REF \
     --ref-version hg38 \
     --data-sources-path $FUNC_RESOURCES \
     --output "/CHIPinHIV_UKB/data/mutect2_output/$sample_id.funcotated.vcf" \
     --output-file-format VCF


echo "END AT $(date)"






