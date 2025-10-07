//CLIJx extension for BoneJ is not installed correctly. Please activate the 'BoneJ' update site
//CLIJx extension for MorpholibJ is not installed correctly. Please activate the 'IJPB-Plugins' update site
//CLIJx extension for the ImageJ 3D Suite is not installed correctly. Please activate the '3D ImageJ Suite' update site
 //* Intel(R) UHD Graphics 750

// start with clean interface
close("*");
print("\\Clear");
setBatchMode("hide");

// ask user to select folder to analyse
#@ File(style="directory") mainFolder
#@ File(style="directory") mainOutputFolder
#@ Boolean(label="Double?") doubleFlag

// get list of folders inside main folder
list = getFileList(mainFolder);

// loop over the list
for (i = 0; i < list.length; i++) {
	// check if folder is a brightfield one
		if (endsWith(list[i], "_brightfield/")){
				folder = mainFolder + "/" + list[i];
				//output_folder = folder + "stack/";
				output_folder = mainOutputFolder + "/" +  replace(list[i], "_brightfield", "");
				filename = File.getName(folder);
			    
                
				print("Processing folder: " + filename + "\n");
				
				// make folder
				File.makeDirectory(output_folder);

				// open sequence
				File.openSequence(folder , " filter=img start=1 count=100");

				// now apply transform
				//run("Top-Hat background subtraction frame by frame on multiple GPUs (experimental)", "sigma=20 sigma_0=20 sigma_1=0");
				run("Top Hat...", "radius=20 stack");
								
				// then apply gauss blur
				run("Gaussian Blur...", "sigma=2 stack");
				
				if (doubleFlag==true) {
					rename("image");
					run("Duplicate...", "duplicate");
					rename("image2");
					
					// interleave
					run("Interleave", "stack_1=image stack_2=image2");
				}
				
				// save the image in stack form into the folder
				saveAs("Tiff", output_folder + filename + "_stack.tif");
				
				// and now get the mask
				run("Convert to Mask", "method=Triangle background=Dark calculate");
				//run("Convert to Mask", "method=Triangle background=Dark create");
				// save the stack as a mask into the folder
				saveAs("Tiff", output_folder + filename + "_mask.tif");
				
				close("*");
		}
}


setBatchMode("exit and display");
print("Done");