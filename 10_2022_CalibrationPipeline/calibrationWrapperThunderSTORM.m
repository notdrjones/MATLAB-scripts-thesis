function [calibrationValues] = calibrationWrapperThunderSTORM(calibrationFolder,outputfolder,options,output)
%CALIBRATIONWRAPPERv2

locCellL = thunderSTORMtoCELL([calibrationFolder, 'L_tunderstormData.csv'],100);
locCellR = thunderSTORMtoCELL([calibrationFolder, 'R_tunderstormData'],100);




% Need to get locCellL and locCellR from ThunderSTORM output

% Extract Localisations from PeakFit output - LEGACY
%[locCellL, ~] = extractPeakFitData('example_data/L.results.xls',81);
%[locCellR, ~] = extractPeakFitData('example_data/R.results.xls',81);

% Load z_positions from metadata
metadataname = dir([calibrationFolder '*metadata.txt']);
z_positions = extractZpositions([calibrationFolder metadataname.name], false);

% make trajctories
[tracksL] = make_trajectories(locCellL,'max_linking_distance',20);
[tracksR] = make_trajectories(locCellR,'max_linking_distance',20);

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

