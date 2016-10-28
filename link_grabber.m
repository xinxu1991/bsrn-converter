clear all;
close all;
fileIN = fopen('links.txt','r');
fileOUT = fopen('download-links.txt','w');
tline = fgetl(fileIN);
count = 0;
while ischar(tline)
    if contains(tline,'https://doi.pangaea.de/10.1594/')
        fprintf(fileOUT,'%s',[tline '?format=textfile']);
        fprintf(fileOUT,'\n');
        count = count+1;
    end
    tline = fgetl(fileIN);
end
fclose(fileIN);
fclose(fileOUT);