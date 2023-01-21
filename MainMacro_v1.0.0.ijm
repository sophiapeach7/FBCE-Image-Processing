SaveDir = "C:/Users/Sophia/Desktop/test/test_save/";
dir_intermediate = "C:/Users/Sophia/Documents/GitHub/FBCE_ImageProcessing/_dir_intermediate_/";
StackPlotDataMacro_dir = "C:/Users/Sophia/Documents/GitHub/FBCE_ImageProcessing/StackPlotDataMacro.ijm";
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
File.makeDirectory(dir_intermediate);
run("Image Sequence...");
NameArray = getList("image.titles");
ImportedName = NameArray[0];
bck = getFileList("C:/Users/Sophia/Desktop/FBCE/Images/WORKING BACKGROUND/");
open("C:/Users/Sophia/Desktop/FBCE/Images/WORKING BACKGROUND/"+bck[0]);
imageCalculator("Subtract create 32-bit stack",ImportedName,bck[0]);
selectWindow("Result of "+ImportedName);
setAutoThreshold("Default");
setThreshold(-1000000000000000000000000000000.0000, -16.0000);
run("NaN Background", "stack");
run("Analyze Particles...", "size=5-Infinity show=Masks include stack");
selectWindow(bck[0]);
close();
selectWindow("Result of "+ImportedName);
close();
selectWindow("Mask of Result of "+ImportedName);
run("Image Sequence... ", "dir="+dir_intermediate+" format=Text name=[] start=1 digits=4 use");
beep();
waitForUser("Run MATLAB Cleanup Code");
list = getFileList(dir_intermediate);
setBatchMode(true);
for (i=0; i<list.length; i++) {
	file = dir_intermediate + list[i];
	run("Text Image... ", "open=&file");
}
run("Images to Stack", "use");
setBatchMode(false);
run("Invert LUT");
run("Select All");
runMacro(StackPlotDataMacro_dir);
run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file");
saveAs("Results", SaveDir+ImportedName+".csv");
for (i=0; i<list.length; i++) {
	File.delete(dir_intermediate+list[i]);
}
File.delete(dir_intermediate);
selectWindow("Log");
run("Close");
beep();
waitForUser("Macro Completed. Datum Point: "+ImportedName);
selectWindow("Results");
run("Close");
close("*");