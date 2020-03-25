#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov  5 12:08:16 2019

@author: Chiara Marzi, Ph.D. student in Biomedical, Electrical and System Engineering,
at Dept. of Electrical, Electronic and Information Engineering – DEI "Guglielmo Marconi",
University of Bologna, Bologna, Italy. 
E-mail address: chiara.marzi3@unibo.it

fractalbrain toolkit e-mail address: fractalbraintoolkit@gmail.com
"""

# The asofi name was chosen as the acronym of Automated Selection of Fractal Indices
def asofi( subjid, image ):
    from fpdf import FPDF
    import logging
    import math
    import matplotlib.pyplot as plt
    plt.rcParams.update({'figure.max_open_warning': 0}) 
    import nibabel as nib
    import numpy as np
    import os
    import random
    import sklearn.metrics as skl
    import sys
    
    
    ### MANAGEMENT OF INPUT FILES: PATH, FILE NAME, EXTENSION, ETC. ###
    print ("Loading", image, "image...")
    imagepath = os.path.dirname(image)
    if not imagepath or imagepath == '.':
        imagepath = os.getcwd()
    imagefile = os.path.basename(image)
    imagename, image_extension = os.path.splitext(imagefile)
    imagename, image_extension = os.path.splitext(imagename)
    
    
    ### LOG FILE SETTING ###
    log_file_name = imagepath+'/'+subjid+'_fractal'
    log = logging.getLogger(log_file_name+'.asofi') 
    log.info('Started: image %s with prefix name %s', image, subjid)
    
    ### NIFTI IMAGE LOADING ###
    img = nib.load(image)
    nii_header = img.header
    imageloaded = img.get_fdata()
    
    ### CHECK THE IMAGE ISOTROPY ###
    voxels_size = nii_header['pixdim'][1:4]
    log.info('The voxel size is %s x %s x %s mm^3', voxels_size[0], voxels_size[1], voxels_size[2])
    if voxels_size[0] != voxels_size[1] or voxels_size[0] != voxels_size[2] or voxels_size[1] != voxels_size[2]:
      sys.exit('The voxel is not isotropic! Exit.')
      
    ### COMPUTING THE MINIMUM AND MAXIMUM SIZES OF THE IMAGE ###
    L_min = voxels_size[0]
    log.info('The minimum size of the image is %s mm', L_min)
    Ly=imageloaded.shape[0]
    Lx=imageloaded.shape[1]
    Lz=imageloaded.shape[2]
    if Lx > Ly:
        L_Max = Lx
    else:
        L_Max = Ly
    if Lz > L_Max:
        L_Max = Lz
    log.info('The maximum size of the image is %s mm', L_Max)

    ### NON-ZERO VOXELS OF THE IMAGE: NUMBER AND Y, X, Z COORDINATES ###
    voxels=[]
    for i in range(Ly):
        for j in range(Lx):
            for k in range(Lz):
                if imageloaded[i,j,k]>0:
                    voxels.append((i,j,k))
    voxels=np.asarray(voxels)
    log.info('The non-zero voxels in the image are (the image volume) %s', voxels.shape[0])
    
    ##### FRACTAL ANALYSIS #####
    ### LOGARITHM SCALES VECTOR AND COUNTS VECTOR CREATION ###
    Ns = []
    scales = []
    stop = math.ceil(math.log2(L_Max))
    for exp in range(stop+1):
        scales.append(2**exp)
    scales = np.asarray(scales)
    random.seed(1)
    
    ### THE 3D BOX-COUNTING ALGORITHM WITH 20 PSEUDO-RANDOM OFFSETS ###
    for scale in scales:
        log.info('Computing scale %s...', scale)
        Ns_offset=[] 
        for i in range(20): 
            y0_rand = -random.randint(0,scale)
            yend_rand = Ly+1+scale
            x0_rand = -random.randint(0,scale)
            xend_rand = Lx+1+scale
            z0_rand = -random.randint(0,scale)
            zend_rand = Lz+1+scale
            # computing the 3D histogram
            H, edges=np.histogramdd(voxels, bins=(np.arange(y0_rand,yend_rand,scale), np.arange(x0_rand,xend_rand,scale), np.arange(z0_rand,zend_rand,scale)))
            Ns_offset.append(np.sum(H>0))
            log.info('======= Offset %s: x0_rand = %s, y0_rand = %s, z0_rand = %s, count = %s ', i+1, x0_rand, y0_rand, z0_rand, np.sum(H>0))
        Ns.append(np.mean(Ns_offset))
    
    ### AUTOMATED SELECTION OF THE FRACTAL SCALING WINDOW ### 
    minWindowSize = 4 # in the logarithm scale, in the worst case, 4 points cover more than 0.5 decade, which should be the minimum fractal scaling window possible, to define an object as fractal (Marzi et al., in preparation)
    scales_indices = [] 

    for step in range(scales.size, minWindowSize-1, -1):
        for start_index in range(0, scales.size-step+1):
            scales_indices.append((start_index, start_index+step-1))
    scales_indices = np.asarray(scales_indices)    
    
    k_ind = 1 # number of indipendent variables in the regression model
    R2_adj = -1
    for k in range(scales_indices.shape[0]):
        coeffs=np.polyfit(np.log2(scales)[scales_indices[k,0]:scales_indices[k,1] + 1], np.log2(Ns)[scales_indices[k,0]:scales_indices[k,1] + 1], 1)
        n = scales_indices[k,1] - scales_indices[k,0] + 1 
        y_true = np.log2(Ns)[scales_indices[k,0]:scales_indices[k,1] + 1]
        y_pred = np.polyval(coeffs,np.log2(scales)[scales_indices[k,0]:scales_indices[k,1] + 1])
        R2=skl.r2_score(y_true,y_pred)
        R2_adj_tmp = 1 - (1 - R2)*((n - 1)/(n - (k_ind + 1)))
        log.info('In the interval [%s, %s] voxels, the FD is %s and the determination coefficient adjusted for the number of points is %s', scales[scales_indices[k,0]], scales[scales_indices[k,1]], -coeffs[0], R2_adj_tmp)
        R2_adj = round(R2_adj, 3)
        R2_adj_tmp = round(R2_adj_tmp, 3)
        if R2_adj_tmp > R2_adj:
            R2_adj = R2_adj_tmp
            FD = -coeffs[0]
            mfs = scales[scales_indices[k,0]]
            Mfs = scales[scales_indices[k,1]]
            fsw_index = k
            coeffs_selected = coeffs
        FD = round(FD, 4)
    
    ### FRACTAL ANALYSIS RESULTS ###
    mfs = mfs * L_min
    Mfs = Mfs * L_min
    log.info('The mfs automatically selected is %s', mfs)
    log.info('The Mfs automatically selected is %s', Mfs)
    log.info('The FD automatically selected is %s', FD)
    log.info('The R2_adj is %s', R2_adj)
    print("mfs automatically selected:", mfs)
    print("Mfs automatically selected:", Mfs)
    print("FD automatically selected:", FD)
    
    ### SAVING THE PLOT WITH THE AUTOMATED SELECTED FRACTAL SCALING WINDOW ###
    plt.figure()
    plt.plot(np.log2(scales),np.log2(Ns), 'o', mfc='none')
    plt.plot(np.log2(scales)[scales_indices[fsw_index,0]:scales_indices[fsw_index,1] + 1], np.polyval(coeffs_selected,np.log2(scales)[scales_indices[fsw_index,0]:scales_indices[fsw_index,1] + 1]))
    plt.xlabel('log $\epsilon$ (mm)')
    plt.ylabel('log N (-)')
    plt.savefig(imagepath+'/'+subjid+'_'+imagename+'_FD_plot.png')
    plt.clf()
    
    ### CREATION OF A TXT FILE WITH FRACTAL ANALYSIS RESULTS ###
    with open(imagepath+'/'+subjid+'_'+imagename+'_FractalIndices.txt', 'w') as f:
        f.write("mfs (mm), %f\n" % mfs)
        f.write("Mfs (mm), %f\n" % Mfs)
        f.write("FD (-), %f\n" % FD)
    
    ### CREATION OF A PDF FILE WITH FRACTAL ANALYSIS RESULTS ###
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Arial", size=12)
    pdf.cell(200, 10, txt="Subject    "+subjid, ln=1, align="C")
    pdf.cell(200, 10, txt="Image    "+imagefile, ln=1, align="C")
    pdf.cell(200, 10, txt="mfs    "+str(mfs)+" mm", ln=1, align="C")
    pdf.cell(200, 10, txt="Mfs    "+str(Mfs)+" mm", ln=1, align="C")
    pdf.cell(200, 10, txt="FD    "+str(FD), ln=1, align="C")
    pdf.cell(200, 10, txt="R2adj    "+str(R2_adj), ln=1, align="C")
    pdf.image(imagepath+'/'+subjid+'_'+imagename+'_FD_plot.png',x=60, w=100)
    pdf.output(imagepath+'/'+subjid+'_'+imagename+'_FD_summary.pdf')
   
    return
