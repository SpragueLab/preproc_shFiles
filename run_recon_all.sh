#!/bin/bash


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
