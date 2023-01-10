#!/bin/bash

#files=$(cat resources/ukb/ukb.hiv.matched.control.exome.files.list.txt)
#files=$(cat files.to.analize.txt)
file1="/Bulk/Exome\ sequences/Exome\ OQFE\ CRAM\ files/10/1008498_23143_0_0.cram"
file2="/Bulk/Exome\ sequences/Exome\ OQFE\ CRAM\ files/10/1009077_23143_0_0.cram"


reference="Bulk/Exome\ sequences/Exome\ OQFE\ CRAM\ files/helper_files/GRCh38_full_analysis_set_plus_decoy_hla.fa"
reference_idx="Bulk/Exome\ sequences/Exome\ OQFE\ CRAM\ files/helper_files/GRCh38_full_analysis_set_plus_decoy_hla.fa.fai"
reference_dict="Bulk/Exome\ sequences/Exome\ OQFE\ CRAM\ files/helper_files/GRCh38_full_analysis_set_plus_decoy_hla.dict"
intervals="resources/chip.genes.bed"
gnomad="resources/af-only-gnomad.hg38.vcf.gz"
gnomad_idx="resources/af-only-gnomad.hg38.vcf.gz.tbi"
pon="PoN_vcf/pon.vcf.gz"
pon_idx="PoN_vcf/pon.vcf.gz.tbi"
gnomad_selected="resources/af-only-gnomad.hg38.biallelic.vcf.gz"
gnomad_selected_idx="resources/af-only-gnomad.hg38.biallelic.vcf.gz.tbi"



IFS=$'\n' 
for file in $file1 $file2
do
file_index="$file.crai"



dx run mutect2 \
-idocker_image="/docker_images/gatk.tar.gz" \
-iinput=$file \
-iinput_index=$file_index \
-ireference=$reference \
-ireference_index=$reference_idx \
-ireference_dict=$reference_dict \
-iintervals=$intervals \
-igermline_resource=$gnomad \
-igermline_resource_idx=$gnomad_idx \
-ipanel_of_normals=$pon \
-ipanel_of_normals_idx=$pon_idx \
-igermline_resource_selected=$gnomad_selected \
-igermline_resource_selected_idx=$gnomad_selected_idx \
-y \
--destination "mutect2_output"

done