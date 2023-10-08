Temp_Dir = "C:/Users/Sophia/Documents/GitHub/FBCE_ImageProcessing";
Dialog.create("BACKGROUND IMAGE OPTIONS");
Dialog.addFile("Select Background Image","D:/Unzipped Images/_____________________________________________________________________________________________");
Dialog.show();
BackgroundImageOpen = Dialog.getString();
BackgroundImage = File.getName(BackgroundImageOpen);
open(BackgroundImageOpen);
//Apply threshhold.
setAutoThreshold("Default");
setThreshold(0, 69, "raw");
run("Convert to Mask");
//Invert colors.
run("Invert");
run("Invert LUTs");
//Despeckle
run("Despeckle");
//Run Analyze Particles command.
run("Analyze Particles...", "size=5-Infinity pixel show=Masks include");
//Select background image window and close it.
selectWindow(BackgroundImage);
run("Close");
//Select the result of Analyze Particles function window.
selectWindow("Mask of "+BackgroundImage);
//Select the entire area of the image.
run("Select All");
//Create a table named "Results".
Table.create("Results");
//Create a profile of the image.
profile = getProfile();
//Transfer profile data to Results table.
for (i=0; i<profile.length; i++)
      setResult("Value", i, profile[i]);
//Update the table.
updateResults;
//Format table.
run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file save_column");
//Save the table as a .csv file.
saveAs("Results", Temp_Dir+"/Background_GrayValues.csv");
//Close all image windows.
close("*");
//Select the table and close it.
selectWindow("Results");
run("Close");
showMessage("Macro Completed!");