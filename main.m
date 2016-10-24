% bsrn-converter: convert BSRN raw data to MATLAB arrays
%
% Description:
%
%%% -----  Programmcode ----- %%%
%% purge cache
clear all;

%% weather data
load('station_list.mat');
year = 2015;
station_num = 10;
station_name = char(station_list{station_num,'Eventlabel'});

%% preallocation
time = [];
G_h = [];
G_dir = [];
G_dif = [];

%% load station name/locations
location.longitude = station_list{station_num,'Longitude'};
location.latitude = station_list{station_num,'Latitude'};
location.altitude = station_list{station_num,'Elevation'};

%% load time, GHI, DNI and DHI
for i=1:1:12
    infile = ['./input/' station_name '/' station_name '_radiation_' num2str(year) '-' num2str(i,'%02d') '.tab'];
    [temp{1},temp{2},temp{3},temp{4}] = importfile(infile, 41, eomday(year,i)*1440);
    time = vertcat(time,temp{1});
    G_h = vertcat(G_h,temp{2});
    G_dir = vertcat(G_dir,temp{3});
    G_dif = vertcat(G_dif,temp{4});
end

%% calculate solar angles
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

%% calculate EHR
G_etr = 1367*(1+0.0334*cos(2*pi*day(time,'dayofyear')/365.25));

%% export
mkdir(['./output/' station_name]);
outfile = ['./output/' station_name '/' station_name '_' num2str(year) '.mat'];
save(outfile,'time','G_h','G_dir','G_dif','G_etr','alpha_s_deg','alpha_s_rad','phi_s_deg','phi_s_rad');