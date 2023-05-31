//Temporary directory for all temporary files
Temp_Dir = "C:/Users/Sophia/Documents/GitHub/FBCE_ImageProcessing";
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Set CleanRest to default value of false
//Create path to separate intermediate folders for .txt image files and working background
CleanRest = false;
dir_intermediate = Temp_Dir+"/_dir_intermediate_/";
background_dir = Temp_Dir+"/WORKING BACKGROUND/";

//Initiates Log window
print("MACRO STARTED\n_______________________________________________________ \n\n");

//First prompt to user to select directory where experiment datum point folders are located
//Have to manipulate file to get actual workable directory that can be used in ImageJ
folderdir = getDirectory("Indicate directory with datum point folders containing raw images");
FolderDir = File.getDirectory(folderdir+"mockfile");

//Prompt to user to select the folder where processed data is saved
savedir = getDirectory("Indicate processed experiment directory");
SaveDir = File.getDirectory(savedir+"Data/mockfile");
//Routes to separate data and video folders
DataDir = SaveDir+"ImageJ Data/";
VideoDir = SaveDir+"Videos/";
//Creates these directories
File.makeDirectory(SaveDir);
File.makeDirectory(DataDir);
File.makeDirectory(VideoDir);
//Pulls void fraction analysis directory and creates it, then updates directory again
VFASaveDir = File.getDirectory(SaveDir);
File.makeDirectory(VFASaveDir+"Analysis/");
File.makeDirectory(VFASaveDir+"Analysis/Void Fraction Analysis/");
VFASaveDir = VFASaveDir+"Analysis/Void Fraction Analysis/";

//Prompt for experiment name and number
Dialog.create("EXPERIMENT INFORMATION");
Dialog.addMessage("Input experiment information");
Dialog.addString("Experiment number","0.0.0");
Dialog.addString("Experiment name","...");
Dialog.show();
ExpNum = Dialog.getString();
ExpName = Dialog.getString();

//Creates a list of folders in the datum point folder
AllFolders = getFileList(FolderDir);

//Asks user how many datum points from the beginning have single-phase flow
Dialog.create("SINGLE-PHASE DATUM POINTS");
Dialog.addMessage("Input how many Datum Points at the BEGINNING include only single-phase images regardless of what the datup point alignment is with the experiment matrix.\n \nThese folders will be ignored and one of the images will be used as background.\n \nEnter 0 for none.");
Dialog.addNumber("Number of single-phase DP",0);
Dialog.show();
SinglePhaseDP = Dialog.getNumber();

//If there are 1 or more single-phase folders, routes to the first image in the first folder and uses as background
if (SinglePhaseDP > 0) {
    //Creates a list of all files in the first datum point folder
	BackgroundImageArray = getFileList(FolderDir + AllFolders[0]);
	//Selects the first file in the array as the background image
	BackgroundImage = BackgroundImageArray[1];
	//Routes the path to the background image to be used in the 'open' function
	BackgroundImageOpen = FolderDir + AllFolders[0] + BackgroundImage;
}
//If there are no single-phase folders, creates a temporary directory for user to drop a background picture to
else {
    //Creates the temporary directory
	File.makeDirectory(background_dir);
	//Creates a notification for the user and waits for the user to complete the action before proceeding
	waitForUser("'WORKING BACKGOUND' folder created in GitHub directory.\n \nImport a single single-phase flow image into the folder from the\nSAME day as the given experiment was recorded.\n \nOnly then click OK to proceed.");
	//Gets list of all files in the temporary directory
	BackgroundImageArray = getFileList(background_dir);
	//Selects the first file in the array as the background image
	BackgroundImage = BackgroundImageArray[0];
	//Routes the path to the background image to be used in the 'open' function
	BackgroundImageOpen = background_dir+BackgroundImage;
}


//Creates a diolog to ask user to align the datum points in the datum point folder and in the experiment matrix
Dialog.create("EXPERIMENT MATRIX DATUM POINT ALIGNMENT");
Dialog.addMessage("Input which datum point in the images folder corresponds to the first datum point in the experiment matrix.\n \nIf they are perfectly aligned enter 1.\n \nDo not just enter the folder name but rather its order in the datum point folder.");
Dialog.addNumber("Folder number correspoding to 1st DP",1);
Dialog.show();
FirstDPFactor = Dialog.getNumber()-1;

//If there are more single phase datum points than the 1st datum point number. Meaning one or more datum points in the experiment matrix resulted in single phase flow
if (SinglePhaseDP > FirstDPFactor)
    //Will start parsing through the folders starting SinglePhaseDP + 1
    StartDP = SinglePhaseDP;
//If 1st datum point is after single phase flow that means that the first datum point in the experiment matrices does not result in single phase flow
else {
	//Will start parsing through the folders starting FirstDPFactor + 1
	StartDP = FirstDPFactor;
}

//Calculates total number of datum points from the experiment matrix that are present in the datum point folder
TotalDP = AllFolders.length - FirstDPFactor;
//Initializes array of labels. It is as long as the number of present experiment matrix's datum points.
labels = newArray(TotalDP);
//Initializes array of default checkbox status. It is as long as the number of present experiment matrix's datum points.
defaults = newArray(TotalDP);
//Parses through the length of the arrays.
for (i=0; i<TotalDP; i++) {
  //Array "labels" are numbers from 1 in increments of 1.
  labels[i] = d2s(i+1,0);
  //Array "defaults" has all "false" values.
  defaults[i] = true;
}

//Asks user which datum points in the experiment matrix have non-zero power.
Dialog.create("SELECT NON-ZERO POWER DATUM POINTS");
Dialog.addMessage("Select which datum points in the experiment matrix have non-zero power values.\n \n!!!Do NOT select ramp up datum points as it is unecessary!!!\n \nNote: The available selection will not have as many datum points as the experiment matrix. Only recorded datum points are an option.\n \nSingle-phase flow datum points will not be processed.")
//Creates checkbox matrix with "TotalDP" rows, 1 column, corresponding "labels" and "defualts" selection status, which is set to false for all checkboxes.
Dialog.addCheckboxGroup(TotalDP,1,labels,defaults);
Dialog.show();
//Sets this value as false since OpenDP variable has not been created yet.
OpenDPCreated = false;
//Parses through all the checkbox values.
for (i=0; i<TotalDP; i++)
  //If checkbox is set to true.
  if (Dialog.getCheckbox()) {
  	//If OpenDP variable is created.
  	if (OpenDPCreated) {
  		//Appends the value of current datum point to the OpenDP array.
  		OpenDP = Array.concat(OpenDP,i+1);
  	}
  	//If OpenDP variable has not been created yet.
  	else {
  		//Initializes OpenDP variable.
  		OpenDP = newArray(1);
  		//Sets the first value in the OpenDP array to the number of the datum point.
  		OpenDP[0] = i+1;
  		//Sets following value as true since now OpenDP has been created. 
  		OpenDPCreated = true;
  	}
  }
//Array.print(OpenDP);
//waitForUser("click cancel");


for (i=StartDP; i<AllFolders.length; i++) {
	setBatchMode(true);
	Folder = FolderDir + AllFolders[i];
	print("OPENING FOLDER: "+Folder+"\nDATUM POINT: "+(i+1-FirstDPFactor)+"\n\n");
	File.openSequence(Folder, " start=2");
	print("    ...Importing image sequence...\n\n");
	NameArray = getList("image.titles");
	ImportedSequenceName = parseInt(NameArray[0])-FirstDPFactor;
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