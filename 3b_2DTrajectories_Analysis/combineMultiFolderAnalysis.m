function combineMultiFolderAnalysis(outputFolder, saveFlag)
%MULTIFOLDERANALYSIS Summary of this function goes here
%   Detailed explanation goes here

if nargin<2
    saveFlag = false;
end

outputFolder = [outputFolder '\'];

% Assume only folders in "outputFolder" are "_1" "_2" etc.
acquisitionFolders  = dir([outputFolder '_*']);

nFolders = length(acquisitionFolders);

allReversalRates = cell(nFolders,1);
allAverageVelocities = cell(nFolders,1);

for i=1:nFolders
    allReversalRates{i} = importdata([outputFolder acquisitionFolders(i).name '\bacteriaTrackingResults\reversalRateArray.mat']);
    allAverageVelocities{i} = importdata([outputFolder acquisitionFolders(i).name '\bacteriaTrackingResults\averageVelocitiesArray.mat']);
end

%-- Convert cells to array - effectively "unfolding" the cells into one long
%list.
allReversalRates = cell2mat(allReversalRates);
allAverageVelocities = cell2mat(allAverageVelocities);


reversalRateFigure = figure;
histogram(allReversalRates)
xlabel('Reversal Frequency (Hz)')
pbaspect([1 1 1])

averageVelocitiesFigure = figure;
histogram(allAverageVelocities)
xlabel('Average Velocity (um/s)')
pbaspect([1 1 1])

if saveFlag
    saveas(reversalRateFigure, [outputFolder '\reversalRateFigure.fig']);
    saveas(reversalRateFigure, [outputFolder '\reversalRateFigure.png']);

    saveas(averageVelocitiesFigure, [outputFolder '\averageVelocitiesFigure.fig']);
    saveas(averageVelocitiesFigure, [outputFolder '\averageVelocitiesFigure.png']);
end

end

