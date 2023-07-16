%% LOADING SETTINGS
clear;
clc;
close all force;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Temp_Dir = "C:/Users/Sophia/Documents/GitHub/FBCE_ImageProcessing";
Settings = readmatrix(Temp_Dir+"/_intermediate_data_transfer_.csv","OutputType","string","Range",1);
delete(Temp_Dir+"/_intermediate_data_transfer_.csv");
bck_gv = readmatrix(Temp_Dir+"/Background_GrayValues.csv");
delete(Temp_Dir+"/Background_GrayValues.csv");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n1p = str2double(Settings(2,1)); %number of single phase datum points at the BEGINNING
plot_starting_DP = n1p+1; %NOT same as avrgmatrix indexation, refer to test matrices for correct DP value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
datadirectory = Settings(2,2); %Full directory of ImageJ Profile Plot data
savedirectory = Settings(2,3); %Full directory where to save output matrix
save_csv_fileNAME = Settings(2,4); %Output matrix name
save_plot_fileNAME = Settings(2,5); %Outpot plot files name
plottitle = Settings(2,6); %Experiment name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% LOADING DATA
cd(datadirectory)
files = dir('*.csv');
wbar = waitbar(0,"Loading data...");
for i = 1:length(files)
    load(files(i).name, '-ascii');
    waitbar(i/length(files),wbar);
end
close(wbar);
nfiles = i;

avrgmatrix = zeros(2040,nfiles+1+n1p);
step = linspace(0,1,2040);
step = transpose(step);
avrgmatrix(:,1) = step;

%% CREATING ZEROS ARRAY FOR SINGLE-PHASE DATUM POINTS
if n1p > 0
    array0 = zeros(2040,1);
    for p = 2:n1p+2
        avrgmatrix(:,p) = array0;
    end
end

%% PROCESSING DATA


















