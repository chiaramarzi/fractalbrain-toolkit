#!/bin/sh

OPTIND=1 #The variable OPTIND holds the number of options parsed by the last call to getopts. It is common practice to call the shift command at the end of your processing loop to remove options that have already been handled from $@.

LOBES_FLAG=0
HEMI_FLAG=0
BRAIN_FLAG=0
LOBES_USR=0
HEMI_USR=0

while getopts "lhba?" opt; do
    case "$opt" in
    \?) echo "Usage: $0 [-?] [-l | -h | -b ] subjID"
	  exit 0
	;;
    l)
        echo "bash: lobes"
	LOBES_FLAG=1
	LOBES_USR=1	
        ;;
    h)  echo "bash: hemi"
	LOBES_FLAG=1
	HEMI_FLAG=1
	HEMI_USR=1
        ;;
    b)  echo "bash: brain"
	LOBES_FLAG=1
	HEMI_FLAG=1
	BRAIN_FLAG=1
        ;;
    esac
done

#echo "$#"

if [ "$#" -eq "1" ]
then
	LOBES_FLAG=1
	HEMI_FLAG=1
	BRAIN_FLAG=1
fi

shift $((OPTIND-1))

if [ "$#" -lt "1" ]
then
	echo
	echo "Usage: $0 [-h] [-l | -h | -b] subjID"
	echo
	exit 1
fi


SUBJID=$1
echo "$SUBJID"
echo "LOBES_FLAG: $LOBES_FLAG"
echo "HEMI_FLAG: $HEMI_FLAG"
echo "BRAIN_FLAG: $BRAIN_FLAG"
echo "LOBES_USR: $LOBES_USR"
echo "HEMI_USR: $HEMI_USR"

if [ $LOBES_FLAG == 1 ] && [ $LOBES_USR == 0 ]
then
	echo "lobes will be processed...but then deleted..."
elif [ $LOBES_FLAG == 1 ] && [ $LOBES_USR == 1 ]
then
	echo "lobes will be processed..."
fi

if [ $HEMI_FLAG == 1 ] && [ $HEMI_USR == 0 ]
then
	echo "hemispheres will be processed...but then deleted..."
elif [ $HEMI_FLAG == 1 ] && [ $HEMI_USR == 1 ]
then
	echo "hemispheres will be processed..."
fi

if [ $BRAIN_FLAG == 1 ] 
then
	echo "brain will be processed..."
fi


MGZ=aparc+aseg.mgz
NII=aparc+aseg.nii.gz
IMG_PATH=${SUBJID}/mri
mri_convert ${IMG_PATH}/$MGZ ${IMG_PATH}/$NII

############################## LOBES ##############################
if [ $LOBES_FLAG == 1 ]
then
	
	LOBES=(frontal parietal temporal occipital)
	
	for i in ${LOBES[@]}
	do
		if [ $i == frontal ]
		then
			thr=(3 12 14 17 18 19 20 24 27 28 32)
		elif [ $i == parietal ]
		then
			thr=(29 8 31 22 25)
		elif [ $i == temporal ]
		then
			thr=(30 15 9 1 7 34 6 33 16)
		else
			thr=(11 13 5 21)
		fi

		LEFT_LOBE_GM=lh_${i}GM.nii.gz
		RIGHT_LOBE_GM=rh_${i}GM.nii.gz
		structures=(${LEFT_LOBE_GM} ${RIGHT_LOBE_GM})

		fslmaths ${IMG_PATH}/$NII -sub ${IMG_PATH}/$NII ${IMG_PATH}/${LEFT_LOBE_GM}
		fslmaths ${IMG_PATH}/$NII -sub ${IMG_PATH}/$NII ${IMG_PATH}/${RIGHT_LOBE_GM}
		
		segbase=(1000 2000)
		ind=0
		
		for j in ${segbase[@]}
		do
			for k in ${thr[@]}
			do
				fslmaths ${IMG_PATH}/$NII -uthr $(( $j + $k )) -thr $(( $j + $k ))  -bin -mul 255 ${IMG_PATH}/$(( $j + $k )).nii.gz
				fslmaths ${IMG_PATH}/${structures[${ind}]} -add ${IMG_PATH}/$(( $j + $k )).nii.gz ${IMG_PATH}/${structures[${ind}]}
				rm -rf ${IMG_PATH}/$(( $j + $k )).nii.gz	
			done
			((ind=ind+1))
		done
	done
fi

############################## HEMISPHERES ##############################
if [ $HEMI_FLAG == 1 ]
then
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CEREBRAL GM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	NO_LOBES=(cingulate insula)
	for i in ${NO_LOBES[@]}
	do
		if [ $i == cingulate ]
		then
			thr=(2 10 23 26)
		else
			thr=35
		fi

		LEFT_NO_LOBE_GM=lh_${i}GM.nii.gz
		RIGHT_NO_LOBE_GM=rh_${i}GM.nii.gz
		structures=(${LEFT_NO_LOBE_GM} ${RIGHT_NO_LOBE_GM})

		fslmaths ${IMG_PATH}/$NII -sub ${IMG_PATH}/$NII ${IMG_PATH}/${LEFT_NO_LOBE_GM}
		fslmaths ${IMG_PATH}/$NII -sub ${IMG_PATH}/$NII ${IMG_PATH}/${RIGHT_NO_LOBE_GM}
		
		segbase=(1000 2000)
		ind=0
		
		for j in ${segbase[@]}
		do
			for k in ${thr[@]}
			do
				fslmaths ${IMG_PATH}/$NII -uthr $(( $j + $k )) -thr $(( $j + $k ))  -bin -mul 255 ${IMG_PATH}/$(( $j + $k )).nii.gz
				fslmaths ${IMG_PATH}/${structures[${ind}]} -add ${IMG_PATH}/$(( $j + $k )).nii.gz ${IMG_PATH}/${structures[${ind}]}
				rm -rf ${IMG_PATH}/$(( $j + $k )).nii.gz	
			done
			((ind=ind+1))
		done
	done

	LEFT_CEREBRAL_GM=lh_cerebralGM.nii.gz
	RIGHT_CEREBRAL_GM=rh_cerebralGM.nii.gz
	fslmaths ${IMG_PATH}/lh_frontalGM.nii.gz -add ${IMG_PATH}/lh_parietalGM.nii.gz -add ${IMG_PATH}/lh_temporalGM.nii.gz -add ${IMG_PATH}/lh_occipitalGM.nii.gz -add ${IMG_PATH}/lh_cingulateGM.nii.gz -add ${IMG_PATH}/lh_insulaGM.nii.gz -bin -mul 255 ${IMG_PATH}/$LEFT_CEREBRAL_GM
	fslmaths ${IMG_PATH}/rh_frontalGM.nii.gz -add ${IMG_PATH}/rh_parietalGM.nii.gz -add ${IMG_PATH}/rh_temporalGM.nii.gz -add ${IMG_PATH}/rh_occipitalGM.nii.gz -add ${IMG_PATH}/rh_cingulateGM.nii.gz -add ${IMG_PATH}/rh_insulaGM.nii.gz -bin -mul 255 ${IMG_PATH}/$RIGHT_CEREBRAL_GM
	
	for i in ${NO_LOBES[@]}
	do
		LEFT_NO_LOBE_GM=lh_${i}GM.nii.gz
		RIGHT_NO_LOBE_GM=rh_${i}GM.nii.gz
		rm -rf ${IMG_PATH}/$LEFT_NO_LOBE_GM
		rm -rf ${IMG_PATH}/$RIGHT_NO_LOBE_GM
	done

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CEREBRAL WM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	LEFT_CEREBRAL_WM=lh_cerebralWM.nii.gz
	RIGHT_CEREBRAL_WM=rh_cerebralWM.nii.gz
	fslmaths ${IMG_PATH}/$NII -uthr 2 -thr 2  -bin -mul 255 ${IMG_PATH}/$LEFT_CEREBRAL_WM
	fslmaths ${IMG_PATH}/$NII -uthr 41 -thr 41  -bin -mul 255 ${IMG_PATH}/$RIGHT_CEREBRAL_WM

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CEREBELLAR GM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	LEFT_CEREBELLAR_GM=lh_cerebellarGM.nii.gz
	RIGHT_CEREBELLAR_GM=rh_cerebellarGM.nii.gz
	fslmaths ${IMG_PATH}/$NII -uthr 8 -thr 8  -bin -mul 255 ${IMG_PATH}/$LEFT_CEREBELLAR_GM
	fslmaths ${IMG_PATH}/$NII -uthr 47 -thr 47  -bin -mul 255 ${IMG_PATH}/$RIGHT_CEREBELLAR_GM

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CEREBELLAR WM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	LEFT_CEREBELLAR_WM=lh_cerebellarWM.nii.gz
	RIGHT_CEREBELLAR_WM=rh_cerebellarWM.nii.gz
	fslmaths ${IMG_PATH}/$NII -uthr 7 -thr 7  -bin -mul 255 ${IMG_PATH}/$LEFT_CEREBELLAR_WM
	fslmaths ${IMG_PATH}/$NII -uthr 46 -thr 46  -bin -mul 255 ${IMG_PATH}/$RIGHT_CEREBELLAR_WM
fi
###################################################################


############################## BRAIN ##############################
if [ $BRAIN_FLAG == 1 ]
then
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CEREBRAL GM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	fslmaths ${IMG_PATH}/$LEFT_CEREBRAL_GM -add ${IMG_PATH}/$RIGHT_CEREBRAL_GM ${IMG_PATH}/cerebralGM.nii.gz
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CEREBRAL WM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	fslmaths ${IMG_PATH}/$LEFT_CEREBRAL_WM -add ${IMG_PATH}/$RIGHT_CEREBRAL_WM ${IMG_PATH}/cerebralWM.nii.gz
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CEREBELLAR GM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	fslmaths ${IMG_PATH}/$LEFT_CEREBELLAR_GM -add ${IMG_PATH}/$RIGHT_CEREBELLAR_GM ${IMG_PATH}/cerebellarGM.nii.gz
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CEREBELLAR WM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	fslmaths ${IMG_PATH}/$LEFT_CEREBELLAR_WM -add ${IMG_PATH}/$RIGHT_CEREBELLAR_WM ${IMG_PATH}/cerebellarWM.nii.gz

fi

if [ $LOBES_USR == 0 ] && [ $LOBES_FLAG == 1 ]
then
	echo "lobes deleting..."
	
	LOBES=(frontal parietal temporal occipital)
	
	for k in ${LOBES[@]}
	do
		LEFT_LOBE_GM=lh_${k}GM.nii.gz
		RIGHT_LOBE_GM=rh_${k}GM.nii.gz
		rm -rf ${IMG_PATH}/$LEFT_LOBE_GM
		rm -rf ${IMG_PATH}/$RIGHT_LOBE_GM
	done	
	
fi

if [ $HEMI_USR == 0 ] && [ $HEMI_FLAG == 1 ]
then
	echo "hemispheres deleting..."
	
	rm -rf ${IMG_PATH}/$LEFT_CEREBRAL_GM
	rm -rf ${IMG_PATH}/$RIGHT_CEREBRAL_GM
	rm -rf ${IMG_PATH}/$LEFT_CEREBRAL_WM
	rm -rf ${IMG_PATH}/$RIGHT_CEREBRAL_WM
	rm -rf ${IMG_PATH}/$LEFT_CEREBELLAR_GM
	rm -rf ${IMG_PATH}/$RIGHT_CEREBELLAR_GM
	rm -rf ${IMG_PATH}/$LEFT_CEREBELLAR_WM
	rm -rf ${IMG_PATH}/$RIGHT_CEREBELLAR_WM
	
fi

rm -rf ${IMG_PATH}/$NII


	






