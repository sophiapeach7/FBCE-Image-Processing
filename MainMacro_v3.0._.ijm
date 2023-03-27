SaveDir = "C:/Users/Sophia/Desktop/test/test_save/";
dir_intermediate = "C:/Users/Sophia/Documents/GitHub/FBCE_ImageProcessing/_dir_intermediate_/";
StackPlotDataMacro_dir = "C:/Users/Sophia/Documents/GitHub/FBCE_ImageProcessing/StackPlotDataMacro.ijm";
background_dir = "C:/Users/Sophia/Documents/GitHub/FBCE_ImageProcessing/WORKING BACKGROUND/";
CleanRest = false;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
FolderDir = getDirectory("Indicate directory of an experiment");
AllFolders = getFileList(FolderDir);
Dialog.create("SINGLE-PHASE DATUM POINTS")
Dialog.addMessage("Input how many Datum Points at the BEGINNING include only single-phase images.\n \nThese folders will be ignored and one of the images will be used as background.\n \nEnter 0 for none.");
Dialog.addNumber("Number of single-phase DP",0);
Dialog.show();
SinglePhaseDP = Dialog.getNumber();
if (SinglePhaseDP > 0) {
	BackgroundImageArray = getFileList(FolderDir + AllFolders[0]);
	BackgroundImage = BackgroundImageArray[0];
	BackgroundImageOpen = FolderDir + AllFolders[0] + BackgroundImage;
}
else {
	File.makeDirectory(background_dir);
	waitForUser("'WORKING BACKGOUND' folder created in GitHub directory.\n \nImport a single single-phase flow image into the folder from the\nSAME day as the given experiment was recorded.\n \nOnly then click OK to proceed.");
	BackgroundImageArray = getFileList(background_dir);
	BackgroundImage = BackgroundImageArray[0];
	BackgroundImageOpen = background_dir+BackgroundImage;
}

for (i=SinglePhaseDP; i<AllFolders.length; i++) {
	setBatchMode(true);
	Folder = FolderDir + AllFolders[i];
	File.openSequence(Folder);
	NameArray = getList("image.titles");
	ImportedSequenceName = NameArray[0];
	open(BackgroundImageOpen);
	showStatus("Subtracting background...");
	imageCalculator("Subtract create 32-bit stack",ImportedSequenceName,BackgroundImage);
	selectWindow("Result of "+ImportedSequenceName);
	showStatus("Setting threshold...");
	setAutoThreshold("Default");
	setThreshold(-1000000000000000000000000000000.0000, -16.0000);
	run("NaN Background", "stack");
	showStatus("Analyzing particles...");
	run("Analyze Particles...", "size=5-Infinity show=Masks include stack");
	setBatchMode(false);
	rename(ImportedSequenceName);
	if (CleanRest) {
		clean = true;
	}
	else {
		beep();
		waitForUser("See whether stack needs cleaning \n \nClick OK to proceed");
		Dialog.create("DECISION REQUIRED");
		Dialog.addMessage("Does stack need cleaning?\n \nCheck 'Clean Rest' to clean the rest of folders as well.\nIf checked, you will not be prompted this again.");
		Dialog.addCheckbox("Check to clean", true);
		Dialog.addCheckbox("Clean rest",false);
		Dialog.show();
		clean = Dialog.getCheckbox();
		CleanRest = Dialog.getCheckbox();
	}
	if (clean) {
		File.makeDirectory(dir_intermediate);
	    selectWindow(ImportedSequenceName);
	    run("Image Sequence... ", "dir="+dir_intermediate+" format=Text name=[] start=1 digits=4 use");
	    close();
	    showStatus("Running cleanup code...");
	    run("RunMatlabClean ");
	    list = getFileList(dir_intermediate);
	    setBatchMode(true);
	    for (n=0; n<list.length; n++) {
		    file = dir_intermediate + list[n];
		    run("Text Image... ", "open=&file");
	    }
	    showStatus("Converting images to stack...");
	    run("Images to Stack", "use");
	    setBatchMode(false);
	    setBatchMode("hide");
	    rename(ImportedSequenceName);
	    run("Invert LUT");
	    run("Select All");
	    run("Select All");
	    runMacro(StackPlotDataMacro_dir);
	    run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file");
	    showStatus("Deleting .txt files...");
	    for (n=0; n<list.length; n++) {
	    	File.delete(dir_intermediate+list[n]);
	    	showProgress(n,list.length);
	    }
	    showProgress(1,0);
	    File.delete(dir_intermediate);
	    selectWindow("Log");
	    run("Close");
	    selectWindow(ImportedSequenceName);
	    run("Close");
	}
	else {
	    selectWindow(ImportedSequenceName);
	    setBatchMode("hide");
	    run("Select All");
	    runMacro(StackPlotDataMacro_dir);
	    run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file");
	    selectWindow(ImportedSequenceName);
	    run("Close");
	}
	saveAs("Results", SaveDir+ImportedSequenceName+".csv");
	selectWindow("Results");
	run("Close");
}

if (File.exists(background_dir)) {
	File.delete(BackgroundImageOpen);
	File.delete(background_dir);
	selectWindow("Log");
	run("Close");
	}
beep();
waitForUser("Macro Completed!\n \nCompleted folder directory:\n"+FolderDir+"\n \nResulting stacks which were saved are displayed for review.\n \nClick OK to clear all.");
close("*");