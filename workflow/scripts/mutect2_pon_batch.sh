#!/bin/bash

files=$(cat resources/ukb/pon_file_paths.txt)

reference="Bulk/Exome\ sequences/Exome\ OQFE\ CRAM\ files/helper_files/GRCh38_full_analysis_set_plus_decoy_hla.fa"
reference_idx="Bulk/Exome\ sequences/Exome\ OQFE\ CRAM\ files/helper_files/GRCh38_full_analysis_set_plus_decoy_hla.fa.fai"
reference_dict="Bulk/Exome\ sequences/Exome\ OQFE\ CRAM\ files/helper_files/GRCh38_full_analysis_set_plus_decoy_hla.dict"
intervals="resources/chip.genes.bed"


IFS=$'\n' 
for file in $files
do

file_index="$file.crai"

echo $file_index

dx run mutect2_pon \
-idocker_image="/docker_images/gatk.tar.gz" \
-iinput=$file \
-iinput_index=$file_index \
-ireference=$reference \
-ireference_index=$reference_idx \
-ireference_dict=$reference_dict \
-iintervals=$intervals \
-y \
--destination "PoN_vcf/"


done
