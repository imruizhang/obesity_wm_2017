#!/bin/bash
# register ICBM labels on FMRIB58_FA_1mm template
dir="/nobackup/aventurin4/LIFE/2017_tbss/all_FA/stats"

echo "---------------------------------------------------------------"
echo "registration of ICBM-FA-1mm on FMRIB58_FA_1mm using flirt+fnirt"
echo "---------------------------------------------------------------"

flirt -in /usr/share/fsl/5.0/data/atlases/JHU/JHU-ICBM-FA-1mm.nii.gz -ref /usr/share/fsl/5.0/data/standard/FMRIB58_FA_1mm.nii.gz -omat ${dir}/ICBM_on_FMRIB58_transf.mat

fnirt --in=/usr/share/fsl/5.0/data/atlases/JHU/JHU-ICBM-FA-1mm.nii.gz --config=FA_2_FMRIB58_1mm --aff=${dir}/ICBM_on_FMRIB58_transf.mat --cout=${dir}/warp_ICBM_on_FMRIB58_nonlinear


echo "-----------------------------------"
echo "apply transformation to ICBM labels"
echo "-----------------------------------"

applywarp --ref=/usr/share/fsl/5.0/data/standard/FMRIB58_FA_1mm.nii.gz --in=/usr/share/fsl/5.0/data/atlases/JHU/JHU-ICBM-labels-1mm.nii.gz --out=${dir}/warped_ICBM_labels_on_FMRIB58_FA --warp=${dir}/warp_ICBM_on_FMRIB58_nonlinear

