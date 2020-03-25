#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov  6 11:21:22 2019

@author: Chiara Marzi, Ph.D. student in Biomedical, Electrical and System Engineering,
at Dept. of Electrical, Electronic and Information Engineering – DEI "Guglielmo Marconi",
University of Bologna, Bologna, Italy. 
E-mail address: chiara.marzi3@unibo.it

fractalbrain toolkit e-mail address: fractalbraintoolkit@gmail.com
"""

import argparse
import csv
import os
import pandas as pd
import textwrap
import sys

### MANAGEMENT OF ARGUMENTS, USAGE AND HELP ###
class MyParser(argparse.ArgumentParser):
    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        sys.exit(2)

parser = MyParser(prog='fractalbrain.fs_fract2table',
                  usage='%(prog)s [-h] [--lobes] [--hemi] [--brain] subjid_list',
                  formatter_class=argparse.RawDescriptionHelpFormatter,
                  epilog=textwrap.dedent('''\
                                        Examples: 
                                        python -m fractalbrain.fs_fract2table --lobes subjid_list.txt
                                        python -m fractalbrain.fs_fract2table subjid_list.tx 
                                        NOTE: the options --lobes, --hemi, --brain (DEFAULT) must be the same used previously for fractalbrain.fs_fract
                                        ''')
                )                                                                                                                 
parser.add_argument('subjid_list', metavar='subjid_list', help='the list containing all the FreeSurfer subjid folders which will be processed')
parser.add_argument('--lobes', action='store_true', help='fractal analysis on lobes')
parser.add_argument('--hemi', action='store_true', help='fractal analysis on cerebral and cerebellar GM and WM, separated for left ah right hemispheres')
parser.add_argument('--brain', action='store_true', help='fractal analysis on cerebral and cerebellar GM and WM (DEFAULT)')
args = parser.parse_args()
structures_list = []   
if args.lobes: 
    structures_list = structures_list + ['lh_frontalGM', 'rh_frontalGM', 'lh_parietalGM', 'rh_parietalGM', 'lh_temporalGM', 'rh_temporalGM', 'lh_occipitalGM', 'rh_occipitalGM']          
if args.hemi:
    structures_list = structures_list + ['lh_cerebralGM', 'rh_cerebralGM', 'lh_cerebralWM', 'rh_cerebralWM', 'lh_cerebellarGM', 'rh_cerebellarGM', 'lh_cerebellarWM', 'rh_cerebellarWM']            
if args.brain:
    structures_list = structures_list + ['cerebralGM', 'cerebralWM', 'cerebellarGM', 'cerebellarWM']
if not args.lobes and not args.hemi and not args.brain:
    structures_list = structures_list + ['cerebralGM', 'cerebralWM', 'cerebellarGM', 'cerebellarWM']

all_csv_filenames = []
for structure in structures_list:
    ### CSV FILES CREATION: ONE FOR EACH STRUCTURE ###
    structure_csv_filename = structure+'_FractalIndices_Results.csv'
    print ("Writing", structure_csv_filename+"..." )
    all_csv_filenames.append(structure_csv_filename)
    ### SEARCHING TXT FILES WITH RESULTS AND WRITING THEM IN THE CSV FILE OF EACH STRUCTURE ###
    with open(structure_csv_filename, mode='w') as fid:
        fieldnames = ['Image', structure+' mfs (mm)', structure+' Mfs (mm)', structure+' FD (-)']
        writer = csv.DictWriter(fid, fieldnames=fieldnames)
        writer.writeheader()
    with open(args.subjid_list, 'r') as fid_list: 
        for line in fid_list:
            subjid = line.rstrip()
            image = subjid+'/fractal-analysis/'+structure+'.nii.gz'
            imagepath = os.path.dirname(image)
            if not imagepath or imagepath == '.':
                imagepath = os.getcwd()
            imagefile = os.path.basename(image)
            imagename, image_extension = os.path.splitext(imagefile)
            imagename, image_extension = os.path.splitext(imagename)
            text_file = imagepath+'/'+subjid+'_'+imagename+'_FractalIndices.txt'
            isfile = os.path.isfile(text_file)
            if isfile is False:
                raise Exception("Attention, you must call the results collection only on the images you have processed")
            with open(text_file, 'r') as fid:
                reader = csv.reader(fid, delimiter=',')
                second_column = [ row[1] for row in reader ]
                row_to_write = subjid+',' + ', '.join(second_column)
                row_to_write = list(row_to_write.split(",")) 
            with open(structure_csv_filename, mode='a+') as fid:
                writer = csv.writer(fid, delimiter=',')
                writer.writerow(row_to_write)

### COMBINE ALL THE CSV FILES IN A UNIQUE ONE ###
csv_out = pd.read_csv(all_csv_filenames[0])
for f in all_csv_filenames[1:]:
    csv_right = pd.read_csv(f)
    csv_out = pd.merge(csv_out, csv_right)
csv_out.to_csv( "FractalIndices_Results.csv", index=False, encoding='utf-8-sig')
print ("Writing FractalIndices_Results.csv..." )
print ("To see the results, type less FractalIndices_Results.csv or open it in a cvs reader")
