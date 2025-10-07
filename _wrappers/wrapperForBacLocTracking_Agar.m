function [finalBacLocs]= wrapperForBacLocTracking_Agar(folderPath,options)

% establish folder paths

[folderName, dirName, mainDataFolderPath, dataOutPath] = getFileNames(folderPath);
if ~exist([dataOutPath dirName], 'dir')
    mkdir([dataOutPath dirName]);
end

outputPath =  [dataOutPath dirName folderName];
if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end

%establish values for parameters for prepping image and tracking

if nargin<2
    % prep options
    options.cropField = [0 0 2496 2500];
    options.binning=1;
    options.bgSubtract=false;
    options.threshold = 100;
    options.dotransform = true;
    options.rotationangle = 0;
    options.translation = [-12 12];
    % bacteria identification options
    
    options.doShapeAnalysis = false;
    options.distfromedge = 10;
    options.maxArea = 5000; %px2
    options.minArea = 500; %px2

    options.maxMajorAxis = 150;
    options.minMajorAxis = 30;
    options.maxMinorAxis = 40;
    options.minMinorAxis = 1;

    % tracking options
    options.save = true;

    options.modifier = 'none';
    options.pxsize = 1;
    options.dt = 1;
    options.maxDisp = 10;
    options.maxDtheta = 7;

    options.max_linking_distance = 5; % this is always in px
    options.minTrackLength = 1; % always in frames
    options.max_gap_closing = 1; % frames
    options.maxRotExcl = 30; % frames
    options.maxLenVar = 1.5; %relative
    options.interpolateTheta = true;


end


brightfieldPath = fullfile(folderPath, 'brightfield.tif');

% 
bacLoc = findBacteriaStackv3(brightfieldPath,true, options);
% bacLoc = importdata([folderPath 'bacLoc.mat']);


% finalBacLocs = num2cell(bacLoc{1},2);
% save([outputPath 'refinedBacLoc.mat'], 'finalBacLocs');
% 
% fprintf("Refining Agar Localisations..")
% 
finalBacLocs = localiseAgarBacteria2D(bacLoc, folderPath, options);



end