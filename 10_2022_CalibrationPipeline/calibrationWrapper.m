function [calibrationValues] = calibrationWrapper(calibrationFolder,outputfolder,options,output)
%CALIBRATIONWRAPPERv2

% load data for registration
%tformfluorescence = load('1_ImageRegistration\tformred.mat');
%tformfluorescence = load('tformLR2x2.mat','tformEstimate');
%tformfluorescence = tformfluorescence.tformEstimate;

tformfluorescence = importdata("tformsJune2023Cropped\R2L.mat");

% get full stack path
stackname = dir([calibrationFolder '*ome.tif']);
stackpath = [calibrationFolder stackname.name];

calibrationFolderRegistered = [calibrationFolder 'registered\'];

% Start by registering the images (L/R FOV)
%registerLRZwo(stackpath, calibrationFolder, tformfluorescence);
registerLRZwoLARGESTACKS2(calibrationFolder, calibrationFolderRegistered, tformfluorescence);

% Find localisations in each side of the stack
options.save = true;
%options.thresholdValue = 0.02;
[locCellL, locCellR] = findLocalisationsLR(calibrationFolderRegistered,options,options);


% Extract Localisations from PeakFit output - LEGACY
%[locCellL, ~] = extractPeakFitData('example_data/L.results.xls',81);
%[locCellR, ~] = extractPeakFitData('example_data/R.results.xls',81);

% Load z_positions from metadata
metadataname = dir([calibrationFolder '*metadata.txt']);
z_positions = extractZpositions([calibrationFolder metadataname.name], false);

% make trajctories
[tracksL] = make_trajectories(locCellL);
[tracksR] = make_trajectories(locCellR);

[calibrationValues, matchedtracksfigure, differenceFigure] = calculateCalibrationParameters(tracksL,tracksR,z_positions,output);
calibrationValues.folder = calibrationFolder;

if output
    save([outputfolder 'calibrationValues.mat'], '-struct', 'calibrationValues');
    
    saveas(matchedtracksfigure, [outputfolder 'matchedtrackfigure.fig']);
    saveas(matchedtracksfigure, [outputfolder 'matchedtrackfigure.tiff']);
    
    saveas(differenceFigure, [outputfolder 'differenceFigure.fig']);
    saveas(differenceFigure, [outputfolder 'differenceFigure.tiff']);
end
end

