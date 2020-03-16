
 mri_convert /data/MRdata/MPRAX1mmDICIOTTISTEFANO.nii.gz /data/MRdata/freesurfer/DICIOTTI_STEFANO/mri/orig/001.mgz 

#--------------------------------------------
#@# MotionCor Thu Nov 12 16:26:24 CET 2015

 cp /data/MRdata/freesurfer/DICIOTTI_STEFANO/mri/orig/001.mgz /data/MRdata/freesurfer/DICIOTTI_STEFANO/mri/rawavg.mgz 


 mri_convert /data/MRdata/freesurfer/DICIOTTI_STEFANO/mri/rawavg.mgz /data/MRdata/freesurfer/DICIOTTI_STEFANO/mri/orig.mgz --conform 


 mri_add_xform_to_header -c /data/MRdata/freesurfer/DICIOTTI_STEFANO/mri/transforms/talairach.xfm /data/MRdata/freesurfer/DICIOTTI_STEFANO/mri/orig.mgz /data/MRdata/freesurfer/DICIOTTI_STEFANO/mri/orig.mgz 

#--------------------------------------------
#@# Talairach Thu Nov 12 16:26:38 CET 2015

 mri_nu_correct.mni --n 1 --proto-iters 1000 --distance 50 --no-rescale --i orig.mgz --o orig_nu.mgz 


 talairach_avi --i orig_nu.mgz --xfm transforms/talairach.auto.xfm 


 cp transforms/talairach.auto.xfm transforms/talairach.xfm 

#--------------------------------------------
#@# Talairach Failure Detection Thu Nov 12 16:28:02 CET 2015

 talairach_afd -T 0.005 -xfm transforms/talairach.xfm 


 awk -f /usr/local/freesurfer/bin/extract_talairach_avi_QA.awk /data/MRdata/freesurfer/DICIOTTI_STEFANO/mri/transforms/talairach_avi.log 


 tal_QC_AZS /data/MRdata/freesurfer/DICIOTTI_STEFANO/mri/transforms/talairach_avi.log 

#--------------------------------------------
#@# Nu Intensity Correction Thu Nov 12 16:28:02 CET 2015

 mri_nu_correct.mni --i orig.mgz --o nu.mgz --uchar transforms/talairach.xfm --n 2 


 mri_add_xform_to_header -c /data/MRdata/freesurfer/DICIOTTI_STEFANO/mri/transforms/talairach.xfm nu.mgz nu.mgz 

#--------------------------------------------
#@# Intensity Normalization Thu Nov 12 16:29:19 CET 2015

 mri_normalize -g 1 nu.mgz T1.mgz 

#--------------------------------------------
#@# Skull Stripping Thu Nov 12 16:31:43 CET 2015

 mri_em_register -skull nu.mgz /usr/local/freesurfer/average/RB_all_withskull_2008-03-26.gca transforms/talairach_with_skull.lta 


 mri_watershed -T1 -brain_atlas /usr/local/freesurfer/average/RB_all_withskull_2008-03-26.gca transforms/talairach_with_skull.lta T1.mgz brainmask.auto.mgz 


 cp brainmask.auto.mgz brainmask.mgz 

#-------------------------------------
#@# EM Registration Thu Nov 12 17:12:01 CET 2015

 mri_em_register -uns 3 -mask brainmask.mgz nu.mgz /usr/local/freesurfer/average/RB_all_2008-03-26.gca transforms/talairach.lta 

#--------------------------------------
#@# CA Normalize Thu Nov 12 17:50:07 CET 2015

 mri_ca_normalize -c ctrl_pts.mgz -mask brainmask.mgz nu.mgz /usr/local/freesurfer/average/RB_all_2008-03-26.gca transforms/talairach.lta norm.mgz 

#--------------------------------------
#@# CA Reg Thu Nov 12 17:51:54 CET 2015

 mri_ca_register -nobigventricles -T transforms/talairach.lta -align-after -mask brainmask.mgz norm.mgz /usr/local/freesurfer/average/RB_all_2008-03-26.gca transforms/talairach.m3z 

#--------------------------------------
#@# CA Reg Inv Thu Nov 12 20:45:38 CET 2015

 mri_ca_register -invert-and-save transforms/talairach.m3z 

#--------------------------------------
#@# Remove Neck Thu Nov 12 20:46:36 CET 2015

 mri_remove_neck -radius 25 nu.mgz transforms/talairach.m3z /usr/local/freesurfer/average/RB_all_2008-03-26.gca nu_noneck.mgz 

#--------------------------------------
#@# SkullLTA Thu Nov 12 20:47:40 CET 2015

 mri_em_register -skull -t transforms/talairach.lta nu_noneck.mgz /usr/local/freesurfer/average/RB_all_withskull_2008-03-26.gca transforms/talairach_with_skull_2.lta 

#--------------------------------------
#@# SubCort Seg Thu Nov 12 21:24:29 CET 2015

 mri_ca_label -align norm.mgz transforms/talairach.m3z /usr/local/freesurfer/average/RB_all_2008-03-26.gca aseg.auto_noCCseg.mgz 


 mri_cc -aseg aseg.auto_noCCseg.mgz -o aseg.auto.mgz -lta /data/MRdata/freesurfer/DICIOTTI_STEFANO/mri/transforms/cc_up.lta DICIOTTI_STEFANO 

#--------------------------------------
#@# Merge ASeg Thu Nov 12 21:44:04 CET 2015

 cp aseg.auto.mgz aseg.mgz 

#--------------------------------------------
#@# Intensity Normalization2 Thu Nov 12 21:44:04 CET 2015

 mri_normalize -aseg aseg.mgz -mask brainmask.mgz norm.mgz brain.mgz 

#--------------------------------------------
#@# Mask BFS Thu Nov 12 21:48:00 CET 2015

 mri_mask -T 5 brain.mgz brainmask.mgz brain.finalsurfs.mgz 

#--------------------------------------------
#@# WM Segmentation Thu Nov 12 21:48:02 CET 2015

 mri_segment brain.mgz wm.seg.mgz 


 mri_edit_wm_with_aseg -keep-in wm.seg.mgz brain.mgz aseg.mgz wm.asegedit.mgz 


 mri_pretess wm.asegedit.mgz wm norm.mgz wm.mgz 

#--------------------------------------------
#@# Fill Thu Nov 12 21:50:18 CET 2015

 mri_fill -a ../scripts/ponscc.cut.log -xform transforms/talairach.lta -segmentation aseg.auto_noCCseg.mgz wm.mgz filled.mgz 

#--------------------------------------------
#@# Tessellate lh Thu Nov 12 21:51:08 CET 2015

 mri_pretess ../mri/filled.mgz 255 ../mri/norm.mgz ../mri/filled-pretess255.mgz 


 mri_tessellate ../mri/filled-pretess255.mgz 255 ../surf/lh.orig.nofix 


 rm -f ../mri/filled-pretess255.mgz 


 mris_extract_main_component ../surf/lh.orig.nofix ../surf/lh.orig.nofix 

#--------------------------------------------
#@# Smooth1 lh Thu Nov 12 21:51:15 CET 2015

 mris_smooth -nw -seed 1234 ../surf/lh.orig.nofix ../surf/lh.smoothwm.nofix 

#--------------------------------------------
#@# Inflation1 lh Thu Nov 12 21:51:20 CET 2015

 mris_inflate -no-save-sulc ../surf/lh.smoothwm.nofix ../surf/lh.inflated.nofix 

#--------------------------------------------
#@# QSphere lh Thu Nov 12 21:51:54 CET 2015

 mris_sphere -q -seed 1234 ../surf/lh.inflated.nofix ../surf/lh.qsphere.nofix 

#--------------------------------------------
#@# Fix Topology lh Thu Nov 12 21:55:58 CET 2015

 cp ../surf/lh.orig.nofix ../surf/lh.orig 


 cp ../surf/lh.inflated.nofix ../surf/lh.inflated 


 mris_fix_topology -mgz -sphere qsphere.nofix -ga -seed 1234 DICIOTTI_STEFANO lh 


 mris_euler_number ../surf/lh.orig 


 mris_remove_intersection ../surf/lh.orig ../surf/lh.orig 


 rm ../surf/lh.inflated 

#--------------------------------------------
#@# Make White Surf lh Thu Nov 12 22:06:55 CET 2015

 mris_make_surfaces -noaparc -whiteonly -mgz -T1 brain.finalsurfs DICIOTTI_STEFANO lh 

#--------------------------------------------
#@# Smooth2 lh Thu Nov 12 22:12:59 CET 2015

 mris_smooth -n 3 -nw -seed 1234 ../surf/lh.white ../surf/lh.smoothwm 

#--------------------------------------------
#@# Inflation2 lh Thu Nov 12 22:13:03 CET 2015

 mris_inflate ../surf/lh.smoothwm ../surf/lh.inflated 


 mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ../surf/lh.inflated 


#-----------------------------------------
#@# Curvature Stats lh Thu Nov 12 22:14:53 CET 2015

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/lh.curv.stats -F smoothwm DICIOTTI_STEFANO lh curv sulc 

#--------------------------------------------
#@# Sphere lh Thu Nov 12 22:14:57 CET 2015

 mris_sphere -seed 1234 ../surf/lh.inflated ../surf/lh.sphere 

#--------------------------------------------
#@# Surf Reg lh Thu Nov 12 22:58:40 CET 2015

 mris_register -curv ../surf/lh.sphere /usr/local/freesurfer/average/lh.average.curvature.filled.buckner40.tif ../surf/lh.sphere.reg 

#--------------------------------------------
#@# Jacobian white lh Thu Nov 12 23:22:00 CET 2015

 mris_jacobian ../surf/lh.white ../surf/lh.sphere.reg ../surf/lh.jacobian_white 

#--------------------------------------------
#@# AvgCurv lh Thu Nov 12 23:22:02 CET 2015

 mrisp_paint -a 5 /usr/local/freesurfer/average/lh.average.curvature.filled.buckner40.tif#6 ../surf/lh.sphere.reg ../surf/lh.avg_curv 

#-----------------------------------------
#@# Cortical Parc lh Thu Nov 12 23:22:04 CET 2015

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 DICIOTTI_STEFANO lh ../surf/lh.sphere.reg /usr/local/freesurfer/average/lh.curvature.buckner40.filled.desikan_killiany.2010-03-25.gcs ../label/lh.aparc.annot 

#--------------------------------------------
#@# Make Pial Surf lh Thu Nov 12 23:22:52 CET 2015

 mris_make_surfaces -white NOWRITE -mgz -T1 brain.finalsurfs DICIOTTI_STEFANO lh 

#--------------------------------------------
#@# Surf Volume lh Thu Nov 12 23:35:05 CET 2015

 mris_calc -o lh.area.mid lh.area add lh.area.pial 


 mris_calc -o lh.area.mid lh.area.mid div 2 


 mris_calc -o lh.volume lh.area.mid mul lh.thickness 

#-----------------------------------------
#@# WM/GM Contrast lh Thu Nov 12 23:35:05 CET 2015

 pctsurfcon --s DICIOTTI_STEFANO --lh-only 

#-----------------------------------------
#@# Parcellation Stats lh Thu Nov 12 23:35:12 CET 2015

 mris_anatomical_stats -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab DICIOTTI_STEFANO lh white 

#-----------------------------------------
#@# Cortical Parc 2 lh Thu Nov 12 23:35:28 CET 2015

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 DICIOTTI_STEFANO lh ../surf/lh.sphere.reg /usr/local/freesurfer/average/lh.destrieux.simple.2009-07-29.gcs ../label/lh.aparc.a2009s.annot 

#-----------------------------------------
#@# Parcellation Stats 2 lh Thu Nov 12 23:36:24 CET 2015

 mris_anatomical_stats -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.a2009s.stats -b -a ../label/lh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab DICIOTTI_STEFANO lh white 

#-----------------------------------------
#@# Cortical Parc 3 lh Thu Nov 12 23:36:42 CET 2015

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 DICIOTTI_STEFANO lh ../surf/lh.sphere.reg /usr/local/freesurfer/average/lh.DKTatlas40.gcs ../label/lh.aparc.DKTatlas40.annot 

#-----------------------------------------
#@# Parcellation Stats 3 lh Thu Nov 12 23:37:32 CET 2015

 mris_anatomical_stats -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.DKTatlas40.stats -b -a ../label/lh.aparc.DKTatlas40.annot -c ../label/aparc.annot.DKTatlas40.ctab DICIOTTI_STEFANO lh white 

#--------------------------------------------
#@# Tessellate rh Thu Nov 12 23:37:48 CET 2015

 mri_pretess ../mri/filled.mgz 127 ../mri/norm.mgz ../mri/filled-pretess127.mgz 


 mri_tessellate ../mri/filled-pretess127.mgz 127 ../surf/rh.orig.nofix 


 rm -f ../mri/filled-pretess127.mgz 


 mris_extract_main_component ../surf/rh.orig.nofix ../surf/rh.orig.nofix 

#--------------------------------------------
#@# Smooth1 rh Thu Nov 12 23:37:55 CET 2015

 mris_smooth -nw -seed 1234 ../surf/rh.orig.nofix ../surf/rh.smoothwm.nofix 

#--------------------------------------------
#@# Inflation1 rh Thu Nov 12 23:38:00 CET 2015

 mris_inflate -no-save-sulc ../surf/rh.smoothwm.nofix ../surf/rh.inflated.nofix 

#--------------------------------------------
#@# QSphere rh Thu Nov 12 23:38:29 CET 2015

 mris_sphere -q -seed 1234 ../surf/rh.inflated.nofix ../surf/rh.qsphere.nofix 

#--------------------------------------------
#@# Fix Topology rh Thu Nov 12 23:43:20 CET 2015

 cp ../surf/rh.orig.nofix ../surf/rh.orig 


 cp ../surf/rh.inflated.nofix ../surf/rh.inflated 


 mris_fix_topology -mgz -sphere qsphere.nofix -ga -seed 1234 DICIOTTI_STEFANO rh 


 mris_euler_number ../surf/rh.orig 


 mris_remove_intersection ../surf/rh.orig ../surf/rh.orig 


 rm ../surf/rh.inflated 

#--------------------------------------------
#@# Make White Surf rh Thu Nov 12 23:52:31 CET 2015

 mris_make_surfaces -noaparc -whiteonly -mgz -T1 brain.finalsurfs DICIOTTI_STEFANO rh 

#--------------------------------------------
#@# Smooth2 rh Thu Nov 12 23:58:33 CET 2015

 mris_smooth -n 3 -nw -seed 1234 ../surf/rh.white ../surf/rh.smoothwm 

#--------------------------------------------
#@# Inflation2 rh Thu Nov 12 23:58:38 CET 2015

 mris_inflate ../surf/rh.smoothwm ../surf/rh.inflated 


 mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ../surf/rh.inflated 


#-----------------------------------------
#@# Curvature Stats rh Fri Nov 13 00:00:29 CET 2015

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/rh.curv.stats -F smoothwm DICIOTTI_STEFANO rh curv sulc 

#--------------------------------------------
#@# Sphere rh Fri Nov 13 00:00:33 CET 2015

 mris_sphere -seed 1234 ../surf/rh.inflated ../surf/rh.sphere 

#--------------------------------------------
#@# Surf Reg rh Fri Nov 13 00:40:15 CET 2015

 mris_register -curv ../surf/rh.sphere /usr/local/freesurfer/average/rh.average.curvature.filled.buckner40.tif ../surf/rh.sphere.reg 

#--------------------------------------------
#@# Jacobian white rh Fri Nov 13 01:06:46 CET 2015

 mris_jacobian ../surf/rh.white ../surf/rh.sphere.reg ../surf/rh.jacobian_white 

#--------------------------------------------
#@# AvgCurv rh Fri Nov 13 01:06:49 CET 2015

 mrisp_paint -a 5 /usr/local/freesurfer/average/rh.average.curvature.filled.buckner40.tif#6 ../surf/rh.sphere.reg ../surf/rh.avg_curv 

#-----------------------------------------
#@# Cortical Parc rh Fri Nov 13 01:06:50 CET 2015

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 DICIOTTI_STEFANO rh ../surf/rh.sphere.reg /usr/local/freesurfer/average/rh.curvature.buckner40.filled.desikan_killiany.2010-03-25.gcs ../label/rh.aparc.annot 

#--------------------------------------------
#@# Make Pial Surf rh Fri Nov 13 01:07:41 CET 2015

 mris_make_surfaces -white NOWRITE -mgz -T1 brain.finalsurfs DICIOTTI_STEFANO rh 

#--------------------------------------------
#@# Surf Volume rh Fri Nov 13 01:19:04 CET 2015

 mris_calc -o rh.area.mid rh.area add rh.area.pial 


 mris_calc -o rh.area.mid rh.area.mid div 2 


 mris_calc -o rh.volume rh.area.mid mul rh.thickness 

#-----------------------------------------
#@# WM/GM Contrast rh Fri Nov 13 01:19:04 CET 2015

 pctsurfcon --s DICIOTTI_STEFANO --rh-only 

#-----------------------------------------
#@# Parcellation Stats rh Fri Nov 13 01:19:11 CET 2015

 mris_anatomical_stats -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab DICIOTTI_STEFANO rh white 

#-----------------------------------------
#@# Cortical Parc 2 rh Fri Nov 13 01:19:28 CET 2015

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 DICIOTTI_STEFANO rh ../surf/rh.sphere.reg /usr/local/freesurfer/average/rh.destrieux.simple.2009-07-29.gcs ../label/rh.aparc.a2009s.annot 

#-----------------------------------------
#@# Parcellation Stats 2 rh Fri Nov 13 01:20:28 CET 2015

 mris_anatomical_stats -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.a2009s.stats -b -a ../label/rh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab DICIOTTI_STEFANO rh white 

#-----------------------------------------
#@# Cortical Parc 3 rh Fri Nov 13 01:20:45 CET 2015

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 DICIOTTI_STEFANO rh ../surf/rh.sphere.reg /usr/local/freesurfer/average/rh.DKTatlas40.gcs ../label/rh.aparc.DKTatlas40.annot 

#-----------------------------------------
#@# Parcellation Stats 3 rh Fri Nov 13 01:21:35 CET 2015

 mris_anatomical_stats -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.DKTatlas40.stats -b -a ../label/rh.aparc.DKTatlas40.annot -c ../label/aparc.annot.DKTatlas40.ctab DICIOTTI_STEFANO rh white 

#--------------------------------------------
#@# Cortical ribbon mask Fri Nov 13 01:21:52 CET 2015

 mris_volmask --label_left_white 2 --label_left_ribbon 3 --label_right_white 41 --label_right_ribbon 42 --save_ribbon DICIOTTI_STEFANO 

#--------------------------------------------
#@# ASeg Stats Fri Nov 13 01:37:46 CET 2015

 mri_segstats --seg mri/aseg.mgz --sum stats/aseg.stats --pv mri/norm.mgz --empty --brainmask mri/brainmask.mgz --brain-vol-from-seg --excludeid 0 --excl-ctxgmwm --supratent --subcortgray --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --etiv --surf-wm-vol --surf-ctx-vol --totalgray --euler --ctab /usr/local/freesurfer/ASegStatsLUT.txt --subject DICIOTTI_STEFANO 

#-----------------------------------------
#@# AParc-to-ASeg Fri Nov 13 01:41:29 CET 2015

 mri_aparc2aseg --s DICIOTTI_STEFANO --volmask 


 mri_aparc2aseg --s DICIOTTI_STEFANO --volmask --a2009s 

#-----------------------------------------
#@# WMParc Fri Nov 13 01:44:22 CET 2015

 mri_aparc2aseg --s DICIOTTI_STEFANO --labelwm --hypo-as-wm --rip-unknown --volmask --o mri/wmparc.mgz --ctxseg aparc+aseg.mgz 


 mri_segstats --seg mri/wmparc.mgz --sum stats/wmparc.stats --pv mri/norm.mgz --excludeid 0 --brainmask mri/brainmask.mgz --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --subject DICIOTTI_STEFANO --surf-wm-vol --ctab /usr/local/freesurfer/WMParcStatsLUT.txt --etiv 

#--------------------------------------------
#@# BA Labels lh Fri Nov 13 01:54:40 CET 2015

 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA1.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA1.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA2.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA2.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA3a.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA3a.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA3b.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA3b.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA4a.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA4a.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA4p.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA4p.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA6.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA6.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA44.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA44.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA45.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA45.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.V1.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.V1.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.V2.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.V2.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.MT.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.MT.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.perirhinal.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.perirhinal.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA1.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA1.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA2.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA2.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA3a.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA3a.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA3b.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA3b.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA4a.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA4a.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA4p.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA4p.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA6.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA6.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA44.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA44.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.BA45.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.BA45.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.V1.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.V1.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.V2.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.V2.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/lh.MT.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./lh.MT.thresh.label --hemi lh --regmethod surface 


 mris_label2annot --s DICIOTTI_STEFANO --hemi lh --ctab /usr/local/freesurfer/average/colortable_BA.txt --l lh.BA1.label --l lh.BA2.label --l lh.BA3a.label --l lh.BA3b.label --l lh.BA4a.label --l lh.BA4p.label --l lh.BA6.label --l lh.BA44.label --l lh.BA45.label --l lh.V1.label --l lh.V2.label --l lh.MT.label --l lh.perirhinal.label --a BA --maxstatwinner --noverbose 


 mris_label2annot --s DICIOTTI_STEFANO --hemi lh --ctab /usr/local/freesurfer/average/colortable_BA.txt --l lh.BA1.thresh.label --l lh.BA2.thresh.label --l lh.BA3a.thresh.label --l lh.BA3b.thresh.label --l lh.BA4a.thresh.label --l lh.BA4p.thresh.label --l lh.BA6.thresh.label --l lh.BA44.thresh.label --l lh.BA45.thresh.label --l lh.V1.thresh.label --l lh.V2.thresh.label --l lh.MT.thresh.label --a BA.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -mgz -f ../stats/lh.BA.stats -b -a ./lh.BA.annot -c ./BA.ctab DICIOTTI_STEFANO lh white 


 mris_anatomical_stats -mgz -f ../stats/lh.BA.thresh.stats -b -a ./lh.BA.thresh.annot -c ./BA.thresh.ctab DICIOTTI_STEFANO lh white 

#--------------------------------------------
#@# BA Labels rh Fri Nov 13 01:58:46 CET 2015

 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA1.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA1.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA2.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA2.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA3a.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA3a.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA3b.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA3b.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA4a.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA4a.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA4p.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA4p.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA6.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA6.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA44.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA44.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA45.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA45.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.V1.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.V1.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.V2.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.V2.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.MT.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.MT.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.perirhinal.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.perirhinal.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA1.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA1.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA2.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA2.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA3a.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA3a.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA3b.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA3b.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA4a.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA4a.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA4p.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA4p.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA6.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA6.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA44.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA44.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.BA45.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.BA45.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.V1.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.V1.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.V2.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.V2.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /data/MRdata/freesurfer/fsaverage/label/rh.MT.thresh.label --trgsubject DICIOTTI_STEFANO --trglabel ./rh.MT.thresh.label --hemi rh --regmethod surface 


 mris_label2annot --s DICIOTTI_STEFANO --hemi rh --ctab /usr/local/freesurfer/average/colortable_BA.txt --l rh.BA1.label --l rh.BA2.label --l rh.BA3a.label --l rh.BA3b.label --l rh.BA4a.label --l rh.BA4p.label --l rh.BA6.label --l rh.BA44.label --l rh.BA45.label --l rh.V1.label --l rh.V2.label --l rh.MT.label --l rh.perirhinal.label --a BA --maxstatwinner --noverbose 


 mris_label2annot --s DICIOTTI_STEFANO --hemi rh --ctab /usr/local/freesurfer/average/colortable_BA.txt --l rh.BA1.thresh.label --l rh.BA2.thresh.label --l rh.BA3a.thresh.label --l rh.BA3b.thresh.label --l rh.BA4a.thresh.label --l rh.BA4p.thresh.label --l rh.BA6.thresh.label --l rh.BA44.thresh.label --l rh.BA45.thresh.label --l rh.V1.thresh.label --l rh.V2.thresh.label --l rh.MT.thresh.label --a BA.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -mgz -f ../stats/rh.BA.stats -b -a ./rh.BA.annot -c ./BA.ctab DICIOTTI_STEFANO rh white 


 mris_anatomical_stats -mgz -f ../stats/rh.BA.thresh.stats -b -a ./rh.BA.thresh.annot -c ./BA.thresh.ctab DICIOTTI_STEFANO rh white 

#--------------------------------------------
#@# Ex-vivo Entorhinal Cortex Label lh Fri Nov 13 02:03:07 CET 2015

 mris_spherical_average -erode 1 -orig white -t 0.4 -o DICIOTTI_STEFANO label lh.entorhinal lh sphere.reg lh.EC_average lh.entorhinal_exvivo.label 


 mris_anatomical_stats -mgz -f ../stats/lh.entorhinal_exvivo.stats -b -l ./lh.entorhinal_exvivo.label DICIOTTI_STEFANO lh white 

#--------------------------------------------
#@# Ex-vivo Entorhinal Cortex Label rh Fri Nov 13 02:03:23 CET 2015

 mris_spherical_average -erode 1 -orig white -t 0.4 -o DICIOTTI_STEFANO label rh.entorhinal rh sphere.reg rh.EC_average rh.entorhinal_exvivo.label 


 mris_anatomical_stats -mgz -f ../stats/rh.entorhinal_exvivo.stats -b -l ./rh.entorhinal_exvivo.label DICIOTTI_STEFANO rh white 

