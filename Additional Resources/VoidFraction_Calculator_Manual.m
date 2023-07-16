%% LOADING SETTINGS
clear;
clc;
close all force;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Temp_Dir = "C:/Users/Sophia/Documents/GitHub/FBCE_ImageProcessing";
%Settings = readmatrix(Temp_Dir+"/_intermediate_data_transfer_.csv","OutputType","string","Range",1);
%delete(Temp_Dir+"/_intermediate_data_transfer_.csv");
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

bck_gv = bck_gv*164/255;

for i = 2+n1p:nfiles+1+n1p
    [empty,name] = fileparts(files(i-1-n1p).name);
    xname = append('X',name);
    DP = eval(xname);
    n = eval(name);
    navrg = vecavrg(DP,bck_gv);
    avrgmatrix(:,n+1) = navrg;
end

%% SAVING RESULTS
writematrix(avrgmatrix,savedirectory+save_csv_fileNAME+".csv");

%% PLOTTING DATA
columns = size(avrgmatrix,2);
VFplot = figure("Name","Void Fraction Plots","Units","normalized","Position",[0.05 0.05 0.9 0.8]);
VFplot.WindowState = "maximized";
for p=1+plot_starting_DP:columns
    plot(avrgmatrix(:,1),avrgmatrix(:,p))
    text(1+0.005,avrgmatrix(end,p),string(p-1),'Color','red','FontSize',10)
    hold on
end
title(plottitle)
xlabel("Length of the Channel, x/L")
ylabel("Void Fraction")
ylim([0 1]);
xlim([0 1]);
savefig(VFplot,savedirectory+save_plot_fileNAME+".fig");
saveas(VFplot,savedirectory+save_plot_fileNAME+".png");

%% FUNCTIONS
function avrg = vecavrg(n,bck_gv)
nrows = size(n,1);
avrg = zeros(nrows,1);

for k=1:nrows
    row = n(k,2:end);
    avrg(k) = mean(row);
end

avrg = avrg*164/255;
avrg = avrg./bck_gv;

end


function result = datainput
f = figure("Name","EXPERIMENT INFORMATION");
f.Position(3:4) = [500 300];
W = f.Position(3);
H = f.Position(4);
uicontrol(f,"Style","text","String","Please input experiment information","Position",[20 H-30 W-5 20],"HorizontalAlignment","left","FontSize",10)
uicontrol(f,"Style","text","String","Number of single-phase datum points at the beginning:","Position",[20 H-70 W-5 20],"HorizontalAlignment","left","FontSize",10)
SinglePhaseDP = uicontrol(f,"Style","edit","Position",[350,H-70,50,20],"HorizontalAlignment","left","FontSize",10);
end
