#!/bin/bash
#for the FA value on ROI
#
#written by zhang@cbs.mpg.de
#

results_dir1="/nobackup/aventurin4/LIFE/2017_tbss/young_599/FA"
results_dir2="/nobackup/aventurin4/LIFE/2017_tbss/old_656/FA"
mask_dir="/nobackup/aventurin4/LIFE/2017_tbss/all_FA/stats/results/bmi_FA"
label_dir="/nobackup/aventurin4/LIFE/2017_tbss/all_FA/stats/label_ROI"

#label's tags and names
label_n1="5"
label_1="CC_splenium"

#label_n2="23"
#label_2="ACR_right"

echo "---------------------"
echo "$label_1"
#echo "$label_2"
echo "---------------------"

#define input and output files
input_ICBM="$label_dir/warped_ICBM_labels_on_FMRIB58_FA.nii.gz"
input_file="masked_tfce_corrp_095_all_FA_1255_bmi_corr_agesex_wmh_tstat2.nii.gz"
out_file1="${label_1}_bmi_FA_tstat2.nii.gz"
#out_file2="${label_2}_bmi_FA_tstat2.nii.gz"
roi_name="bmi_meanFA"

echo "------------------------------------------"
echo "getting ROI on TBSS obesity-related tracts"
echo "------------------------------------------"

fslmaths $input_ICBM -uthr ${label_n1} -thr ${label_n1} $label_dir/${label_1}
#fslmaths $input_ICBM -uthr ${label_n2} -thr ${label_n2} $label_dir/${label_2}

echo "------------------------------------------"
echo "masking ROI on TBSS obesity-related tracts"
echo "------------------------------------------"


fslmaths $mask_dir/${input_file} -mas ${label_dir}/${label_1} $mask_dir/${out_file1}
#fslmaths $mask_dir/${input_file} -mas ${label_dir}/${label_2} $mask_dir/${out_file2}



echo "------------------"
echo "getting FA of ROIs"
echo "------------------"

list="/home/raid1/zhang/Documents/2017/LIFE/R/subj_lists/subj_list_all_tbss_1255"

for subject in `cat ${list}`

do


echo $subject 
if [ -f $results_dir1/${subject}_DTI_100_FA_FA_to_target.nii.gz ]; then
	cd $results_dir1
else
	cd $results_dir2
fi


a="`fslstats ${subject}_DTI_100_FA_FA_to_target.nii.gz -k $mask_dir/${out_file1} -m`"
echo $subject $a >> /home/raid1/zhang/Documents/2017/LIFE/R/dataset/FA/$roi_name.${label_1}.txt

#a="`fslstats ${subject}_DTI_100_FA_FA_to_target.nii.gz -k $mask_dir/${out_file2} -m`"
#echo $subject $a >> /home/raid1/zhang/Documents/2017/LIFE/R/dataset/FA/$roi_name.${label_2}.txt



done
