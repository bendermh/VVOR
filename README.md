# VVOR
MATLAB/OCTAVE script for VVOR &amp; VORS extended analysis. 


## INSTALL & USE
Copy all files to your MATLAB - OCTAVE documents directory.
+ MATLAB (ver. 2015b): You will need signal toolbox. To run VVOR navigate to your VVOR folder and type 'VVOR'
+ OCTAVE (ver. 4.0.3): You will need signal package, type `pkg install -forge control` and `pkg install -forge signal`, each time you open OCTAVE you need to type `pkg load signal` (this should be not neccesary if you use a previous to 4.2 version if you used `pkg install -forge -auto signal` command to install signal package). To run VVOR navigate to your VVOR folder and type 'VVOR'

## SUPPORTED VVOR FILES
To use VVOR you need the exported .csv results file from ICS Impulse version 4.0 ® (Only English or Spanish location are supported). If there are more than one test results on the file only the last test will be loaded (you can delete other existing VVOR test from .csv file easily using a text editor)
