# FIJI-macro_zStackQuant

## Fiji Macro for Z-stack Image Analysis
This repository contains a Fiji macro that analyzes the mean gray-value intensities along the z-axis and visualizes the fluorescent signal of multichannel z-stack images. This analysis can aid in understanding the fluorescent signal distribution in three-dimensional microscopy data. 

The macro processes data from multichannel z-stack images (e.g. .tif files with e.g. DAPI, Fibronectin, Collagen), which are expected to be organized in folders sorted by condition. Outputs include z-axis intensity profiles for each channel, 3-slice substacks, an overview z-stack composite flythrough visualization, and related statistical data.

## Requirements
The macro has been developed and tested on the following Fiji version: ImageJ2 V 2.9.0 1.53t. To ensure compatibility, use this version or later versions.

## Functionality
The macro is designed to:
* Calculate and plot Z-axis intensity profiles for each channel.
* Generate 3-slice substacks around the slice that showed the maximum intensity for Channel 2 (CH2) and Channel 3 (CH3).
* Create visualizations of the z-stack images and intensity profiles.
* Save maximum z-axis positions for each channel.
* Compute descriptive statistics for CH2max and CH3max data.

The macro's input is multichannel Z-stack files (e.g., tif files), sorted by condition, with three channels:
1. Channel 1 (CH1): DAPI
2. Channel 2 (CH2): Fibronectin
3. Channel 3 (CH3): Collagen

The output includes Z-axis intensity profiles per channel, raw substacks and average Z-projections for visualization, and a Z-stack composite flythrough visualization (avi file).

## Installation
To use this macro, clone this repository to your local machine.

## Usage
1. Open Fiji ImageJ.
2. Open the Fiji macro with a text editor.
3. Adapt the `dirInList` array to your folder structure, where each folder is sorted by condition. For example: `dirInList = newArray( "Ctrl_neg/", "Ctrl_pos/", "FBS_neg/", "FBS_pos/", "FGF_neg/", "FGF_pos/", "IGF_neg/", "IGF_pos/", "PDGF_neg/", "PDGF_pos/", "TGFb_neg/", "TGFb_pos/");`
4. Run the macro in Fiji. The macro will prompt you to select an input and an output directory. 
`dirInRoot = getDirectory("Choose input directory!"); dirOutRoot = getDirectory("Choose output directory!");`
Alternatively, you can replace these lines with your specific input and output paths:
`dirInRoot = "/path/to/your/input/directory/"; dirOutRoot = "/path/to/your/output/directory/";`
5. When prompted, select the input directory containing the multichannel z-stack images.
6. The macro will then process the images, saving the results to the output directory.
7. The macro will generate the required output files in the specified output directory.

## Output
The macro generates the following directory structure for output files:
* `Plots`: you will find plots for the z-axis intensity profiles for each channel
* `Results`: you will find .csv files for the z-axis intensity profile values and maximum z-axis positions for each channel.
* `ZOI`: you will find the 3-slice substacks around the slice that showed the maximum intensity for each channel and their average z-projections.

In the root of the output directory, you will also find an avi file for the overview z-stack composite flythrough visualization.

