# ImageJ_FBCE_ImageProcessing

!!!READ THE WHOLE DOCUMENT!!!

This project contains all the tools necessary to process images for NASA FBCE project. Images are processed using ImageJ software along with Matlab if necessary. Data is then analyzed using Matlab code.

To setup all the tools several files need to be move in appropriate locations:
    RunMatlabClean_.m => C:\Program Files\fiji-win64\Fiji.app\plugins\Scripts\
    MainMacro_v..._.ijim => C:\Program Files\fiji-win64\Fiji.app\plugins\Macros\
    All files in SaveAsMovie_Resources => C:\Program Files\fiji-win64\Fiji.app\plugins\
  
Matlab RunMatlabClean_.m file is assigned to the Scrits folder so that ImageJ can recognize it when it is invoked from MainMacro_v..._.ijim. 
Assigning MainMacro_v..._.ijim to the Macros folder allows to quickly run it from ImageJ program. It will be located under Plugins > Macros in the program tab.

MainMacro references several directories which might need to be changed depending on where GitHub folder is located and where the user prefers to store temporary folders. To change these directories go to Plugins > Macros > Edit... and open MainMacro_v..._.ijim. These directories will be located at the top of the code. 

Default directories are: 
    SaveDir = "C:/Users/.../Desktop/test/test_save/";
    dir_intermediate = "C:/Users/.../Documents/GitHub/FBCE_ImageProcessing/_dir_intermediate_/";
    StackPlotDataMacro_dir = "C:/Users/.../Documents/GitHub/FBCE_ImageProcessing/StackPlotDataMacro.ijm";
    background_dir = "C:/Users/.../Documents/GitHub/FBCE_ImageProcessing/WORKING BACKGROUND/";
Change these as needed. Make sure to use / instead of \.

"_dir_intermediate_" and "WORKING BACKGROUND" folders are not present in GitHub directory but are created and deleted during execution if required. Their names still have to be present in their respective paths.

Java cannot run ImageClean.m directly, therefore, it needs to be invoked by another Matlab script. RunMatlabClean_.m invokes program ImageClean.m from the GitHub folder. Therefore, the directory to ImageClean.m has to be changed in RunMatlabClean_.m, if it does not correspond to the default path.


SaveAsMovie_.jar plugins will need to be updated. To do that go to Menu>Help>Update..., and add the following URLs via "Manage update sites">"Add update site":
	https://sites.imagej.net/Template_Matching/
	https://sites.imagej.net/iterativePIV/
	https://sites.imagej.net/FFMPEG-javacv/
	https://sites.imagej.net/adaptiveThreshold/
Restart ImageJ after.