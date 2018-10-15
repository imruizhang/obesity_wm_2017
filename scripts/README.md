## This is for documentation of how data was preprocessed in the publication zhang et al. 2018 (“White Matter Microstructural Variability Mediates the Relation between Obesity and Cognition in Healthy Adults.” NeuroImage 172 (February):239–49.)

### The script for preprocessing was reorganized but the content reminds unchanged. Orignially the preprocessing was done in seperated scripts (under folder ./orig, intenal only). 

### Preprocessing steps:
#### Note: LIFE Study was done using the twice-refocused spin-echo DTI

1. motion correction (eddy)
	- used eddy_correct (with default -dof 12)
	- rotating bvecs (used script following ENIGMA protocol: fdt\_rotate\_bvecs.sh)
2. skull stripping
	- bet
	- quality check for brain mask
	- correated brain mask manually
3. tensor fitting
	- dtifit
	- quality check for resulting images using QC_ENIGMA protocol
	- quality check for ghost artifact manualy
	

### Tract-Based Spacial Statistic (TBSS) analysis steps:

1. `tbss_1_preproc *.nii.gz`

2. check slicedir for quality

3. `tbss_2_reg -T` (we used a modified version to run this job parallel: tbss\_2\_mod\_par.sh)

4. `tbss_3_postreg -S`

5. `tbss_4_prestats 0.3`

6. design matrix files were created manually due to big sample size

7. Check the order of filenames, in FA directory: `imglob *_FA.*`, matched the ID of participant list

8. `randomise -i all_FA_skeletonised.nii.gz -o [output filename] -d design.mat -t design.con -m mean_FA_skeleton_mask -n 10000 -D --T2 -x --uncorrp`


### Region of interest analysis steps:

1. register ICBM-FA-1mm on FMRIB58\_FA\_1mm (reg\_ICBM\_FA.sh)

2. use the predefined label to calculate mean FA of each ROI (label\_ROI\_FA\_extraction.sh)
