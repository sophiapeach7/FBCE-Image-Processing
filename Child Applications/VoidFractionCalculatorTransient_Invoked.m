%% LOADING SETTINGS
clear;
clc;
close all force;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Temp_Dir = "C:/Users/Sophia/Documents/GitHub/FBCE_ImageProcessing";
% Settings = readmatrix(Temp_Dir+"/_intermediate_data_transfer_.csv","OutputType","string","Range",1);
% delete(Temp_Dir+"/_intermediate_data_transfer_.csv");
bck_gv_raw = readmatrix(Temp_Dir+"/Background_GrayValues.csv");
% delete(Temp_Dir+"/Background_GrayValues.csv");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n1p = 4; %TEMPORARY
%n1p = str2double(Settings(2,1)); %number of single phase datum points at the BEGINNING
plot_starting_DP = n1p+1; %NOT same as avrgmatrix indexation, refer to test matrices for correct DP value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
datadirectory = uigetdir("Select data directory"); %TEMPORARY
Ntot = 12750; %TEMPORARY BUT IMPROVE
fps = 2000; %TEMPORARY BUT IMPROVE
% datadirectory = Settings(2,2); %Full directory of ImageJ Profile Plot data
% savedirectory = Settings(2,3); %Full directory where to save output matrix
% save_csv_fileNAME = Settings(2,4); %Output matrix name
% save_plot_fileNAME = Settings(2,5); %Outpot plot files name
% plottitle = Settings(2,6); %Experiment name
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

%% PREPROCESSING

%Multiply by image pixel height to obtain total grey value and divide by
%black color grey value to obtain number of black pixels
bck_gv = bck_gv_raw(:,2)*164/255;

%% PROCESSING DATA - TOTAL VOID FRACTION

bck_gv_tot = sum(bck_gv);

%Creates time array 
TimeArr = linspace(0,Ntot/fps,Ntot);

%Initiates datum point number array
DParr = zeros(1,nfiles);
%Fill datum point array with processed datum point numbers
for i = 1:nfiles
    [empty,name] = fileparts(files(i).name);
    DParr(1,i) = eval(name);
end
%Sort the datum points in the ascending order
DParr = sort(DParr,"ascend");
%Initiate Total Void Fraction array
TotVF = nan(DParr(end)+1,Ntot);
TotVF(1,:) = TimeArr;

for i = 1:nfiles
    [empty,name] = fileparts(files(i).name);
    xname = append('X',name);
    DP = eval(xname);
    DP = DP(:,2:end)*164/255;
    n = eval(name);
    TotVF(n+1,:) = sum(DP,1)/bck_gv_tot;
end


%% PLOTTING - TOTAL VOID FRACTION

VFplot = figure("Name","Void Fraction Plots","Units","normalized","Position",[0.05 0.05 0.9 0.8]);
VFplot.WindowState = "maximized";
for p=1:DParr(end)
    if ~isnan(TotVF(p+1,1))
        plot(TotVF(1,:),TotVF(p+1,:))
        text(TimeArr(end)+0.005,TotVF(p+1,end),string(p),'Color','red','FontSize',10)
        hold on
    end
end
% title(plottitle)
xlabel("Time, s")
ylabel("Total Channel Void Fraction")
ylim([0 1]);
xlim([0 TimeArr(end)]);
%savefig(VFplot,savedirectory+save_plot_fileNAME+".fig");
%saveas(VFplot,savedirectory+save_plot_fileNAME+".png");

stepinfo(TotVF(7,:),TimeArr,"SettlingTimeThreshold",0.155)
new = rmoutliers(TotVF(7,:),"movmean",0.1);







