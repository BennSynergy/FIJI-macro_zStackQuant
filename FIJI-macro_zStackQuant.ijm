/*
 * 
 * The purpose of this macro "FIJI-macro_zStackQuant.ijm" is to analyse the mean grayvalue intensities along the z-axis and to visualize the fluoroscent signal of multichannel z-stack images. 
 * 
 * Input:
 * 	- Multichannel Z-stack files (e.g. tif-files) (CH1: DAPI, CH2: Fibronectin, CH3: Collagen) in folders sorted by condition 
 * 
 * Output:
 *  - Z-axis Intensity Profiles per Channel (Results and Plot)
 *  - 3-slice Substacks around the slice that showed the Maximum Intensity (each for Channel 2 (CH2) and Channel 3 (CH3))
 *  	1: Raw Substack
 *  	2: Average Z-Projection and Channel Composite for Visualization
 *  - Overview Z-stack Composite Flythrough Visualization (avi-file) 
 *  - Output directory structure includes directories for raw data, Z-projections, and plot results
 *  - Z-axis maximum positions for each channel are saved
 *  - Descriptive statistics are calculated for CH2max and CH3max data  
 *   
 * =========================================================================
 * Copyright (c) 2023, Mario C. Benn, ETH Zurich, Switzerland
 * 
 * Permission to use, copy, modify, and/or distribute this macro for any
 * purpose with or without fee is hereby granted.
 * 
 * The macro is provided "as is", without warranty of any kind, express or implied,
 * including but not limited to the warranties of merchantability, fitness for a 
 * particular purpose and noninfringement. In no event shall the author be liable for any claim, damages or other liability, whether in an action 
 * of contract, tort or otherwise, arising from, out of or in connection with the 
 * macro or the use or other dealings in the macro.
 * ========================================================================= 
 */


//Adapt dirInList to the respective folder structure sorted by condition
dirInList = newArray(
"Ctrl_neg/",
"Ctrl_pos/",
"FBS_neg/",
"FBS_pos/",
"FGF_neg/",
"FGF_pos/",
"IGF_neg/",
"IGF_pos/",
"PDGF_neg/",
"PDGF_pos/",
"TGFb_neg/",
"TGFb_pos/");

dirOutList = dirInList;

dirInRoot =  getDirectory("Choose input directory!"); //can be replaced by the input path
dirOutRoot = getDirectory("Choose input directory!"); //can be replaced by the output path

titles = getList("window.titles");

for (i = 0; i < titles.length; i++) {
	close(titles[i]);
}
run("Clear Results");
	
for (l = 0; l < dirInList.length; l++) {
	//Create Output folder structure
		dirIn = dirInRoot + dirInList[l];
		dirOut = dirOutRoot + dirOutList[l];
		File.makeDirectory(dirOut);
		dirOutPlot = dirOut + "Plots/";
		File.makeDirectory(dirOutPlot);
		dirOutResults = dirOut + "Results/";
		File.makeDirectory(dirOutResults);
		dirOutZOI = dirOut + "ZOI/";
		File.makeDirectory(dirOutZOI);
		dirOutZOIraw = dirOut + "ZOI/RAW/";
		File.makeDirectory(dirOutZOIraw);
		dirOutZOIzproj = dirOut + "ZOI/zProjection/";
		File.makeDirectory(dirOutZOIzproj);	

	//Prep
		run("Close All");
		run("Clear Results");
		list = getFileList(dirIn);
		setBatchMode(false); 
		Array.show(list);
		ZOImax = newArray("CH2Max","CH3Max");
		for (i = 0; i < ZOImax.length; i++) {
			windowlist = getList("window.titles");
			if (ArrayContainsElement(windowlist, "Results_"+ZOImax[i])==true) {
				Table.rename("Results_"+ZOImax[i],"Results");
			}
			run("Clear Results");
		}
	//Debugging tool
		Start =getTime();
		print("Current Dir:" + dirIn);	
		
	for (m = 0; m < list.length; m++) {
		if(indexOf(list[m],"/")>=0){
			//non-folder-items in the list will be skipped
		} else { 
		//Prep & Import Z-stack
			run("Close All");
			StartSeq =getTime();
			run("Bio-Formats Importer", "open="+dirIn+list[m]+" color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
			ID = File.nameWithoutExtension;
			titleIni = getTitle();
			Stack.setDisplayMode("color");
			Stack.setChannel(1);
			run("Blue");
			Stack.setChannel(2);
			run("Green");
			Stack.setChannel(3);
			run("Red");
		
		//Export z-axis profile definition and define the Z-slice of maximum intensity (ZOI); ZOI will be used to quantify fluorescent intensities per Channel
			ZOIarray = newArray();
			getDimensions(width, height, channels, slices, frames);
			title = getTitle();
			color = newArray("blue","green","red");
			chName=newArray("CH1","CH2","CH3");

		//Measure & export all mean intensities
			run("Measure Stack...", "channels slices frames order=zct");
			saveAs("Results", dirOutResults + "Results_" + ID +"_allCH_z-axis-plot_Values.csv");
			close("Results_" + ID +"_allCH_z-axis-plot_Values.csv");
			
		//Plot Z-axis Profiles per channel
			for (k = 0; k < channels; k++) {
				selectWindow(title);
				Stack.setDisplayMode("color");
				Stack.setChannel(k+1);
				run("Plot Z-axis Profile");
				Plot.getValues(xpoints, ypoints);
				//Debug info
					//Array.show(xpoints, ypoints);
				
				//Find Maxima in Z-axis Profiles
					Max = Array.findMaxima(ypoints,0);
					//Debug info
						//Array.show(Max);
					if (Max.length>=2) {
						MaxMax = Array.findMaxima(Max,0);
						//Debug info
							//Array.show(MaxMax);
						ZOI = Max[MaxMax[0]]+1;
					} else {
						ZOI = Max[0]+1;	
					}
				
				//Export Z-axis Profiles
					ZOIarray = Array.concat(ZOIarray,ZOI); 
					Array.show(ZOIarray);
					rename("Plot_zAxisProfile_"+ ID + "_CH" + k+1);
					savePlot();
					rename(color[k]);
					Plot.getValues(xpoints, ypoints);
					Array.show(xpoints, ypoints);
					saveAs("Results", dirOutPlot + "Results_" + ID +"_CH" + k+1 + "_z-axis-plot_Values.csv");
					close("Results_" + ID +"_CH" + k+1 + "_z-axis-plot_Values.csv");
				
				//Exportresults per channel and Z-slice
					selectWindow(title);
					getVoxelSize(width, height, depth, unit);
					getDimensions(width, height, channels, slices, frames);
					run("Clear Results");
					for (i = 0; i < slices; i++) {
						setResult("µm", i, i*depth);
					}
						Stack.setDisplayMode("color");
						Stack.setChannel(k+1);
						for (j = 0; j < slices; j++) {
							Stack.setSlice(j+1);
							getStatistics(area, mean, min, max, std, histogram);
							setResult("mean", j, mean);
							setResult("SD", j, std);
							updateResults();
						}
						saveAs("Results", dirOutResults + "Results_" + ID +"_CH" + k+1 + "_z-axis-plot_Values.csv");
						close("Results_" + ID +"_CH" + k+1 + "_z-axis-plot_Values.csv");
						run("Clear Results");
					}
					
			//Export results, 3-slice substack around maximum z-profile intensity (CH2 and CH3) and composite image
				ZOImax = newArray("CH2Max","CH3Max");
				for (i = 0; i < ZOImax.length; i++) {
					windowlist = getList("window.titles");
					if (ArrayContainsElement(windowlist, "Results_"+ZOImax[i])==true) {
						Table.rename("Results_"+ZOImax[i],"Results");
					}				
				ZOI = ZOIarray[i+1];
				tag = ZOImax[i]+"_ZOI"+ZOIarray[i+1];
					
				//Save 3-slice substack
					selectWindow(title);
					run("Duplicate...", "duplicate slices="+ZOI-1+"-"+ZOI+1);
					//run("Duplicate...", "duplicate slices=8-10");
					saveAs("TIFF", dirOutZOIraw + ID + "_" + tag + "_z"+ZOI-1+"-"+ZOI+1+".tif");
				
				//Save Z-projection of substack
					run("Z Project...", "projection=[Average Intensity]");
					saveAs("TIFF", dirOutZOIzproj + ID + "_" + tag + "_z"+ZOI-1+"-"+ZOI+1+"_zAVG.tif");
				
				//Export results
					setResult("Label", nResults, ID);
					setResult("ZOI", nResults-1, d2s(ZOI-1,0)+"-"+d2s(ZOI+1,0));
					setResult("Z-max", nResults-1, ZOImax[i]);
					for (j = 0; j < channels; j++) {
						Stack.setDisplayMode("color");
						Stack.setChannel(j+1);
						getStatistics(area, mean, min, max, std, histogram);						
						setResult(chName[j]+"_Mean", nResults-1, mean);
						setResult(chName[j]+"_SD", nResults-1, std);
						updateResults();
					}
				
				//Save composite image for visualization
					Stack.setDisplayMode("color");
					Stack.setChannel(1);
					run("Enhance Contrast...", "saturated=0.05");
					Stack.setDisplayMode("composite");
					Stack.setActiveChannels("111");
					run("Scale Bar...", "width=20 height=4 font=14 color=White background=None location=[Lower Right] bold overlay");
					saveAs("PNG", dirOutZOI + ID + "_" + tag + "_z"+ZOI-1+"-"+ZOI+1+"_zAVG_composite.PNG");
					Table.rename("Results","Results_"+ZOImax[i]);						
				}
			
			//Plot Z-axis Profile for all channels
				selectWindow(color[2]);
				Plot.setStyle(0, "red,none,1.0,Line");
				Plot.setStyle(1, "red,none,1.0,Circle");	
				Plot.addFromPlot("blue", 0);
				Plot.setStyle(2, "blue,none,1.0,Line");
				Plot.addFromPlot("blue", 1);
				Plot.setStyle(3, "blue,none,1.0,Circle");
				Plot.addFromPlot("green", 0);
				Plot.setStyle(4, "green,none,1.0,Line");
				Plot.addFromPlot("green", 1);
				Plot.setStyle(5, "green,none,1.0,Circle");
				rename(ID + "Plot_zAxisProfile_allCH");
				Plot.setLimitsToFit();
				PlotTitle = getTitle();
			    Plot.makeHighResolution("HiRes",2.0);
			    saveAs("PNG", dirOut + PlotTitle + ".png");
			    close();    
				close(color[0]);
				close(color[1]);

			//Export Z-axis maximum positions per channel
				windowlist = getList("window.titles");
				if (ArrayContainsElement(windowlist, "zAxisResults")==true) {
					Table.rename("zAxisResults","Results");		
				}
				setResult("Label", nResults, ID);
				setResult("ZOI_CH1max", nResults-1, ZOIarray[0]);
				setResult("ZOI_CH2max", nResults-1, ZOIarray[1]);
				setResult("ZOI_CH3max", nResults-1, ZOIarray[2]);
				updateResults();
				saveAs("Results",dirOutRoot + "Z-axis-maximum-positions_per_Channel.csv");
				Table.rename("Results","zAxisResults");

			//Export Overview Composite Z-stack Flythrough Visualization Video (avi)
				selectWindow(title);
				Stack.setDisplayMode("color");
				for (i = 0; i < ZOIarray.length; i++) {
					Stack.setChannel(i+1);
					Stack.setSlice(ZOIarray[i]);
					run("Enhance Contrast...", "saturated=0.05");
				}
				Stack.setDisplayMode("composite");
				Stack.setActiveChannels("111");
				run("Scale Bar...", "width=20 height=4 font=14 color=White background=None location=[Lower Right] bold overlay");
				run("AVI... ", "compression=JPEG frame=7 save=["+dirOut+ID+".avi]");
				
			EndSeq =getTime();
			print(i+1+"/"+list.length+": "+ID);
			print("Sequence duration: "+ EndSeq-StartSeq +" ms");	
		}
	}
	
	//Export results_CH2Max & CH3Max
		selectWindow("Results_CH2Max");
		saveAs("Results",dirOutResults + "Results_CH2Max.csv");
		selectWindow("Results_CH3Max");
		saveAs("Results",dirOutResults + "Results_CH3Max.csv");
		
	//Descriptive statistics for CH2max and CH3max data
		//CH2max
			windowlist = getList("window.titles");
			if (ArrayContainsElement(windowlist, "CH2max_GroupResults.csv")==true) {
				Table.rename("CH2max_GroupResults.csv","Results");		
			}
			if (ArrayContainsElement(windowlist, "CH2max_GroupResults")==true) {
				Table.rename("CH2max_GroupResults","Results");		
			}
			selectWindow("Results_CH2Max.csv");
			CH1mean = Table.getColumn("CH1_Mean");
			CH2mean = Table.getColumn("CH2_Mean");
			CH3mean = Table.getColumn("CH3_Mean");
			setResult("Label", nResults, dirInList[l]);
			setResult("n", nResults-1, lengthOf(CH1mean));
			Array.getStatistics(CH1mean, min, max, mean, stdDev);
			setResult("CH1_mean", nResults-1, mean);
			setResult("CH1_sd", nResults-1, stdDev);
			Array.getStatistics(CH2mean, min, max, mean, stdDev);
			setResult("CH2_mean", nResults-1, mean);
			setResult("CH2_sd", nResults-1, stdDev);
			Array.getStatistics(CH3mean, min, max, mean, stdDev);
			setResult("CH3_mean", nResults-1, mean);
			setResult("CH3_sd", nResults-1, stdDev);
			Table.rename("Results","CH2max_GroupResults");
			saveAs("Results",dirOutRoot + "CH2max_GroupResults.csv");
			Table.rename("Results_CH2Max.csv","Results");
			run("Clear Results");

		//CH3max
			windowlist = getList("window.titles");
			if (ArrayContainsElement(windowlist, "CH3max_GroupResults.csv")==true) {
				Table.rename("CH3max_GroupResults.csv","Results");	
			}
			if (ArrayContainsElement(windowlist, "CH3max_GroupResults")==true) {
				Table.rename("CH3max_GroupResults","Results");	
			}
			selectWindow("Results_CH3Max.csv");
			CH1mean = Table.getColumn("CH1_Mean");
			CH2mean = Table.getColumn("CH2_Mean");
			CH3mean = Table.getColumn("CH3_Mean");
			setResult("Label", nResults, dirInList[l]);
			setResult("n", nResults-1, lengthOf(CH1mean));
			Array.getStatistics(CH1mean, min, max, mean, stdDev);
			setResult("CH1_mean", nResults-1, mean);
			setResult("CH1_sd", nResults-1, stdDev);
			Array.getStatistics(CH2mean, min, max, mean, stdDev);
			setResult("CH2_mean", nResults-1, mean);
			setResult("CH2_sd", nResults-1, stdDev);
			Array.getStatistics(CH3mean, min, max, mean, stdDev);
			setResult("CH3_mean", nResults-1, mean);
			setResult("CH3_sd", nResults-1, stdDev);
			Table.rename("Results","CH3max_GroupResults");
			saveAs("Results",dirOutRoot + "CH3max_GroupResults.csv");
			Table.rename("Results_CH3Max.csv","Results");
			run("Clear Results");
	
	//Debugging & time management tools				
		End =getTime();
		print("Process duration: "+((End-Start)/1000)/60+" minutes");		
}

//Debugging & time management tools	
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	selectWindow("Log");
	saveAs("Text", dirOutRoot + year + "_" + month+1 + "_" + dayOfMonth + "_Log.txt");

function savePlot() {
		    PlotTitle = getTitle();
		    Plot.makeHighResolution("HiRes",2.0);
		    saveAs("PNG", dirOutPlot + PlotTitle + ".png");
		    close();    
		}
				
function ArrayContainsElement(array, element) {
	ContainsIndicator = 0;
	for (i = 0; i < array.length; i++) {
		if (element == array[i]) {
			ContainsIndicator++;
		}
	}
	if (ContainsIndicator >=1) {
		return true	
	} else return false
}
			 	