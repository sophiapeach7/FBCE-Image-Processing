# ImageJ_FBCE_ImageProcessing

!!!READ THE WHOLE DOCUMENT!!!

This project contains all the tools necessary to process images for NASA FBCE project. Images are processed using ImageJ software along with Matlab, if necessary. Data is then analyzed using Matlab code.

To execute: MainMacro is located under Plugins > Macros in the program tab.




SOFTWARE REQUIREMENTS:

	MATLAB R2022a with Parallel Computing Toolbox installed
	FIJI (ImageJ2)




SETUP:

To setup all the tools several files need to be moved in appropriate locations:
    MainMacro_v..._.ijim => C:\Program Files\fiji-win64\Fiji.app\plugins\Macros\
    All files in Scripts => C:\Program Files\fiji-win64\Fiji.app\plugins\Scripts\
    All files in SaveAsMovie_Resources => C:\Program Files\fiji-win64\Fiji.app\plugins\


MainMacro and ImageClean.m utilize temporary directories the path of which might need to be changed depending on where GitHub folder is located and where the user prefers to store temporary folders. To change directories in MainMacro go to Plugins > Macros > Edit... and open MainMacro_v..._.ijim.

    Default directory in MainMacro: 
        GitHub_Dir = "C:/Users/Sophia/Documents/GitHub/FBCE_ImageProcessing";
    Change it as needed. Make sure to use / instead of \. Do not end path in / or \.

    Default directory in ImageClean:
        datadirectory = 'C:\Users\Sophia\Documents\GitHub\FBCE_ImageProcessing\_dir_intermediate_';
    Change it as needed. Do not end path in \.


Java cannot run ImageClean.m directly, therefore, it needs to be invoked by another MATLAB script. RunMatlabClean_.m invokes program ImageClean.m located in the GitHub folder. Therefore, the directory to ImageClean.m has to be changed in RunMatlabClean_.m, if it does not correspond to the default path.

    Default directory in RunMatlabClean_.m:
        'C:\\Users\\Sophia\\Documents\\GitHub\\FBCE_ImageProcessing\\ImageClean.m'
    Change it as needed. Make sure to use \\ instead of \.


SaveAsMovie_.jar plugins will need to be updated. To do that go to Menu>Help>Update..., and add the following URLs via "Manage update sites">"Add update site":
	https://sites.imagej.net/Template_Matching/
	https://sites.imagej.net/iterativePIV/
	https://sites.imagej.net/FFMPEG-javacv/
	https://sites.imagej.net/adaptiveThreshold/

Restart ImageJ after any change is applied.




WARNINGS:

It is recommended that the user does not utilize processing machine for any other tasks while running this program as it demands up to 100% of CPU power. It is also recommended to use additional cooling mechanisms to avoid severe overheating. 