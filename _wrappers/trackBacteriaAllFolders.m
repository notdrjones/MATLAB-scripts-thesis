function trackBacteriaAllFolders(mainFolder, options)

if nargin<2
    % prep options
    options.cropField = [1536 426 2484 2556];
    options.binning=2;
    options.bgSubtract=true;
    options.threshold = 235;
    options.dotransform = true;
    options.rotationangle = 0;
    options.translation = [-12 12];
    % bacteria identification options
    options.distfromedge = 10;
    options.doShapeAnalysis = false;
    
    options.maxArea = 5000; %px2
    options.minArea = 500; %px2

    options.maxMajorAxis = 130;
    options.minMajorAxis = 30;
    options.maxMinorAxis = 40;
    options.minMinorAxis = 1;

    % tracking options
    options.save = true;

    options.modifier = 'none';
    options.pxsize = 1;
    options.dt = 1;
    options.minSLV = 0;

    options.max_linking_distance = 20; % this is always in px
    options.minTrackLength = 20; % always in frames
    options.max_gap_closing = 3; % frames

end

stackFolders = dir(fullfile(mainFolder, '_*'));
disp(stackFolders);
nFolders = numel(stackFolders);
for i=1:nFolders
    folderName = stackFolders(i).name;
    folderPath = [mainFolder folderName '\'];
    disp(folderPath);
    [~, ~]= wrapperForBacLocTracking(folderPath,options);
    
end

end