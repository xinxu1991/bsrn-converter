% bsrn-converter: convert BSRN raw data to MATLAB arrays
%
% Description:
%
%%% -----  Programmcode ----- %%%
%% purge cache
clear all;
pause on;

%% station
load('station_list.mat');
station_num = 10;
station_name = char(station_list{station_num,'Eventlabel'});
start_year = 2006;
end_year = 2015;

%% make dir
if exist(['./output/' station_name])~=7
    mkdir(['./output/' station_name]);
end

%% check integrity of files
fileOUT = fopen(['./input/' station_name '/missing_files.txt'],'w');
count = 0;
for year = start_year:1:end_year
    for i = 1:1:12
        infile = ['./input/' station_name '/' station_name '_radiation_' num2str(year) '-' num2str(i,'%02d') '.tab'];
        if exist(infile)==0
            fprintf(fileOUT,'%s',[station_name '_radiation_' num2str(year) '-' num2str(i,'%02d') '.tab']);
            fprintf(fileOUT,'\n');
            count = count+1;
        end
    end
end
fclose(fileOUT);
if count>0
    disp([num2str(count) ' files are missing, supplement them!']);
    return;
else
    disp(['Good! No file is missing between the year ' num2str(start_year) '-' num2str(end_year) ', proceeding program...']);
end 

%% convert data
for year = start_year:1:end_year
    % clear
    clearvars -except station_num station_name year station_list start_year end_year;
    % preallocation
    time = [];
    G_h = [];
    G_dir = [];
    G_dif = [];
    
    % load station name/locations
    location.longitude = station_list{station_num,'Longitude'};
    location.latitude = station_list{station_num,'Latitude'};
    location.altitude = station_list{station_num,'Elevation'};    
    
    % get start and end lines
    for i=1:1:12
        infile = ['./input/' station_name '/' station_name '_radiation_' num2str(year) '-' num2str(i,'%02d') '.tab'];
        fileIN = fopen(infile,'r');
        tline = fgetl(fileIN);
        nline = 2;
        while contains('*/',tline)==false
            tline = fgetl(fileIN);
            nline = nline+1;
        end
        startline(i) = nline+1;
        while ischar(tline)
            tline = fgetl(fileIN);
            nline = nline+1;
        end
        endline(i) = nline-2;
        fclose(fileIN);
    end
    
    % load time, GHI, DNI and DHI
    for i=1:1:12
        infile = ['./input/' station_name '/' station_name '_radiation_' num2str(year) '-' num2str(i,'%02d') '.tab'];
        [temp{1},temp{2},temp{3},temp{4}] = importfile(infile, startline(i), endline(i));
        time = vertcat(time,temp{1});
        G_h = vertcat(G_h,temp{2});
        G_dir = vertcat(G_dir,temp{3});
        G_dif = vertcat(G_dif,temp{4});
    end
    
    % calculate solar angles
    parfor i=1:1:length(time)
        temp = sun_position(time(i),location);
        alpha_s_deg(i) = 90-temp.zenith;
        alpha_s_rad(i) = (90-temp.zenith)*pi/180;
        phi_s_deg(i) = temp.azimuth;
        phi_s_rad(i) = temp.azimuth*pi/180;
    end
    alpha_s_deg = transpose(alpha_s_deg);
    alpha_s_rad = transpose(alpha_s_rad);
    phi_s_deg = transpose(phi_s_deg);
    phi_s_rad = transpose(phi_s_rad);
    
    % calculate EHR
    G_etr = 1367*(1+0.0334*cos(2*pi*day(time,'dayofyear')/365.25));
    
    % export
    outfile = ['./output/' station_name '/' station_name '_' num2str(year) '.mat'];
    save(outfile,'time','G_h','G_dir','G_dif','G_etr','alpha_s_deg','alpha_s_rad','phi_s_deg','phi_s_rad');
end