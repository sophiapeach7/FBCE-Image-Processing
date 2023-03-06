# ImageJ_FBCE_ImageProcessing

This project contains all the tools necessary to process images for NASA FBCE project. Images are processed using ImageJ software along with Matlab if necessary. Data is then analyzed using Matlab code.

To setup all the tools several files need to be move in appropriate locations:
    IJMRunMAT_.m => C:\Program Files\fiji-win64\Fiji.app\plugins\Scripts\
    MainMacro_v..._.ijim => C:\Program Files\fiji-win64\Fiji.app\plugins\Macros\
  
Matlab IJMRunMAT_.m file is assigned to the Scrits folder so that ImageJ can recognize it when it is invoked from MainMacro_v..._.ijim. 
Assigning MainMacro_v..._.ijim to the Macros folder allows to quickly run it from ImageJ program. It will be located under Plugins > Macros in the program tab.

MainMacro references several directories which might need to be changed depending on where GitHub folder is located and where the user prefers to store temporary folders. To change these directories go to Plugins > Macros > Edit... and open MainMacro_v..._.ijim. These directories will be located at the top of the code. 

Default directories are: 
    SaveDir = "C:/Users/.../Desktop/test/test_save/";
    dir_intermediate = "C:/Users/.../Documents/GitHub/FBCE_ImageProcessing/_dir_intermediate_/";
    StackPlotDataMacro_dir = "C:/Users/.../Documents/GitHub/FBCE_ImageProcessing/StackPlotDataMacro.ijm";
    background_dir = "C:/Users/.../Documents/GitHub/FBCE_ImageProcessing/WORKING BACKGROUND/";
Change these as needed. Make sure to use / instead of \.
