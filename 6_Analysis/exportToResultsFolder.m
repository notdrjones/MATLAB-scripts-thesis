function exportToResultsFolder(dataFolder,resultsFolder)
% A function to take cropped cells videos and move them to a results folder
% for further analysis and categorisation

% Note that this assumes the processed files are kept in a directory called
% "output", which is inside the main acquisition folder for the day

if strcmp(dataFolder(end),'\')
else
    dataFolder(end+1) = '\';
end

if strcmp(resultsFolder(end),'\')
else
    resultsFolder(end+1) = '\';
end

% Use split to divide the string into substrings with directories
subFolders = split(dataFolder,'\');

mainAcquisitionFolder = subFolders{end-3}; % This would be something like "2023_06_08_SprB0.1nM_tunnel"
subAcquisitionFolder = subFolders{end-1}; % This something like "_1"

% Now set up the save folder
resultsFolder = [resultsFolder mainAcquisitionFolder '\']; 

if ~exist(resultsFolder,'dir')
    mkdir(resultsFolder)
end


%-- Now look through the dataFolder for any cropped cells
croppedCellsDirectory = [dataFolder 'cropped\'];
croppedCellsList = dir([croppedCellsDirectory 'cell_*']);

nCroppedCells = length(croppedCellsList);

for i=1:nCroppedCells
    croppedCellFolder = croppedCellsList(i).name;
    copyPath = [resultsFolder 'acquisition' subAcquisitionFolder '_' croppedCellFolder '\'];
    copyfile([croppedCellsDirectory croppedCellFolder], copyPath);

    % For each folder, create a MATLAB structure with some info
    croppedCellData = struct;
    croppedCellData.originalFolder = dataFolder;
    croppedCellData.copiedOn = datetime;
    croppedCellData.category = 'Uncategorised';

    % Save the structure too
    save([copyPath 'croppedCellData.mat'], 'croppedCellData');
end
end

