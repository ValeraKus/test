#!/bin/bash

#files=$(dx ls mutect2_output | grep "gz$")

files=$(dx ls mutect2_output | head -1)
reference="Bulk/Exome\ sequences/Exome\ OQFE\ CRAM\ files/helper_files/GRCh38_full_analysis_set_plus_decoy_hla.fa"
reference_idx="Bulk/Exome\ sequences/Exome\ OQFE\ CRAM\ files/helper_files/GRCh38_full_analysis_set_plus_decoy_hla.fa.fai"
reference_dict="Bulk/Exome\ sequences/Exome\ OQFE\ CRAM\ files/helper_files/GRCh38_full_analysis_set_plus_decoy_hla.dict"
intervals="resources/chipgenes_hg38.bed"
gnomad="resources/gnomad.simplified.vcf.gz"
gnomad_idx="resources/gnomad.simplified.vcf.gz.tbi"

IFS=$'\n' 

for file in $files
do

echo $file

file_path="/mutect2_output/$file"
file_path_idx="$file_path.tbi"
file_path_stats="$file_path.stats"
bam_name=$(echo $file | sed 's/\.vcf.gz/\.cram/')
bam="/Bulk/Exome\ sequences/Exome\ OQFE\ CRAM\ files/"${file:0:2}"/$bam_name"
bam_idx="$bam.crai"


dx run filer_mutect_calls \
-idocker_image="/docker_images/gatk.tar.gz" \
-iinput=$bam \
-iinput_idx=$bam_idx \
-ireference=$reference \
-ireference_index=$reference_idx \
-ireference_dict=$reference_dict \
-ivariant=$file_path \
-ivariant_idx=$file_path_idx \
-ivariant_stats=$file_path_stats \
-iintervals=$intervals \
-igermline_resource=$gnomad \
-igermline_resource_idx=$gnomad_idx \
-y

done