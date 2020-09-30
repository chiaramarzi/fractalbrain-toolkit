 # fractalbrain toolkit

*fractalbrain* is a simple, easy-to-use, and efficient toolkit for fractal analysis of the human brain - starting from Magnetic Resonance structural images (sMRI) -  and generic fractal structures. It computes the fractal dimension (FD), the minimal fractal scale (mfs) and the maximal fractal scale (Mfs) of the automatically selected fractal scaling window, that is the spatial window within which the structure manifests the highest self-similarity. *fractalbrain* fills the gap between the theory of fractal geometry and its numerical implementation, especially in the Neuroimaging field. It is able to easily run on FreeSurfer outputs.

This document provides a quick introduction to the fractalbrain toolkit to help new users get started.  

*fractalbrain* is available at https://github.com/chiaramarzi/fractalbrain-toolkit.
Please read the [LICENSE.md](./LICENSE.md) file before using fractalbrain.

## Installation
### Installing via Git
Open a terminal window (for Unix users) or Anaconda Prompt (for Windows users), activate or create a Python environment (we recommend to create a new Python environment, see below) and type:

```
pip install git+https://github.com/chiaramarzi/fractalbrain-toolkit.git
```

### Installing via GitHub download
Download the latest version of fractalbrain-toolkit from LINK - you will get a file that looks like fractalbrain-toolkit-master.zip

Open a terminal window (for Unix users) or Anaconda Prompt (for Windows users), activate or create a Python environment (we recommend to create a new Python environment, see below) and type:

```
pip install your-path/fractalbrain-toolkit-master.zip
```

### Create a new local Python virtual environment using conda:
1. Create a new folder with the name of your new environment (e.g., fbt_env)
2. Open a terminal window (for Unix users) or Anaconda Prompt (for Windows users), from the folder that contains fbt_env directory and type:

```
conda create --prefix ./fbt_env
```

```
conda activate ./fbt_env
```

```
conda install python
```

### Uninstalling fractalbrain toolkit

```
pip uninstall fractalbrain
```

## Getting Started

### Overview of the toolkit
The *fractalbrain toolkit* contains different modules able to compute the fractal indices (FD, mfs and Mfs) of 3D binary isotropic NifTI volumes.

### Working with FreeSurfer outputs
If the user has pre-processed the MRI T1-weighted images using FreeSurfer, obtaining the *subjid/mri/aparc+aseg.mgz* file:

1. Copy the bash script [bin/FS_binarization.sh](./bin/FS_binarization.sh) in your bin folder or in a folder included in the PATH
2. Use the *fractalbrain.fs_fract* module:

```
python -m fractalbrain.fs_fract -h

usage: fractalbrain.fs_fract [-h] [--lobes] [--hemi] [--brain] subjid

positional arguments:
  subjid      the FreeSurfer subjid folder that will be processed or a file containing a list of FreeSurfer subjid folders. In the latter case, the fractal analysis will be
              performed on each subject sequentially

optional arguments:
  -h, --help  show this help message and exit
  --lobes     fractal analysis on lobes
  --hemi      fractal analysis on cerebral and cerebellar GM and WM, separated for left and right hemispheres
  --brain     fractal analysis on cerebral and cerebellar GM and WM (DEFAULT)

Examples: 
python -m fractalbrain.fs_fract --lobes --brain subjid
python -m fractalbrain.fs_fract --hemi subjid
python -m fractalbrain.fs_fract subjid
python -m fractalbrain.fs_fract --lobes subjid_list.txt
python -m fractalbrain.fs_fract subjid_list.txt
```
3. If the user has performed *fractalbrain.fs_fract* on a file containing a list of subjects directories, it is possible to collect the results in a unique CSV file, using *fractalbrain.fs_fract2table*:

```
python -m fractalbrain.fs_fract2table -h

usage: fractalbrain.fs_fract2table [-h] [--lobes] [--hemi] [--brain] subjid_list

positional arguments:
  subjid_list  the list containing all the FreeSurfer subjid folders which will be processed

optional arguments:
  -h, --help   show this help message and exit
  --lobes      fractal analysis on lobes
  --hemi       fractal analysis on cerebral and cerebellar GM and WM, separated for left ah right hemispheres
  --brain      fractal analysis on cerebral and cerebellar GM and WM (DEFAULT)

Examples: 
python -m fractalbrain.fs_fract2table --lobes subjid_list.txt
python -m fractalbrain.fs_fract2table subjid_list.tx 
NOTE: the options --lobes, --hemi, --brain (DEFAULT) must be the same used previously for fractalbrain.fs_fract
```

Both *fractalbrain.fs_fract* and *fractalbrain.fs_fract2table* are able to work with FreeSurfer output (aparc+aseg.mgz) and with the folders tree established by FreeSurfer developers. *fractalbrain.fs_fract* creates subjid/fractal-analysis folder and works in it. *fractalbrain.fs_fract2table* writes in the folder containing all the FreeSurfer subjid directories.
The folders automatically created by FreeSurfer procedure are not modified by the fractalbrain toolkit.

### Working with other 3D isotropic binary NifTI images
If the user wants to apply fractal analysis on his own 3D isotropic binary NifTI images:

1. Use the module *fractalbrain.fract*:

```
python -m fractalbrain.fract -h

usage: fractalbrain.fract [-h] prefix image

positional arguments:
  prefix      the prefix name of the NifTI image that will be processed or a file containing a list of prefixes
  image       the NifTI image that will be processed or a file containing a list of NifTI images. In the latter case, the fractal analysis will be performed on each NifTI image
              sequentially

optional arguments:
  -h, --help  show this help message and exit

Examples: 
python -m fractalbrain.fract subjid image.nii.gz
python -m fractalbrain.fract sub001 cerebralGM.nii.gz
python -m fractalbrain.fract prefixes_list.txt NifTI_list.txt
```

2. If the user has performed *fractalbrain.fract* on a file containing a list of subjects directories, it is possible to collect the results in a unique CSV file, using *fractalbrain.fract2table*:

```
python -m fractalbrain.fract2table -h

usage: fractalbrain.fract2table [-h] prefix_list image_list

positional arguments:
  prefix_list  the list containing all the prefixes names
  image_list   the list containing all the images which will be processed

optional arguments:
  -h, --help   show this help message and exit

Examples: 
python -m fractalbrain.fract2table prefixes_list.txt NifTI_list.txt
```

## Testing
There are two folders of tests distributed with the code: [test/fs_subjects_examples](./test/fs_subjects_examples) and [test/phantoms_examples](./test/phantoms_examples).

### Test on FreeSurfer outputs
To run the test on FreeSurfer outputs:
1. Go to the [test/fs_subjects_examples](./test/fs_subjects_examples) folder
2. From the terminal window (for Unix users) or Anaconda Prompt (for Windows users), run, for the 'sub001' FreeSurfer folder: 

```
python -m fractalbrain.fs_fract sub001
```

or, for all the FreeSurfer folders contained the list file 'subjid_list.txt':

```
python -m fractalbrain.fs_fract subjid_list.txt
```

3. Read the fractal indices in the file *sub001/fractal-analysis/sub001_\*_FractalIndices.txt*, or collect the results of the list files in a CSV file, running:

```
python -m fractalbrain.fs_fract2table subjid_list.txt
```

and open *FractalIndices_Results.csv*

### Test on 3D isotropic binary fractal NifTI volumes
1. Go to the [test/phantoms_examples](./test/phantoms_examples) folder
2. From the terminal window (for Unix users) or Anaconda Prompt (for Windows users), type, for the Menger’s sponge phantom:  

```
python -m fractalbrain.fract menger menger_level5.nii.gz
```

or, for all the NifTI images and prefixes contained in the list files 'prefix_list.tx't and 'NifTI_list.txt', respectively: 

```
python -m fractalbrain.fract prefix_list.txt NifTI_list.txt
```

3. Read the fractal indices in the file *menger_menger_level5_FractalIndices.txt*, or collect the results of the list files in a CSV file running: 

```
python -m fractalbrain.fract2table prefix_list.txt NifTI_list.txt
```

and open *FractalIndices_Results.csv*

## Authors
* [**Chiara Marzi**](https://www.unibo.it/sitoweb/chiara.marzi3/en) - *Ph.D. student in Biomedical, Electrical and System Engineering, Dept. of Electrical, Electronic and Information Engineering – DEI "Guglielmo Marconi", University of Bologna, Bologna, Italy.* Email address: <chiara.marzi3@unibo.it>

* [**Stefano Diciotti**](https://www.unibo.it/sitoweb/stefano.diciotti/en) - *Associate Professor in Biomedical Engineering, Dept. of Electrical, Electronic and Information Engineering – DEI "Guglielmo Marconi", University of Bologna, Bologna, Italy.* Email address: <stefano.diciotti@unibo.it>

## Contribution, help, bug reports, feature requests
The developers welcome contributions to the fractalbrain toolkit. Please contact the developers at <fractalbraintoolkit@gmail.com> if you would like to contribute code, or for any questions and comments.
Bug reports should include sufficient information to reproduce the problem.

## Additional Information
If you use and find the *fractalbrain toolkit* helpful, please cite it as:

Marzi, C., Giannelli, M., Tessa, C., Mascalchi, M., and Diciotti, S. (2020). **Toward a more reliable characterization of fractal properties of the cerebral cortex of healthy subjects during the lifespan**. Scientific Reports (IN PRESS)

Other related references:

Marzi, C., Ciulli, S., Giannelli, M., Ginestroni, A., Tessa, C.,
Mascalchi, M., and Diciotti, S. (2018). **Structural Complexity of
the Cerebellum and Cerebral Cortex is Reduced in
Spinocerebellar Ataxia Type 2**. Journal of neuroimaging : official
journal of the American Society of Neuroimaging 28 6, pp. 688–693. PMID: [29975004](https://www.ncbi.nlm.nih.gov/pubmed/29975004)

Pantoni, L., Marzi, C., Poggesi, A., Giorgio, A., De Stefano, N.,
Mascalchi, M., Inzitari, D., Salvadori, E., and Diciotti, S. (2019). **Fractal dimension of cerebral white matter: A consistent feature
for prediction of the cognitive performance in patients with
small vessel disease and mild cognitive impairment**.
NeuroImage: Clinical. PMID: [31491677](https://www.ncbi.nlm.nih.gov/pubmed/?term=Fractal+dimension+of+cerebral+white+matter%3A+A+consistent+feature+for+prediction+of+the+cognitive+performance+in+patients+with+small+vessel+disease+and+mild+cognitive+impairment)













