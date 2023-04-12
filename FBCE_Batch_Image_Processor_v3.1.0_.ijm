Temp_Dir = "C:/Users/Sophia/Documents/GitHub/FBCE_ImageProcessing";
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CleanRest = false;
dir_intermediate = Temp_Dir+"/_dir_intermediate_/";
background_dir = Temp_Dir+"/WORKING BACKGROUND/";
print("MACRO STARTED\n_______________________________________________________ \n\n");
folderdir = getDirectory("Indicate directory with datum point folders containing raw images");
FolderDir = File.getDirectory(folderdir+"mockfile");
savedir = getDirectory("Indicate processed experiment directory");
SaveDir = File.getDirectory(savedir+"Data/mockfile");
DataDir = SaveDir+"ImageJ Data/";
VideoDir = SaveDir+"Videos/";
File.makeDirectory(SaveDir);
File.makeDirectory(DataDir);
File.makeDirectory(VideoDir);
VFASaveDir = File.getDirectory(SaveDir);
File.makeDirectory(VFASaveDir+"Analysis/");
File.makeDirectory(VFASaveDir+"Analysis/Void Fraction Analysis/");
VFASaveDir = VFASaveDir+"Analysis/Void Fraction Analysis/";
Dialog.create("EXPERIMENT INFORMATION");
Dialog.addMessage("Input experiment information");
Dialog.addString("Experiment number","0.0.0");
Dialog.addString("Experiment name","...");
Dialog.show();
ExpNum = Dialog.getString();
ExpName = Dialog.getString();
AllFolders = getFileList(FolderDir);
Dialog.create("SINGLE-PHASE DATUM POINTS");
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
	print("OPENING FOLDER: "+Folder+"\nDATUM POINT: "+(i+1)+"\n\n");
	File.openSequence(Folder);
	print("    ...Importing image sequence...\n\n");
	NameArray = getList("image.titles");
	ImportedSequenceName = NameArray[0];
	File.makeDirectory(VideoDir+ImportedSequenceName+"/");
	print("    ...Creating raw movie...\n\n");
	showStatus("Creating movie");
	showProgress(1,0);
	run("Movie...", "frame=30 container=.mov using=H.264 video=excellent save=["+VideoDir+ImportedSequenceName+"/"+ImportedSequenceName+"_raw"+".mov]");
	open(BackgroundImageOpen);
	print("    ...Subtracting background...\n\n");
	showStatus("Subtracting background...");
	imageCalculator("Subtract create 32-bit stack",ImportedSequenceName,BackgroundImage);
	selectWindow("Result of "+ImportedSequenceName);
	print("    ...Setting threshold...\n\n");
	showStatus("Setting threshold...");
	setAutoThreshold("Default");
	setThreshold(-1000000000000000000000000000000.0000, -16.0000);
	run("NaN Background", "stack");
	print("    ...Analyzing particles...\n\n");
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
	    print("    ...Saving stack as .txt...\n\n");
	    run("Image Sequence... ", "dir="+dir_intermediate+" format=Text name=[] start=1 digits=4 use");
	    close();
	    print("    ...Running MATLAB cleanup code...\n\n");
	    showStatus("Running cleanup code...");
	    run("Run ImageClean ");
	    list = getFileList(dir_intermediate);
	    setBatchMode(true);
	    print("    ...Opening cleaned images...\n\n");
	    for (n=0; n<list.length; n++) {
		    file = dir_intermediate + list[n];
		    run("Text Image... ", "open="+file);
	    }
	    print("    ...Converting images to stack...\n\n");
	    showStatus("Converting images to stack...");
	    run("Images to Stack", "use");
	    setBatchMode(false);
	    setBatchMode("hide");
	    print("    ...Running batch profile analysis macro...\n\n");
	    rename(ImportedSequenceName);
	    run("Invert LUT");
	    run("Select All");
	    run("Select All");
	    run("StackPlotDataMacro ");
	    run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file");
	    print("    ...Deleting .txt files...\n\n");
	    showStatus("Deleting .txt files...");
	    for (n=0; n<list.length; n++) {
	    	File.delete(dir_intermediate+list[n]);
	    	showProgress(n,list.length);
	    }
	    showProgress(1,0);
	    File.delete(dir_intermediate);
	    selectWindow("Log");
	    run("Close");
	}
	else {
		print("    ...Running batch profile analysis macro...\n\n");
	    selectWindow(ImportedSequenceName);
	    setBatchMode("hide");
	    run("Select All");
	    run("StackPlotDataMacro ");
	    run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file");
	}
	selectWindow(ImportedSequenceName);
	print("    ...Creating processed movie...");
	run("Movie...", "frame=30 container=.mov using=H.264 video=excellent save=["+VideoDir+ImportedSequenceName+"/"+ImportedSequenceName+"_processed"+".mov]");
	selectWindow(ImportedSequenceName);
	run("Close");
	saveAs("Results", DataDir+ImportedSequenceName+".csv");
	selectWindow("Results");
	run("Close");
	selectWindow("Log");
	run("Close");
}

close("*");
open(BackgroundImageOpen);
setAutoThreshold("Default");
setThreshold(0, 69, "raw");
run("Convert to Mask");
run("Invert");
run("Invert LUTs");
run("Analyze Particles...", "size=5-Infinity pixel show=Masks include");
selectWindow(BackgroundImage);
run("Close");
selectWindow("Mask of "+BackgroundImage);
run("Select All");
Table.create("Results");
profile = getProfile();
for (i=0; i<profile.length; i++)
      setResult("Value", i, profile[i]);
updateResults;
saveAs("Results", Temp_Dir+"/Background_GrayValues.csv");
close("*");
selectWindow("Results");
run("Close");
setResult("Single-phase DP",0,SinglePhaseDP);
setResult("ImageJ Data Dir",0,DataDir);
setResult("Save Dir",0,VFASaveDir);
setResult("Save .csv Name",0,ExpNum+"_"+ExpName+"_Void_Fraction_Matrix");
setResult("Save Plots Name",0,ExpNum+"_"+ExpName+"_Void_Fraction_Plots");
setResult("Plot Name",0,"'"+ExpNum+" "+ExpName+"' Void Fraction Plots");
selectWindow("Results");
run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file save_column");
saveAs("Results",Temp_Dir+"/_intermediate_data_transfer_.csv");
run("Close");
run("Run VoidFractionCalculator ");
if (File.exists(background_dir)) {
	File.delete(BackgroundImageOpen);
	File.delete(background_dir);
	selectWindow("Log");
	run("Close");
	}
beep();
showMessage("Macro Completed!\n \nCompleted folder directory:\n"+FolderDir);