# FBCE Image Processing

!!!READ THE WHOLE DOCUMENT!!!

This project contains all the tools necessary to process images for NASA FBCE project. Images are processed using ImageJ software along with Matlab, if necessary. Data is then analyzed using Matlab code.

To execute: FBCE_Batch_Image_Processor_v3.0.1_.ijm is located under Plugins > Macros in the program tab.




### SOFTWARE REQUIREMENTS:

	MATLAB R2022a with Parallel Computing Toolbox installed
	FIJI (ImageJ2)




### SETUP:

MainMacro and ImageClean.m utilize temporary directories the path of which might need to be changed depending on where GitHub folder is located and where the user prefers to store temporary folders. To change directories in MainMacro go to Plugins > Macros > Edit... and open FBCE_Batch_Image_Processor_v3.0.1_.ijm. Alternatively, it can also be opened with Notepad application.

    Default directory in FBCE_Batch_Image_Processor_v3.0.1_.ijm: 
        Temp_Dir = "C:/Users/Sophia/Documents/GitHub/FBCE_ImageProcessing";
    This is the directory where temporary folders will be stored. Change it to any accessible direcrory. 
    Make sure to use / instead of \. Do not end path in /.

    Default directory in ImageClean.m:
        datadirectory = 'C:\Users\Sophia\Documents\GitHub\FBCE_ImageProcessing\_dir_intermediate_';
    This references one of the temporary folders. This directory has to match the chosen directory above. 
    Do not end path in \.


Java cannot run ImageClean.m directly, therefore, it needs to be invoked by another MATLAB script. Run_ImageClean_.m invokes program ImageClean.m located in the GitHub folder. Therefore, the directory to ImageClean.m has to be changed in Run_ImageClean_.m, if it does not correspond to the default path.

    Default directory in Run_ImageClean_.m:
        'C:\\Users\\Sophia\\Documents\\GitHub\\FBCE_ImageProcessing\\Child Applications\\ImageClean.m'
    Change it as needed. Make sure to use \\ instead of \.


Similarly, Run_VoidFractionCalculator_.m invokes VoidFractionCalculator_Invoked.m. Therefore, directory of VoidFractionCalculator_Invoked.m has to be routed in Run_VoidFractionCalculator_.m.

    Default directory in Run_VoidFractionCalculator_.m:
        'C:\\Users\\Sophia\\Documents\\GitHub\\FBCE_ImageProcessing\\Child Applications\\VoidFractionCalculator_Invoked.m'
    Change it as needed. Make sure to use \\ instead of \.


Next, directory of the intermediate folder for Void Fraction Analysis has to be indicated in the VoidFractionCalculator_Invoked.m script.
    Default directory in VoidFractionCalculator_.m:
        "C:/Users/Sophia/Documents/GitHub/FBCE_ImageProcessing"
    Change it to the same location as the default directory of FBCE_Batch_Image_Processor_v3.0.1_.ijm.
    
	

After making changes to the directories, move the following files in appropriate locations:

    FBCE_Batch_Image_Processor_v3.0.1_.ijm => C:\Program Files\fiji-win64\Fiji.app\plugins\Macros\
    All files in Scripts => C:\Program Files\fiji-win64\Fiji.app\plugins\Scripts\
    All files in SaveAsMovie_Resources => C:\Program Files\fiji-win64\Fiji.app\plugins\

SaveAsMovie_.jar plugins will need to be updated. To do that go to Menu>Help>Update..., and add the following URLs via "Manage update sites">"Add update site":

	https://sites.imagej.net/Template_Matching/
	https://sites.imagej.net/iterativePIV/
	https://sites.imagej.net/FFMPEG-javacv/
	https://sites.imagej.net/adaptiveThreshold/

Finally, in same window for "Manage update sites" add an update site called ImageJ-Matlab. Close the window, submit changes and restart ImageJ.



### WARNINGS:

It is recommended that the user does not utilize their processing machine for any other tasks while running this program as it demands up to 100% of CPU power. It is also recommended to use additional cooling mechanisms to avoid severe overheating.



