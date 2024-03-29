//Directory for all temporary files.
Temp_Dir = "C:/Users/Sophia/Documents/GitHub/FBCE_ImageProcessing";
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Set CleanRest to default value of false.
//Create path to separate intermediate folders for .txt image files and working background.
CleanRest = false;
clean = false;
dir_intermediate = Temp_Dir+"/_dir_intermediate_/";
background_dir = Temp_Dir+"/WORKING BACKGROUND/";

//Initiates Log window
print("MACRO STARTED\n_______________________________________________________ \n\n");

//First prompt to user to select directory where experiment datum point folders are located.
//Have to manipulate file to get actual workable directory that can be used in ImageJ.
folderdir = getDirectory("Indicate directory with datum point folders containing raw images");
FolderDir = File.getDirectory(folderdir+"mockfile");

//Prompt to user to select the folder where processed data is saved.
savedir = getDirectory("Indicate processed experiment directory");
SaveDir = File.getDirectory(savedir+"Data/mockfile");
//Routes to separate data and video folders.
DataDir = SaveDir+"ImageJ Data/";
VideoDir = SaveDir+"Videos/";
//Creates these directories.
File.makeDirectory(SaveDir);
File.makeDirectory(DataDir);
File.makeDirectory(VideoDir);
//Pulls void fraction analysis directory and creates it, then updates directory again..
VFASaveDir = File.getDirectory(SaveDir);
File.makeDirectory(VFASaveDir+"Analysis/");
File.makeDirectory(VFASaveDir+"Analysis/Void Fraction Analysis/");
VFASaveDir = VFASaveDir+"Analysis/Void Fraction Analysis/";

//Prompt for experiment name, number, whether both or only side is heated at once and whether the experiment is steady-state or transient.
Dialog.create("EXPERIMENT INFORMATION");
Dialog.addMessage("Input experiment information");
Dialog.addString("Experiment number","0.0.0",10);
Dialog.addString("Experiment name","...",100);
Dialog.addMessage("________________________________________________________________________________________________________________");
Dialog.addChoice("Heated Side(s) at Once", newArray("Bottom/One at a Time","Both"), "Bottom");
Dialog.addChoice("Time Dependency", newArray("Steady-state","Transient"), "Steady-state");
Dialog.show();
ExpNum = Dialog.getString();
ExpName = Dialog.getString();
HeatedSide = Dialog.getChoice();
TimeWise = Dialog.getChoice();

//If experiment is transient and only one sided, this part creates a dialogue asking user to select whether it is On/Off or Alternating.
if (HeatedSide == "Bottom/One at a Time" && TimeWise == "Transient") {
	Dialog.create("TRANSIENT EXPERIMENT TYPE");
	Dialog.addChoice("Please indicate which transient experiment type does the experiment correspond to", newArray("On/Off","Alternating"), "On/Off");
	Dialog.show();
	TimeWise = Dialog.getChoice();
}

//Creates a dialog asking user how many datum point folders there are in the specified data folder and whether the values can be assigned automatically.
Dialog.create("NUMBER OF DATUM POINT FOLDERS");
Dialog.addMessage("Input how many datum points folders there are in the specified data folder.\n \nSpecify whether datum points are in a continuous ascending order or to assign them manually.");
Dialog.addNumber("Number of folders",0);
Dialog.addCheckbox("Assign values automatically",true);
Dialog.show();
Nfolders = Dialog.getNumber();
AssignAuto = Dialog.getCheckbox();

//If values are assigned automatically from 1 to nFolders in increments on 1.
if (AssignAuto) {
	//Initializes array of folder names which will be used to create directories.
	AllFoldersNumbers = newArray(Nfolders);
    AllFolders = newArray(Nfolders);
    //Parses through all the folder numbers and populates AllFolders array with them.
    for (i=0; i<Nfolders; i++) {
		AllFoldersNumbers[i] = toString(i+1);
	    //Have to add "/" at the end because that is a part of folder path.
	    AllFolders[i] = toString(i+1)+"/";
    }
}
//If datum point folders do not follow a continuous pattern.
else {
	//Creates a user interface with a number slot for each datum point folder
	Dialog.create("Datum Point Values");
	Dialog.addMessage("Indicate folder numbers, input in ascending order.");
	for (i=0; i<Nfolders; i++) {
		Dialog.addNumber("",0);
	}
	Dialog.show();
	//Initializes array of folder names which will be used to create directories.
	AllFoldersNumbers = newArray(Nfolders);
    AllFolders = newArray(Nfolders);
	for (i=0; i<Nfolders; i++) {
		iFolder = Dialog.getNumber();
		AllFoldersNumbers[i] = toString(iFolder);
		AllFolders[i] = toString(iFolder)+"/";
	}
}

//Asks user how many datum points from the beginning have single-phase flow and ask user to align the datum points in the datum point folder and in the experiment matrix
Dialog.create("DATUM POINT SETTINGS");
Dialog.addMessage("Input how many Datum Points at the BEGINNING include only single-phase images regardless of what the datum point alignment is with the experiment matrix.\n \nThese folders will be ignored and one of the images will be used as background.\n \nEnter 0 for none.");
Dialog.addNumber("Number of single-phase DP",0);
Dialog.addMessage("____________________________________________________________________________________________________________________________");
Dialog.addMessage("Input which datum point in the images folder corresponds to the first datum point in the experiment matrix.\n \nIf they are perfectly aligned enter 1.\n \nDo not just enter the folder name but rather its order in the datum point folder.");
Dialog.addNumber("Folder number correspoding to 1st DP",1);
Dialog.show();
SinglePhaseDP = Dialog.getNumber();
FirstDPFactor = Dialog.getNumber()-1;

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
  labels[i] = d2s(AllFoldersNumbers[i],0);
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
  }  //At the end of this OpenDP contains datum points to be opened according to the experiment matrix notation. 
     //Need to be adjusted and converted to ImageJ indexing notation.

//Sets this value as false since DeleteDP variable has not been created yet.
DeleteDPCreated = false;
//Parses through all OpenDP values to remove single-phase flow DPs and convert the array into ImageJ indexing notation.
for (i=0; i<OpenDP.length; i++) {
	//If current datum point is single-phase.
	if (OpenDP[i] <= SinglePhaseDP - FirstDPFactor) {
		//If DeleteDP array already exists.
		if (DeleteDPCreated) {
			//Ad current index to the array
			DeleteDP = Array.concat(DeleteDP,i);
		}
		//If DeleteDp array does not exist.
		else {
			//Initialize the array.
			DeleteDP = newArray(1);
			//Make the current value equal to the current index.
			DeleteDP[0] = i;
			//Set DeleteDPCreated variable to true as DeleteDP variable now exists.
			DeleteDPCreated = true;
		}
	}
	//If current datum point is not single-phase.
	else {
		//Offset the datum point up by the First Datum Point Factor and offset down by 1 to accommodate ImageJ's indexing from 0.
		OpenDP[i] = OpenDP[i] + FirstDPFactor - 1;
	}
}

//If there are any datum points that need to be ignored.
if (DeleteDPCreated) {
	//Parse through all indexes in DeleteDP.
	for (i=0; i<DeleteDP.length; i++) {
	//Delete the datum point from the "open" array.
	OpenDP = Array.deleteIndex(OpenDP,DeleteDP[i]-i);
    }
}

for (i=0; i<OpenDP.length; i++) {
    //Establish the index of the current DP.
    CurrentDP = OpenDP[i];
    //Turn Batch Mode on so that newly opened images are not displayed. This speeds up the processing.
	setBatchMode(true);
	//Creates a path to the current iteration of a folder.
	Folder = FolderDir + AllFolders[CurrentDP];
    //Gets the datum point number of the currently opened stack.
	ImportedSequenceName = toString(parseInt(AllFoldersNumbers[CurrentDP])-FirstDPFactor);
	//Add a message to the log which folder is being opened.
	print("OPENING FOLDER: "+Folder+"\nDATUM POINT: "+(ImportedSequenceName)+"\n\n");
	//Open all the images in the datum point as a stack.
	File.openSequence(Folder, " start=2");
	//Print status update.
	print("    ...Importing image sequence...\n\n");
	//Rename the stack into proper DP number.
	rename(ImportedSequenceName);
	//Creates directory for videos.
	File.makeDirectory(VideoDir+ImportedSequenceName+"/");
	//Print status update.
	print("    ...Creating raw movie...\n\n");
	showStatus("Creating movie");
	showProgress(1,0);
	//Shows the raw image stack.
	setBatchMode("show");
	//Saves unprocessed stack as video.
	run("Movie...", "frame=30 container=.mov using=H.264 video=high use save=["+VideoDir+ImportedSequenceName+"/"+ImportedSequenceName+"_raw"+".mov]");
	//Hides the raw stack
	setBatchMode("hide");
	//Opens background image.
	open(BackgroundImageOpen);
	//Print status update.
	print("    ...Subtracting background...\n\n");
	showStatus("Subtracting background...");
	//Subtracts background for the stack.
	imageCalculator("Difference stack", ImportedSequenceName,BackgroundImage);
	//Print status update.
	print("    ...Setting threshold...\n\n");
	showStatus("Setting threshold...");
	//Sets threshold from -Inf to -16 while setting noise pixels to NaN.
	selectWindow(ImportedSequenceName);
    setThreshold(20, 255, "raw");
    setOption("BlackBackground", true);
    run("Convert to Mask", "method=Default background=Dark black");
    //Print status update.
	print("    ...Despeckling...\n\n");
	showStatus("Despeckling...");
    run("Despeckle", "stack");
    close("\\Others");
	//Print status update.
	print("    ...Analyzing particles...\n\n");
	showStatus("Analyzing particles...");
	//Runs "Analyse Particles" function.
	run("Analyze Particles...", "  show=Masks include stack");
	close("\\Others");
	//Sets Batch Mode to false, meaning that the last active window becomes visible and all the rest are discarded.
	setBatchMode(false);
	//After several operations the name of the stack is changed. This command renames it back to the datum point number.
	rename(ImportedSequenceName);
	
	//If only one side is heated per datum point, the stack might have to be cleaned.
	if (HeatedSide == "Bottom/One at a Time" && TimeWise != "On/Off") {
		//If CleanRest is activated, automatically sets 'clean' to true.
		if (CleanRest) {
			clean = true;
			CleanStack = ImportedSequenceName;
		}
		
		//Otherwise prompts user to decide whether the stack needs to be cleaned of shadows.
		else {
		    //Produces a beeping sound to attract user's attention.
			beep();
			//Decision dialog where user can chose whether to clean the stack and/or whether to automatically clean the rest of datum points.
			Dialog.createNonBlocking("DECISION REQUIRED");
			Dialog.addMessage("Does stack need cleaning?\n \nCheck 'Clean Rest' to clean the rest of folders as well.\nIf checked, you will not be prompted this again.");
			Dialog.addCheckbox("Check to clean", true);
			Dialog.addCheckbox("Clean rest",false);
			Dialog.show();
			clean = Dialog.getCheckbox();
			CleanRest = Dialog.getCheckbox();
			CleanStack = ImportedSequenceName;
		}
	}
	else {
		if (TimeWise == "On/Off") {
			Dialog.createNonBlocking("DECISION REQUIRED");
			Dialog.addMessage("Does stack need cleaning?\n \nIf not, options below are not considered.\n \nThis prompt is specialized for single-sided, transient, On/Off experiments.\n \nIf selected 'Beginning', images will be cleaned (0-break).\nWith 'break' being the value of the 'Start/End at:' prompt.\nIf selected 'End', images will be cleaned (break-end)");
			Dialog.addCheckbox("Check to clean", true);
			Dialog.addChoice("Clean at the:", newArray("beginning","end"));
			Dialog.addNumber("Start/End at:",0);
			Dialog.show();
			clean = Dialog.getCheckbox();
			StartorEnd = Dialog.getChoice();
			Break = Dialog.getNumber();
			
			if (clean) {
				if (StartorEnd == "beginning") {
					Start = 1;
					End = Break;
				}
				else {
					Start = Break;
					End = nSlices;
				}
				run("Make Substack...", "slices="+Start+"-"+End+" delete");
				selectWindow("Substack ("+Start+"-"+End+")");
				rename("Substack");
				CleanStack = "Substack";
			}
			
		}
	}
	
	
	//If datum point is selected to be cleaned.
	if (clean) {
	    //Create intermediate diarectory where stack is saved as .txt files.
		File.makeDirectory(dir_intermediate);
		//Selects the stack window.
	    selectWindow(CleanStack);
	    //Print status update.
	    print("    ...Saving stack as .txt...\n\n");
	    //Saves the whole stack as .txt files. One file per image.
	    run("Image Sequence... ", "dir="+dir_intermediate+" format=Text name=[] start=1 digits=5 use");
	    //Closes the stack.
	    close(CleanStack);
	    //Print status update.
	    print("    ...Running MATLAB cleanup code...\n\n");
	    showStatus("Running cleanup code...");
	    //Runs ImageJ code that will invoke MATLAB "cleaning" script.
	    run("Run ImageClean ");
	    //Code continues after MATLAB script is done executing.
	    //Creates a list of files in the intermediate directory.
	    list = getFileList(dir_intermediate);
	    //Turns Batch Mode on so that newly opened images are not shown.
	    setBatchMode(true);
	    //Print status update.
	    print("    ...Opening cleaned images...\n\n");
	    //Iterate for all files in the 'list' array.
	    for (n=0; n<list.length; n++) {
	        //Create path to the file.
		    file = dir_intermediate + list[n];
		    //Open .txt file as image. All images are hence opened in separate windows.
		    run("Text Image... ", "open="+file);
	    }
	    //Print status update.
	    print("    ...Converting images to stack...\n\n");
	    showStatus("Converting images to stack...");
	    //Convert all the opened images into a stack.
	    run("Images to Stack", "use");
	    //Set Batch Mode to false so that cleaned stack becomes visible and individually opened images are discarded.
	    setBatchMode(false);
	    //Rename the stack into original name.
	    rename(CleanStack);
	    //Invert colors as images get imported with inverted colors.
	    run("Invert LUT");
	    //Convert the imported stack into 8-bit.
	    run("8-bit");
	    if (CleanStack == "Substack") {
	    	if (StartorEnd == "beginning") {
	    		run("Concatenate...", "  title="+ImportedSequenceName+" image1=Substack image2="+ImportedSequenceName);
	    	}
	    	else {
	    		run("Concatenate...", "  title="+ImportedSequenceName+" image1="+ImportedSequenceName+" image2=Substack");
	    	}
	    }
	    //Print status update.
	    print("    ...Deleting .txt files...\n\n");
	    showStatus("Deleting .txt files...");
	    //Parse through each .txt image file in the list.
	    for (n=0; n<list.length; n++) {
	        //Delete file.
	    	File.delete(dir_intermediate+list[n]);
	    	//Update progress bar.
	    	showProgress(n,list.length);
	    }
	    //Delete progress bar.
	    showProgress(1,0);
	    //Delete intermediate directory.
	    File.delete(dir_intermediate);
	    //Select and close Log window.
	    selectWindow("Log");
	    run("Close");
	}
	
	//Select stack window.
	selectWindow(ImportedSequenceName);
	//Print status update.
	print("    ...Creating processed movie...\n\n");
	//Save processed stack as video.
	run("Movie...", "frame=30 container=.mov using=H.264 video=normal use save=["+VideoDir+ImportedSequenceName+"/"+ImportedSequenceName+"_processed"+".mov]");
	//Select stack window.
	selectWindow(ImportedSequenceName);
	//Print update.
	print("    ...Running batch profile analysis macro...\n\n");
	//Select the whole image area.
	run("Select All");
	//Hide the stack.
	setBatchMode("hide");
	//Run macro that derives profile plot of each image and combines it into one matrix.
	run("StackPlotDataMacro ");
	//Format the table.
	run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file");
	//Close old stack.
	close(ImportedSequenceName);
	//Save table as .csv file.
	saveAs("Results", DataDir+ImportedSequenceName+".csv");
	//Select the table window and close it.
	selectWindow("Results");
	run("Close");
	//Select and close Log window.
	selectWindow("Log");
	run("Close");
	run("Close All");
}


//Close all image windows.
close("*");
//Open background image.
open(BackgroundImageOpen);
//Apply threshhold.
setAutoThreshold("Default");
setThreshold(0, 69, "raw");
run("Convert to Mask");
//Invert colors.
run("Invert");
run("Invert LUTs");
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
//Save the table as a .csv file.
saveAs("Results", Temp_Dir+"/Background_GrayValues.csv");
//Close all image windows.
close("*");
//Select the table and close it.
selectWindow("Results");
run("Close");

//Create a new "Results" table and write useful data to it for MATLAB processing.
setResult("Single-phase DP",0,SinglePhaseDP);
setResult("ImageJ Data Dir",0,DataDir);
setResult("Save Dir",0,VFASaveDir);
setResult("Save .csv Name",0,ExpNum+"_"+ExpName+"_Void_Fraction_Matrix");
setResult("Save Plots Name",0,ExpNum+"_"+ExpName+"_Void_Fraction_Plots");
setResult("Plot Name",0,"'"+ExpNum+" "+ExpName+"' Void Fraction Plots");
//Select "Results" table window and save it as a .csv file.
selectWindow("Results");
//Format table.
run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file save_column");
//Save table as .csv file.
saveAs("Results",Temp_Dir+"/_intermediate_data_transfer_.csv");
//Close it.
run("Close");

//If intermediate background directory exists, delete it and its contents.
if (File.exists(background_dir)) {
	File.delete(BackgroundImageOpen);
	File.delete(background_dir);
	selectWindow("Log");
	run("Close");
	}
	
//Run analysis code on MATLAB.
run("Run VoidFractionCalculator ");	
	
//Inform user script is completed.
beep();
showMessage("Macro Completed!\n \nCompleted folder directory:\n"+FolderDir);