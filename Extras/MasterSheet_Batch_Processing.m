clear;
clc;
%%%%%%%%%%%%%%%%%%%EMPTY MASTER SHEET DIRECTORY%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MS_File = "C:\Users\Sophia\Documents\GitHub\FBCE_ImageProcessing\Extras\MasterSheet_Empty.xlsx";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Data_Dir = uigetdir("C:\","Indicate unprocessed data directory");
Save_Dir = uigetdir("C:\","Indicate save directory");

[MS_Dir,MS_Name,~] = fileparts(MS_File);
cd(Data_Dir);
csv_list = dir('*.xlsx');
csv_length = length(csv_list);

for i = 1:csv_length
    fprintf(csv_list(i).name+"\n\n");
end
fprintf("Found "+csv_length+" .xlsx files\n\n");

for i = 1:csv_length
    cd(MS_Dir);
    copyfile(MS_Name+".xlsx",Save_Dir);
    cd(Save_Dir);
    movefile(MS_Name+".xlsx",csv_list(i).name);
end

D = parallel.pool.DataQueue;
h = waitbar(0, 'Please wait ...');
afterEach(D, @nUpdateWaitbar);
N = 1;

parfor i = 1:csv_length
    Data_Transfer = readtable(Data_Dir+"\"+csv_list(i).name,"FileType","spreadsheet","Sheet",2,"Range",'A5');
    writetable(Data_Transfer,Save_Dir+"\"+csv_list(i).name,"FileType","spreadsheet","Sheet","EU Data","Range",'A5','WriteMode','inplace','PreserveFormat',true,'WriteVariableNames',false);
    send(D, [i csv_length]);
end

close(h);

function nUpdateWaitbar(input)
N = evalin("base","N");
h = findall(0, 'type', 'figure', 'Tag', 'TMWWaitbar');
p = N/input(2);

waitbar(p, h);
assignin("base","N",N+1);

end
