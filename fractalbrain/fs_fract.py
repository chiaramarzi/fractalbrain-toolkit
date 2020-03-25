#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 13 13:25:34 2019

@author: Chiara Marzi, Ph.D. student in Biomedical, Electrical and System Engineering,
at Dept. of Electrical, Electronic and Information Engineering – DEI "Guglielmo Marconi",
University of Bologna, Bologna, Italy. 
E-mail address: chiara.marzi3@unibo.it

fractalbrain toolkit e-mail address: fractalbraintoolkit@gmail.com
"""

def fs_fract( subjid, brain, hemi, lobes ):
    from fractalbrain.asofi import asofi
    import logging
    import os
    import shutil
    import subprocess
    import time
    import datetime
    
    ### START TIME ###
    start_time = time.process_time() 
    start_time_to_log = time.asctime( time.localtime(time.time()) )
    print ("### Started at", start_time_to_log)
    print(" ")
    NOW = datetime.datetime.now()
    DATE = NOW.strftime("%Y-%m-%d")
    TIME = NOW.strftime("%H:%M:%S")
    
    ### PREPARATION OF THE NAMES OF THE BRAIN STRUCTURES CHOSEN BY THE USER ###
    structures_list = []
    bash_args = ''
    structure_DIR = ''
    
    if lobes: 
        structures_list = structures_list + ['lh_frontalGM.nii.gz', 'rh_frontalGM.nii.gz', 'lh_parietalGM.nii.gz', 'rh_parietalGM.nii.gz', 'lh_temporalGM.nii.gz', 'rh_temporalGM.nii.gz', 'lh_occipitalGM.nii.gz', 'rh_occipitalGM.nii.gz']
        bash_args = bash_args + 'l' 
        structure_DIR = structure_DIR + 'Lobes'
    if hemi:
        structures_list = structures_list + ['lh_cerebralGM.nii.gz', 'rh_cerebralGM.nii.gz', 'lh_cerebralWM.nii.gz', 'rh_cerebralWM.nii.gz', 'lh_cerebellarGM.nii.gz', 'rh_cerebellarGM.nii.gz', 'lh_cerebellarWM.nii.gz', 'rh_cerebellarWM.nii.gz']
        bash_args = bash_args + 'h'    
        structure_DIR = structure_DIR + 'Hemi'             
    if brain:
        structures_list = structures_list + ['cerebralGM.nii.gz', 'cerebralWM.nii.gz', 'cerebellarGM.nii.gz', 'cerebellarWM.nii.gz']
        bash_args = bash_args + 'b'     
        structure_DIR = structure_DIR + 'Brain'
    if not lobes and not hemi and not brain:
        structures_list = structures_list + ['cerebralGM.nii.gz', 'cerebralWM.nii.gz', 'cerebellarGM.nii.gz', 'cerebellarWM.nii.gz']
        structure_DIR = structure_DIR + 'Brain'
        
    ### LOG FILE SETTING ###
    log_file_name = subjid+'/mri/'+subjid+'_fractal'
    log = logging.getLogger(log_file_name)
    hdlr = logging.FileHandler(log_file_name+'.log', mode="w")
    formatter = logging.Formatter(fmt = '%(asctime)s - %(message)s', datefmt='%Y/%m/%d %H:%M:%S') 
    hdlr.setFormatter(formatter)
    log.addHandler(hdlr) 
    log.setLevel(logging.INFO)
    
    log.info('Started at %s', start_time_to_log)
    
    ### BINARIZATION ###
    log.info('Starting the binarization process...')
    command = "FS_binarization.sh" 
    print ("Binarization of "+subjid+"/mri/aparc+aseg.mgz image...")
    print (" ")
    with open(subjid+'/mri/FS_bin.txt', 'w') as fid:
        if bash_args:
            bash_args = '-' + bash_args
            subprocess.run([command, bash_args, subjid], stdout=fid)
        else:
            subprocess.run([command, subjid], stdout=fid)
    with open(subjid+'/mri/FS_bin.txt', 'r') as fid:
        to_log = fid.read()
        log.info('%s', to_log)
    os.remove(subjid+'/mri/FS_bin.txt')
    
    
    ### SETTING FRACTAL-ANALYSIS FOLDER ###
    FRACTAL_ANALYSIS_DIR = 'fractal-analysis'
    os.makedirs(subjid+'/'+FRACTAL_ANALYSIS_DIR+'/', exist_ok=True)
    
    ### FRACTAL ANALYSIS ON EACH STRUCTURE CHOSEN BY THE USER ###
    for structure in structures_list:
        image = subjid+'/mri/'+structure 
        imagepath = os.path.dirname(image) 
        if not imagepath or imagepath == '.':
            imagepath = os.getcwd()
        imagename, image_extension = os.path.splitext(structure)
        imagename, image_extension = os.path.splitext(imagename) 
        
        asofi(subjid, image)

        print("Moving", image, "to", subjid+'/'+FRACTAL_ANALYSIS_DIR+'/'+structure )
        shutil.move(image, subjid+'/'+FRACTAL_ANALYSIS_DIR+'/'+structure)
        print("Creating fractal plot in", subjid+'/'+FRACTAL_ANALYSIS_DIR+'/'+subjid+'_'+imagename+'_FD_plot.png')
        shutil.move(imagepath+'/'+subjid+'_'+imagename+'_FD_plot.png', subjid+'/'+FRACTAL_ANALYSIS_DIR+'/'+subjid+'_'+imagename+'_FD_plot.png')
        print("Writing fractal results PDF summary to", subjid+'/'+FRACTAL_ANALYSIS_DIR+'/'+subjid+'_'+imagename+'_FD_summary.pdf')
        shutil.move(imagepath+'/'+subjid+'_'+imagename+'_FD_summary.pdf', subjid+'/'+FRACTAL_ANALYSIS_DIR+'/'+subjid+'_'+imagename+'_FD_summary.pdf')
        print("Writing fractal results to", subjid+'/'+FRACTAL_ANALYSIS_DIR+'/'+subjid+'_'+imagename+'_FractalIndices.txt')
        print(" ")
        shutil.move(imagepath+'/'+subjid+'_'+imagename+'_FractalIndices.txt', subjid+'/'+FRACTAL_ANALYSIS_DIR+'/'+subjid+'_'+imagename+'_FractalIndices.txt')
        
    end_time = time.process_time()
    end_time_to_log = time.asctime( time.localtime(time.time()) )
    print ("### Ended at", time.asctime( time.localtime(time.time()) ))
    print (" ")
    elapsed_time = end_time - start_time
    
    log.info('#----------------------------------------')
    log.info('Started at %s', start_time_to_log)
    log.info('Ended at %s', end_time_to_log)
    log.info('fs_fract-run-time-seconds %s', elapsed_time)
    
    shutil.move(imagepath+'/'+subjid+'_fractal.log', subjid+'/'+FRACTAL_ANALYSIS_DIR+'/'+subjid+'_fractal_'+structure_DIR+'_'+DATE+'_'+TIME+'.log')
    return;

#####################################################################################################################    
if __name__ == "__main__":
    import argparse
    import os
    import textwrap
    import sys

    ### MANAGEMENT OF ARGUMENTS, USAGE AND HELP ###
    class MyParser(argparse.ArgumentParser):
        def error(self, message):
            sys.stderr.write('error: %s\n' % message)
            self.print_help()
            sys.exit(2)

    parser = MyParser(prog='fractalbrain.fs_fract',
                      usage='%(prog)s [-h] [--lobes] [--hemi] [--brain] subjid',
                      formatter_class=argparse.RawDescriptionHelpFormatter,
                      epilog=textwrap.dedent('''\
                                            Examples: 
                                            python -m fractalbrain.fs_fract --lobes --brain subjid
                                            python -m fractalbrain.fs_fract --hemi subjid
                                            python -m fractalbrain.fs_fract subjid
                                            python -m fractalbrain.fs_fract --lobes subjid_list.txt
                                            python -m fractalbrain.fs_fract subjid_list.txt
                                            ''')
                    )
    parser.add_argument('subjid', metavar='subjid', help='the FreeSurfer subjid folder that will be processed or a file containing a list of FreeSurfer subjid folders. In the latter case, the fractal analysis will be performed on each subject sequentially')
    parser.add_argument('--lobes', action='store_true', help='fractal analysis on lobes')
    parser.add_argument('--hemi', action='store_true', help='fractal analysis on cerebral and cerebellar GM and WM, separated for left and right hemispheres')
    parser.add_argument('--brain', action='store_true', help='fractal analysis on cerebral and cerebellar GM and WM (DEFAULT)')
    args = parser.parse_args()
    
    ### CHECK IF THE USER PASSED DIRECTLY THE FOLDER OF THE FREESURFER SUBJECT OR A LIST CONTAINING THE FOLDERS OF THE FREESURFER SUBJECTS ###
    if os.path.isdir(args.subjid):
        print (args.subjid, 'is a FreeSurfer folder')
        print (" ")
        fs_fract(**vars(args))
    elif os.path.isfile(args.subjid):
        print (args.subjid, 'is a file containing the list of FreeSurfer folders')
        print (" ")
        with open(args.subjid, 'r') as fid_list:
            for line in fid_list:
                subjid = line.rstrip() 
                print ("--> subjid:", subjid, "<--")
                fs_fract( subjid, lobes=args.lobes, hemi=args.hemi, brain=args.brain )
    
    

    
    
