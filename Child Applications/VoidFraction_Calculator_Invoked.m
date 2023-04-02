%% LOADING SETTINGS
Temp_Dir = "C:/Users/Sophia/Documents/GitHub/FBCE_ImageProcessing";
Settings = readmatrix(Temp_Dir+"/_intermediate_data_transfer_.csv","OutputType","string");
delete(Temp_Dir+"/_intermediate_data_transfer_.csv");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n1p = str2double(Settings(2,2)); %number of single phase datum points at the BEGINNING
plot_starting_DP = n1p+1; %NOT same as avrgmatrix indexation, refer to test matrices for correct DP value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
datadirectory = Settings(2,3); %Full directory of ImageJ Profile Plot data
savedirectory = Settings(2,4); %Full directory where to save output matrix
savefileNAME = Settings(2,5); %Output matrix name
plottitle = Settings(2,6); %Experiment name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% LOADING DATA
cd(datadirectory)
files = dir('*.csv');
for i = 1:length(files)
    load(files(i).name, '-ascii');
end
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
for i = 2+n1p:nfiles+1+n1p
    [empty,name] = fileparts(files(i-1-n1p).name);
    xname = append('X',name);
    DP = eval(xname);
    n = eval(name);
    navrg = vecavrg(DP);
    avrgmatrix(:,n+1) = navrg;
end

%% SAVING RESULTS
writematrix(avrgmatrix,savedirectory+savefileNAME+".csv");

%% PLOTTING DATA
columns = size(avrgmatrix,2);
VFplot = figure("Name","Void Fraction Plots","Units","normalized","Position",[0 0 1 1]);
for p=1+plot_starting_DP:columns
    plot(avrgmatrix(:,1),avrgmatrix(:,p))
    text(1+0.005,avrgmatrix(end,p),string(p-1),'Color','red','FontSize',10)
    hold on
end
title(plottitle)
xlabel("Length of the Channel, x/L")
ylabel("Void Fraction")
ylim([0 1]);
xlim([0 2040]);
savefig(VFplot,savedirectory+savefileNAME+".fig");
saveas(VFplot,savedirectory+savefileNAME+".png");


%% FUNCTIONS
function avrg = vecavrg(n)
nrows = size(n,1);
avrg = zeros(nrows,1);

for k=1:nrows
    row = n(k,2:end);
    avrg(k) = mean(row);
end

avrg = avrg*164/255/103;

end