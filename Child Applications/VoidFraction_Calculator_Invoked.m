%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loaddata = "NO";
createavrgmatrix = "NO";
savematrix = "NO";
plotdata = "NO";
n1p = 0; %number of single phase datum points at the BEGINNING
plot_starting_DP = 1; %NOT same as avrgmatrix indexation, refer to test matrices for correct DP value
save_starting_DP = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
datadirectory = 'Full directory of ImageJ Profile Plot data';
savedirectory = 'Full directory where to save output matrix';
savefileNAME = 'Output matrix name';
plottitle = 'Experiment name';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if loaddata == "YES"
    cd(datadirectory)
    files = dir('*.csv');
    for i = 1:length(files)
        load(files(i).name, '-ascii');
    end
    nfiles = i;
end

if createavrgmatrix == "YES"
    if exist('nfiles') == 0
        error("Data Files are NOT imported. Use loaddata option.")
    end

    avrgmatrix = zeros(2040,nfiles+1+n1p);
    step = linspace(0,1,2040);
    step = transpose(step);
    avrgmatrix(:,1) = step;

    if n1p > 0
        array0 = zeros(2040,1);
        for p = 2:n1p+2
            avrgmatrix(:,p) = array0;
        end
    end

    for i = 2+n1p:nfiles+1+n1p
        [empty,name] = fileparts(files(i-1-n1p).name);
        xname = append('X',name);
        DP = eval(xname);
        n = eval(name);
        navrg = vecavrg(DP);
        avrgmatrix(:,n+1) = navrg;
    end

end 

if savematrix == "YES"
    if exist('avrgmatrix') == 0
        error("Output matrix does not exist.")
    end
    cd(savedirectory)
    saveavrgmatrix = [avrgmatrix(:,1) avrgmatrix(:,save_starting_DP:end)];
    writematrix(saveavrgmatrix,savefileNAME)
end

if plotdata == "YES"
    if exist('avrgmatrix') == 0
        error("Output matrix does not exist.")
    end
    columns = size(avrgmatrix,2);
    for p=1+plot_starting_DP:columns
        plot(avrgmatrix(:,1),avrgmatrix(:,p))
        text(1+0.005,avrgmatrix(end,p),string(p-1),'Color','red','FontSize',10)
        hold on
    end
    title("Void Fraction Plots for Each Datum Point ("+plottitle+")")
    xlabel("Length of the Channel, x/L")
    ylabel("Void Fraction")
end

function avrg = vecavrg(n)
nrows = size(n,1);
avrg = zeros(nrows,1);

for k=1:nrows
    row = n(k,2:end);
    avrg(k) = mean(row);
end

avrg = avrg*164/255/103;

end