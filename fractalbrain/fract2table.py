#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov  6 09:57:30 2019

@author: Chiara Marzi, Ph.D. student in Biomedical, Electrical and System Engineering,
at Dept. of Electrical, Electronic and Information Engineering – DEI "Guglielmo Marconi",
University of Bologna, Bologna, Italy. 
E-mail address: chiara.marzi3@unibo.it

fractalbrain toolkit e-mail address: fractalbraintoolkit@gmail.com
"""

import argparse
import csv
import os
import textwrap
import sys

### MANAGEMENT OF ARGUMENTS, USAGE AND HELP ###
class MyParser(argparse.ArgumentParser):
    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        sys.exit(2)

parser = MyParser(prog='fractalbrain.fract2table',
                  usage='%(prog)s [-h] prefix_list image_list',
                  formatter_class=argparse.RawDescriptionHelpFormatter,
                  epilog=textwrap.dedent('''\
                                        Examples: 
                                        python -m fractalbrain.fract2table prefixes_list.txt NifTI_list.txt
                                        ''')
                    )
parser.add_argument('prefix_list', metavar='prefix_list', help='the list containing all the prefixes names')
parser.add_argument('image_list', metavar='image_list', help='the list containing all the images which will be processed')
args = parser.parse_args()

### CSV FILE CREATION ###
print ("Writing FractalIndices_Results.csv...")
with open('FractalIndices_Results.csv', mode='w') as fid:
        fieldnames = ['Image', 'mfs (mm)', 'Mfs (mm)', 'FD (-)']
        writer = csv.DictWriter(fid, fieldnames=fieldnames)
        writer.writeheader()
### SEARCHING TXT FILES WITH RESULTS AND WRITING THEM IN THE CSV FILE ### 
with open(args.prefix_list, 'r') as fid_subj_list, open(args.image_list, 'r') as fid_imgs_list:
    for x, y in zip(fid_subj_list, fid_imgs_list):
       subjid = x.strip()
       image = y.strip()
       imagepath = os.path.dirname(image)
       if not imagepath or imagepath == '.':
           imagepath = os.getcwd()
       imagefile = os.path.basename(image)
       imagename, image_extension = os.path.splitext(imagefile)
       imagename, image_extension = os.path.splitext(imagename)
       text_file = imagepath+'/'+subjid+'_'+imagename+'_FractalIndices.txt'
       with open(text_file, 'r') as fid:
           reader = csv.reader(fid, delimiter=',')
           second_column = [ row[1] for row in reader ]
           row_to_write = subjid+'_'+imagename+',' + ', '.join(second_column)
           row_to_write = list(row_to_write.split(","))
       with open('FractalIndices_Results.csv', mode='a+') as fid:
           writer = csv.writer(fid, delimiter=',')
           writer.writerow(row_to_write)

print ("To see the results, type less FractalIndices_Results.csv or open it in a cvs reader")
            
