#!/bin/bash
#
# run_recon_all.sh
#
# Executes recon-all using all T1 and T2 scans available for a given subject within a given freesurfer subjects directory
#
# Data is assumed to be in <SUBJ>anat within a freesurfer directory. If you have a global $SUBJECTS_DIR set, to run for sub000 run like:
# run_recon_all.sh sub000
#
# If the data for sub000 lives in a directory other than freesurfer-defined $SUBJECTS_DIR, you'll need to specify that directory as the second arg:
# run_recon_all.sh sub000 /dir/where/data/lives
#
# To specify the number of cores, use the 3rd argument (remmeber, this is for each hemi, so use at most total # cores/2)
# run_recon_all.sh sub000 /dir/where/data/lives 18
# (note: for above, if using Freesurfer-set $SUBJECTS_DIR, use that as 2nd arg:
# run_recon_all.sh sub000 $SUBJECTS_DIR 18
#
# NOTES:
# - this doesn't work very well yet! does not dynamicallly scale to number of T1 images (TODO)
# - if specifying 3rd arg, must also specify subject directory (see above)


SUBJ=$1

# if 2 or more arguments, subjects_dir is the second one; otherwise, use the freesurfer one...
if [ $# -ge 2 ]
then
    SUBJ_DIR=$2
else
    SUBJ_DIR=$SUBJECTS_DIR   # otherwise, get the freesurfer value
fi



# if 3 arguments, use 3rd as # of 
if [ $# -ge 3 ]
then
    OPENMP_CORES=$3
else
    OPENMP_CORES=30
fi


#cd $SUBJECTS_DIR

# recon-all -autorecon1 -autorecon2 -autorecon3 -sd $SUBJECTS_DIR -subjid ${SUBJ}anat \
#     -i $SUBJECTS_DIR/${SUBJ}src/T1_1.nii* \
#     -i $SUBJECTS_DIR/${SUBJ}src/T1_2.nii* \
#     -i $SUBJECTS_DIR/${SUBJ}src/T1_3.nii* \
#     -expert $PREPROC/hires_expert \
#     -parallel -openmp 16 -hires


recon-all -autorecon1 -autorecon2 -autorecon3 -sd $SUBJ_DIR -subjid ${SUBJ}anat \
     -i  $SUBJ_DIR/${SUBJ}src/T1_1.nii* \
     -i  $SUBJ_DIR/${SUBJ}src/T1_2.nii* \
     -i  $SUBJ_DIR/${SUBJ}src/T1_3.nii* \
     -T2 $SUBJ_DIR/${SUBJ}src/T2_1.nii* \
     -expert $PREPROC/hires_expert \
     -T2pial -parallel -openmp $OPENMP_CORES -hires


#recon-all -autorecon1 -autorecon2 -autorecon3 -sd $SUBJ_DIR -subjid ${SUBJ}anat \
#    -i  $SUBJ_DIR/${SUBJ}src/T1_1.nii* \
#    -T2 $SUBJ_DIR/${SUBJ}src/T2_1.nii* \
#    -expert $PREPROC/hires_expert \
#    -T2pial -parallel -openmp $OPENMP_CORES -hires
