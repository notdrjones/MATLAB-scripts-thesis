function wrapper_MultiFolderAnalysis(dirPath,options)

% establish folder paths


%establish values for parameters for prepping image and tracking

if nargin<2
    options.forcedir = false;
    % prep options
    options.cropField = [0 0 2496 2500];
    options.pixelsize = 67;
    options.binning=1;
    options.bgSubtract=true;
    options.threshold = 230;

    % bacteria identification options
    
    options.doShapeAnalysis = false;
    options.distfromedge = 10;
    options.maxArea = 5000; %px2
    options.minArea = 500; %px2

    options.maxMajorAxis = 130;
    options.minMajorAxis = 30;
    options.maxMinorAxis = 40;
    options.minMinorAxis = 5;

    % tracking options
    options.save = true;

    options.modifier = 'none';
    options.pxsize = 1;
    options.dt = 1;
    options.minSLV = 0;

    options.max_linking_distance = 20; % this is always in px
    options.minTrackLength = 20; % always in frames
    options.max_gap_closing = 3; % frames
    options.maxRotExcl = 30; % frames
    options.maxLenVar = 1.5; %relative
    options.interpolateTheta = true;

    % for kymmograph
    options.cellspeedsmoothing = 5;
    options.useLandR = false;
    options.saveflag = true;
    options.cellpadding = 5;
    options.lengthpadforkymo = 5;
    options.widthpadforkymo = 2;

end


stackFolders = dir(fullfile(dirPath, '_*'));
disp(stackFolders);
nFolders = numel(stackFolders);
for i=1:nFolders
    stackFolder = fullfile(dirPath, stackFolders(i).name);
    stackFolder = [stackFolder '\'];
    [folderName, dirName, mainDataFolderPath, dataOutPath] = getFileNames(stackFolder);
    outputPath =  [dataOutPath dirName folderName];
    if ~exist(outputPath, 'dir')
        mkdir(outputPath);
    end
    % if ~ exist(fullfile(stackFolder, 'brightfield.tif'), 'file') || options.forcedir == true
    %     splitChannelsToStacks(stackFolder);
    % end
    % 
    if ~ exist([outputPath 'allBacteriaTracks.mat'], 'file') || options.forcedir == true
        disp(['Now working in folder' stackFolders(i).name]);
        
        if ~exist([dataOutPath dirName], 'dir')
            disp(dataOutPath);
            disp(dirName);
            mkdir([dataOutPath dirName]);
        end
        

        %LOCALISE AND TRACK BACTERIA

        brightfieldPath = fullfile(stackFolder, 'brightfield.tif');

        %-- Track Bacteria (steps 2 and 3)

        bacLoc = findBacteriaStackv3(brightfieldPath,true, options);

        
        fprintf("Tracking Bacteria..")
        allTracks = trackBacteria2D(bacLoc, stackFolder, options);
    end
    % PLOT KYMOGRAPHS
    if ~exist([outputPath 'kymographs2'], 'dir') || options.forcedir == true
        fprintf("Plotting Kymographs..")
        wrapper_plotkymographs(stackFolder, options);
    end
        %MATCH AND TRANSLATE TRACKS
    % if exist([dataOutPath dirName folderName '\translatedtracks3D.mat'], 'file') || options.forcedir == true
    %     if exist([outputPath '\tracks3D.mat'], 'file')
    %         fprintf("Translating tracks...");
    %         wrapper_translateTracksMovingCells(stackFolder);
    %     end
    % end


    end


end