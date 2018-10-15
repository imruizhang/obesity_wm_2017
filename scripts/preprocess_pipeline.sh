#!/bin/bash

#usage: ./preprocess_pipeline.sh [subListFile]
#usage: sh preprocessing_pipeline.sh [subListFile]
#Implemented ENIGMA pipeline
#@author: zhang@cbs.mpg.de

#define directories
orig_dir="life"
results_dir="dti_preprocessing"


while read DEM
do 

subject="${DEM}"

echo "=========================================="
echo "    Preparing files for $subject"
echo "=========================================="

echo " -creating folders in the results folder"
echo " --------------------------------------"
#create folders for results
mkdir -p $results_dir/$subject
#create folders for checking
mkdir -p $results_dir/$subject/check


#find the first subject MRI folder because of two times scans for few subjects
first_dir=$(find $orig_dir -d -name $subject* | sort)
echo $first_dir
set -- $first_dir

echo " -copying diffusion-weighted imges"
echo " --------------------------------"
#copy the first in the list of DTI-images found
dti_name=$(find $1 -name *DTI_100.nii*)
# dti_name=$(find $1 -name *_diff*.nii* | sort) #some subjects were done with the ep2d_diff protocol
echo $dti_name
dti_arr=($dti_name)
nifti_tool -copy_im -prefix $results_dir/$subject/DTI_100.nii -infiles ${dti_arr[0]}
echo "${dti_arr[0]}" >> $results_dir/$subject/check/images_used.txt

echo " -copying bval and bvec files"
echo " ---------------------------"
#copy the first in the list of bval found
bval_name=$(find $1 -name *DTI_100.bval*)
# bval_name=$(find $1 -name *_diff*.bval*) #some subjects were done with the ep2d_diff protocol
echo $bval_name
bval_arr=($bval_name)
cp ${bval_arr[0]} $results_dir/$subject/DTI_100.bval.gz
gunzip -f $results_dir/$subject/DTI_100.bval.gz


#copy the first in the list of bval found
bvec_name=$(find $1 -name *DTI_100.bvec*)
# bvec_name=$(find $1 -name *_diff*.bvec*) #some subjects were done with the ep2d_diff protocol
echo $bvec_name
bvec_arr=($bvec_name)
cp ${bvec_arr[0]} $results_dir/$subject/DTI_100.bvec.gz
gunzip -f $results_dir/$subject/DTI_100.bvec.gz

echo "=========================================="
echo "    Preprocessing of ${subject}"
echo "=========================================="

cd $dir/$subject

#eddy current correction
echo " -Correcting for motions"
echo " -----------------------"
eddy_correct DTI_100.nii ${subject}.DTI_100_ecc 0
# eddy_correct DTI_100.nii ${subject}.DTI_100_ecc 61 #some subjects have b0 at volume 61
#get the b0 image for bet
# fslroi ${subject}.DTI_100_ecc ${subject}.nodif 61 1

#rotate bvec
sh fdt_rotate_bvecs.sh DTI_100.bvec DTI_100.rotated.bvec ${subject}.DTI_100_ecc.ecclog

#creat brain mask (#using Center of Gravity)
echo " -Brain mask using bet"
echo " ---------------------"

cmd="echo `fslstats $subject.DTI_100_ecc.nii.gz -C > $subject.bet.cog.txt`"
echo $cmd
$cmd 

X=`awk '{print $1}' $subject.bet.cog.txt`
Y=`awk '{print $2}' $subject.bet.cog.txt`
Z=`awk '{print $3}' $subject.bet.cog.txt`

bet $subject.DTI_100_ecc.nii.gz $subject.DTI_100_bet.nii.gz -m -c $X $Y $Z -f 0.1

echo " -tensor fitting"
echo " ---------------"
#brain mask was corrected manually for some subjects after visual check which identified mistakes after bet
if [ -f $subject.DTI_100_bet_mask_corr.hdr ]; then
	mask="$subject.DTI_100_bet_mask_corr.hdr"
	else
	mask="$subject.DTI_100_bet_mask"
fi

# --sse output sum of squared errors

dtifit -k $subject.DTI_100_ecc -m $mask -r DTI_100.rotated.bvec -b DTI_100.bval -o ${subject}_DTI_100 --sse


done < ${1}
