#!/usr/bin/env python

"""
@author: Chiara Marzi, Ph.D. student in Biomedical, Electrical and System Engineering,
at Dept. of Dept. of Electrical, Electronic and Information Engineering – DEI "Guglielmo Marconi",
University of Bologna, Bologna, Italy. 
E-mail address: chiara.marzi3@unibo.it

fractalbrain toolkit e-mail address: fractalbraintoolkit@gmail.com
"""

from distutils.core import setup

setup(name='fractalbrain',
    version='1.0',
    #description='Python Distribution Utilities',
    author='Chiara Marzi',
    author_email='chiara.marzi3@unibo.it',
    #url='https://www.python.org/sigs/distutils-sig/',
    #packages=setuptools.find_packages(),
    packages=['fractalbrain'],
    install_requires=[
        'fpdf',
        'matplotlib',
        'nibabel',
        'pandas',
        'scikit-learn',    
    ],
     )
