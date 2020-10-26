#!/bin/bash
#
# surf_to_vol_targGrid.sh
#
# Used for transforming surface data from one session/resolution into volume data in grid from a different session/resolution
#
# Adapted from surf_to_vol_SEalign.sh, only difference is location things are saved and gridparent
#
# TCS 10/11/2017
#
# run like:
# surf_to_vol_targGrid.sh vRF_tcs CC RF1 surf 0 /deathstar/data/wmChoose_scanner/CC/MGSMap1/func01_volreg.nii.gz _25mm
# args:
# - SOURCE experiment directory (e.g., vRF_tcs)
# - SUBJ
# - SOURCE session name (e.g., RF1)
# - type of data (surf, blur)
# - FWHM (for non-blur, use "0"; it's ignored)
# - FULL PATH to a 'gridparent' dataset (the grid we want to render our data into)
# - SUFFIX to add to end of filename, must include an underscore/separation character if you need one
#
# above will create CC_RF1.r*_surf_25mm.nii.gz files in /vRF_tcs/CC/RF1/



#DATAROOT=/deathstar/data

#ROOT=/deathstar/data/vRF_tcs
EXPTDIR=$1

ROOT=$DATAROOT/$EXPTDIR

SUBJ=$2
FUNCSESS=$3


ANATSUBJ=${SUBJ}anat

#TR=$4   # TODO: figure out how to get this dynamically per run (hard w/ parallel command...)
SOURCESTR=$4



FWHM=$5
#CORES=8

GRIDPARENT=$6

TARGSUFFIX=$7



ALL_PREPROC_DIR=$(ls -d $ROOT/$SUBJ/$FUNCSESS/${SUBJ}_${FUNCSESS}*.results)

# OR ss5
if [[ $SOURCESTR = blur ]]; then
  #statements
  PBNUM=pb04
  FUNCSUFFIX=ss${FWHM}${TARGSUFFIX}
elif [[ $SOURCESTR = surf ]]; then
  #statements
  PBNUM=pb03
  FUNCSUFFIX=surf${TARGSUFFIX}
fi




#FUNCSUFFIX=ss5  # when saving (bar_widht_1_XXX), what to use? usually surf or ss$FWHM
#SOURCESTR=blur   # pb0X.$SOURCESTR.niml.dset (typically blur or surf)
#PBNUM=pb04       # pb03, surf OR pb04, blur

FUNCPREFIX_lh=$ROOT/$SUBJ/$FUNCSESS/${SUBJ}_${FUNCSESS}*.results/$PBNUM.${SUBJ}_${FUNCSESS}*.lh.r*.$SOURCESTR.niml.dset
FUNCPREFIX_rh=$ROOT/$SUBJ/$FUNCSESS/${SUBJ}_${FUNCSESS}*.results/$PBNUM.${SUBJ}_${FUNCSESS}*.rh.r*.$SOURCESTR.niml.dset



FUNCPREFIX=${SUBJ}_${FUNCSESS} #"pb04.CCpp2_CMRR4_unwarp_ss.lh.r03.blur.niml.dset"


cd $ROOT/$SUBJ/$FUNCSESS


# need this to have all the runs (within their individual .results directories)
# should include: pb03.CC_MGSMap1.lh.r01

rm $ROOT/$SUBJ/$FUNCSESS/func_list_lh.txt; for FUNC in $FUNCPREFIX_lh; do printf "%s\n" $FUNC | cut -f -5 -d . >> $ROOT/$SUBJ/$FUNCSESS/func_list_lh.txt; done
rm $ROOT/$SUBJ/$FUNCSESS/func_list_rh.txt; for FUNC in $FUNCPREFIX_rh; do printf "%s\n" $FUNC | cut -f -5 -d . >> $ROOT/$SUBJ/$FUNCSESS/func_list_rh.txt; done

# list of runs
rm $ROOT/$SUBJ/$FUNCSESS/run_list.txt; for FUNC in $FUNCPREFIX_lh; do printf "%s.%s\n" $FUNC | cut -f 5 -d .   >> $ROOT/$SUBJ/$FUNCSESS/run_list.txt; done


# list of output filenames

# want it to look like : CC_MGSMap1.r01 ($SUBJ_$FUNCSESS.$RUN)
# just make it, don't try to chop up (too tricky w/ SE)
#rm $ROOT/$SUBJ/$FUNCSESS/func_list.txt; for FUNC in $FUNCPREFIX_lh; do printf "%s.%s\n" $FUNC | cut -f 3,5 -d .   >> $ROOT/$SUBJ/$FUNCSESS/func_list.txt; done
rm $ROOT/$SUBJ/$FUNCSESS/func_list.txt; for FUNC in $(cat run_list.txt); do printf "${SUBJ}_$FUNCSESS.$FUNC\n" $FUNC >> $ROOT/$SUBJ/$FUNCSESS/func_list.txt; done



# move a volreg run (pb02) to FUNCSESS, rename appropriately`
#3dcopy $PREPROC_DIR/pb02.${SUBJ}_${FUNCSESS}.r01.volreg+orig $ROOT/$SUBJ/$FUNCSESS/${FUNCPREFIX}_r01.nii.gz
3dcopy $(ls $ROOT/$SUBJ/$FUNCSESS/${SUBJ}_${FUNCSESS}*.results/pb02.${SUBJ}_${FUNCSESS}*.r01.volreg+orig* | head -1) $ROOT/$SUBJ/$FUNCSESS/${FUNCPREFIX}_r01.nii.gz

TR=$(3dinfo -tr $ROOT/$SUBJ/$FUNCSESS/${FUNCPREFIX}_r01.nii.gz)


# how many runs? that's how many cores we want
CORES=$(cat $ROOT/$SUBJ/$FUNCSESS/func_list.txt | wc -l)


cd $ROOT/$SUBJ

# something like this works: cat ./func_list_lh.txt | parallel -C / echo printf "%s" {-1} | cut -f 3- -d .

# convert this back into vol (unsmoothed)
cat ./$FUNCSESS/func_list_lh.txt | parallel -P $CORES -C / \
3dSurf2Vol \
-spec ./${ANATSUBJ}/SUMA/${ANATSUBJ}_lh.spec \
-surf_A smoothwm \
-surf_B pial \
-sv ./${ANATSUBJ}/SUMA/${ANATSUBJ}_SurfVol+orig. \
-grid_parent $GRIDPARENT \
-map_func ave \
-f_steps 10 \
-prefix ./${FUNCSESS}/{-1}_$FUNCSUFFIX.nii.gz \
-sdata  ./${FUNCSESS}/{-2}/{-1}.$SOURCESTR.niml.dset

# convert this back into vol (unsmoothed)
cat ./$FUNCSESS/func_list_rh.txt | parallel -P $CORES -C / \
3dSurf2Vol \
-spec ./${ANATSUBJ}/SUMA/${ANATSUBJ}_rh.spec \
-surf_A smoothwm \
-surf_B pial \
-sv ./${ANATSUBJ}/SUMA/${ANATSUBJ}_SurfVol+orig. \
-grid_parent $GRIDPARENT \
-map_func ave \
-f_steps 10 \
-prefix ./${FUNCSESS}/{-1}_$FUNCSUFFIX.nii.gz \
-sdata  ./${FUNCSESS}/{-2}/{-1}.$SOURCESTR.niml.dset



# RENAME THEM TO SOMETHING SENSICAL
# TODO: figure out how to dynamically change pb03/pb04?
cat ./$FUNCSESS/run_list.txt | parallel -P $CORES \
mv ./$FUNCSESS/$PBNUM.$FUNCPREFIX*.rh.{}_$FUNCSUFFIX.nii.gz ./$FUNCSESS/rh_${FUNCPREFIX}.{}_$FUNCSUFFIX.nii.gz
#mv $(ls ./$FUNCSESS/$PBNUM.$FUNCPREFIX*.rh.{}_$FUNCSUFFIX.nii.gz | head 1) ./$FUNCSESS/rh_${FUNCPREFIX}.{}_$FUNCSUFFIX.nii.gz



cat ./$FUNCSESS/run_list.txt | parallel -P $CORES \
mv ./$FUNCSESS/$PBNUM.$FUNCPREFIX*.lh.{}_$FUNCSUFFIX.nii.gz ./$FUNCSESS/lh_${FUNCPREFIX}.{}_$FUNCSUFFIX.nii.gz


cat ./$FUNCSESS/func_list.txt | parallel -P $CORES \
3dcalc -prefix ./${FUNCSESS}/{}_$FUNCSUFFIX.nii.gz -a ./${FUNCSESS}/lh_{}_$FUNCSUFFIX.nii.gz -b ./${FUNCSESS}/rh_{}_$FUNCSUFFIX.nii.gz -expr "'(a+b)/(notzero(a)+notzero(b))'"

# NOTE: very hard to get this to work w/ parallel, so dropping it for now
#squeeze & reset TR [[_surf]]
for FUNC in $(cat ./$FUNCSESS/func_list.txt);
do
  matlab -nosplash -nojvm -nodesktop -r "setup_paths_RFs; nii=niftiRead('./${FUNCSESS}/${FUNC}_$FUNCSUFFIX.nii.gz'); nii=niftiSqueeze(nii,${TR}); niftiWrite(nii,'./${FUNCSESS}/${FUNC}_$FUNCSUFFIX.nii.gz'); exit;";
done


# finally, put them in RAI (preferred by vista; all ROIs in this orientation)
cat ./$FUNCSESS/func_list.txt | parallel -P $CORES \
3dresample -overwrite -prefix ./${FUNCSESS}/{}_$FUNCSUFFIX.nii.gz -orient rai -inset ./${FUNCSESS}/{}_$FUNCSUFFIX.nii.gz
