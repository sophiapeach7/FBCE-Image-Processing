%This script goes through all datum point folders and creates a table 
%displaying at what frame rate each datum point was recorded

ExpDir = uigetdir("C:\","Indicate directory of the experiment");

w = waitbar(0,"Please wait...");

DP_List = dir(ExpDir);

SortedListExists = false;
for i=1:length(DP_List)
    if contains(DP_List(i).name,string(linspace(1,50,50)))
        if SortedListExists
            SortedList = vertcat(SortedList,str2double(DP_List(i).name));
        else
            SortedList = [str2double(DP_List(i).name)];
            SortedListExists = true;
        end
    end
end

SortedList = sort(SortedList);
FrameRate = zeros(length(SortedList),1);
ImageCount = zeros(length(SortedList),1);

for i=1:length(SortedList)
    waitbar(i/length(SortedList));
    DP_Dir = ExpDir + "\" + string(SortedList(i));
    cd(DP_Dir);
    DataFile = dir('*.csv');
    FrameRate(i,1) = readmatrix(DataFile(1).name,"OutputType","double","Range",[2 7 2 7]);
    ImageCountArray = readmatrix(DataFile(1).name,"OutputType","string","FileType","text","Range",[2 7 20000 7]);
    ImageCount(i,1) = length(ImageCountArray);
end

close(w);
Data = horzcat(SortedList,FrameRate,ImageCount);

f = uifigure;
f.Position(2:4) = [50 400 600];
uitable(f,"Data",Data,"ColumnName",["Datum Point" "Frame Rate" "Number of Images"],"ColumnWidth",'fit','Position',[5 5 f.Position(3)-10 f.Position(4)-10]);