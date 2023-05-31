%FOLDER CHECK
%
%This code checks the info (.mdipsucl) file of each datum point and
%converts it to a .csv file so that the user can open it.
%
%This code also parses through the folders and warns user if any of them
%are empty.


%Clears command window and workspace, closes all windows.
clc;
clear;
close all force;

%Prompts user to select "Unzipped Images" folder.
unzip_dir = uigetdir('C:\',"Select 'Unzipped images' directory");

%Creates a structure of all the folders within the selected directory.
date_folders = dir(unzip_dir);

%This loop goes through all the folders in the selected directory.
parfor i=1:length(date_folders)

    % "If the subfolder name contains either '2022' or '2023'":
    %This is done because dir command sometimes produces empty folders that
    %are not there.
    if contains(date_folders(i).name,["2022","2023"])

        %Creates a full directory for a subfolder. A subfolder corresponds
        %to a whole day of experiments.
        date_folder_full_dir = [date_folders(i).folder '\' date_folders(i).name];

        %Creates a structure of all the folders within the subfolder. Each
        %subsubfolder corresponds to a specific experiment that was ran
        %that day.
        exp_folders = dir(date_folder_full_dir);

        %This loop goes through all the experiment subsubfolders within the
        %subfolder.
        for k=1:length(exp_folders)

            % "If subsubfolder contains either '2022' or '2023'":
            % For the same reasons.
            if contains(exp_folders(k).name,["2022","2023"])

                %Full directory for experiment subsubfolder.
                exp_folder_full_dir = [date_folder_full_dir '\' exp_folders(k).name '\CL_Camera_1'];

                %Creates a list of folders within the experiment folder.
                %Each subsubsubfolder corresponds to a datup point within
                %that folder.
                dp_folders = dir(exp_folder_full_dir);

                %This loop goes through all datup point subsubsubfolders
                %within the experiment folder.
                for m=1:length(dp_folders)

                    % "If the name of the datum point contains any integer
                    % from 1 to 100":
                    %For the same reasons. 
                    if contains(dp_folders(m).name,string(linspace(1,100,100)))

                        %Full directory to the datup point folder
                        dp_folder_full_dir = [exp_folder_full_dir '\' dp_folders(m).name];

                        %Makes datum point folder the main MATLAB
                        %directory.
                        cd(dp_folder_full_dir);

                        %Creates a structure of folders within the datum
                        %point folder that contain ".mdipsucl" extension.
                        info_mdipsucl = dir('*.mdipsucl');

                        % "If there IS a file with ".mdipsucl" extension
                        % found":
                        if ~isempty(info_mdipsucl)

                            %Extracts the name of the file.
                            [~,name,~] = fileparts(info_mdipsucl(1).name);

                            %Renames the file to change extension to ".csv"
                            movefile([name '.mdipsucl'], [name '.csv'])

                        % "If there IS NO file with ".mdipsucl" extension":
                        elseif isempty(dir('*.csv'))

                            % "If there are no images in the folder:"
                            if isempty(dir('*.tiff'))

                                %Displays a warning that the folder is empty.
                                fprintf("\n");
                                disp("!!! WARNING: Folder '"+string(dp_folder_full_dir)+"' IS EMPTY !!!");
                                fprintf("\n");
                            else
                            %Creates a note to tell user that info file is
                            %missing. This is not critical as .mdipsucl
                            %file is not necessary.
                            disp("Note: Folder '"+string(dp_folder_full_dir)+"' does not have an info file");
                            end
                        end
                    end
                end
            end
        end
    end
end
