# bsrn-converter
Convert Baseline Surface Radiation Network (BSRN) raw data files (tab delimited text files via PANGAEA https://dataportals.pangaea.de/bsrn/) to MATLAB binary files

# About BSRN
http://bsrn.awi.de/
https://dataportals.pangaea.de/bsrn/

% Solar position calculator
This script needs sun position calculator by Vicent Roy, see http://blogs.mathworks.com/pick/2010/07/16/sun_positionm/

# Input
Download 12 tab files for 1 year from PANGAEA, and put them in the directory './input/STATION_NAME/'

# Output
Output will be .mat data in the directory './output/STATION_NAME/'

# Variables
These variables are selected and converted:
'time','G_h','G_dir','G_dif','G_etr','alpha_s_deg','alpha_s_rad','phi_s_deg','phi_s_rad'



