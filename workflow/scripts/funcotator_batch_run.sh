#!/bin/bash

#files=$(cat cat resources/ukb/ukb.hiv.matched.control.exome.files.list.txt | grep -o "[0-9].*_[0-9].*_0_0" | sed "s/^[0-9][0-9]\//\/mutect2_output\//" | sed 's/$/\.vcf\.gz/')
file1="mutect2_output/1008498_23143_0_0.vcf.gz"
file2="mutect2_output/1009077_23143_0_0.vcf.gz"

#files="mutect2_output/6010992_23143_0_0.vcf.gz"

reference="Bulk/Exome\ sequences/Exome\ OQFE\ CRAM\ files/helper_files/GRCh38_full_analysis_set_plus_decoy_hla.fa"
reference_idx="Bulk/Exome\ sequences/Exome\ OQFE\ CRAM\ files/helper_files/GRCh38_full_analysis_set_plus_decoy_hla.fa.fai"
reference_dict="Bulk/Exome\ sequences/Exome\ OQFE\ CRAM\ files/helper_files/GRCh38_full_analysis_set_plus_decoy_hla.dict"
gatk_docker_image="/docker_images/gatk.tar.gz"
vt_docker_image="/docker_images/vt.tar.gz"
funcotator_resources="/resources/funcotator_dataSources.v1.7.20200521s.tar.gz"


IFS=$'\n' 
for file in $file1 $file2
do

echo $file
file_index="$file.tbi"

dx run funcotator \
-igatk_docker_image=$gatk_docker_image \
-ivt_docker_image=$vt_docker_image \
-iinput=$file \
-iinput_index=$file_index \
-ireference=$reference \
-ireference_index=$reference_idx \
-ireference_dict=$reference_dict \
-ifuncotator_resources=$funcotator_resources \
-y \
--destination "funcotator_output/"

done