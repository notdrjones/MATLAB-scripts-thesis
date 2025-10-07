function wrapper_MultiFolderAnalysis_Agar(dirPath,options)

% establish folder paths


%establish values for parameters for prepping image and tracking

if nargin<2
    options.forcedir = false;
    % prep options
    options.cropField = [0 0 2496 2500];
    options.pixelsize = 67;
    options.binning=1;
    options.bgSubtract=false;
    options.threshold = 60;
    
    % bacteria identification options
    
    options.doShapeAnalysis = false;
    options.distfromedge = 2;
    options.maxArea = 5000; %px2
    options.minArea = 500; %px2

    options.maxMajorAxis = 200;
    options.minMajorAxis = 30;
    options.maxMinorAxis = 40;
    options.minMinorAxis = 3;

    % tracking options
    options.save = true;

    options.modifier = 'none';
    options.pxsize = 1;
    options.dt = 1;

    options.max_linking_distance = 3; % this is always in px
    options.minTrackLength = 20; % always in frames
    options.max_gap_closing = 1; % frames
    options.maxRotExcl = 30; % frames
    options.maxLenVar = 1.5; %relative
    options.maxDisp = 10;
    options.maxDtheta = 7;

    % for kymmograph
    options.useLandR = false;
    options.saveflag = true;
    options.cellpadding = 5;
    options.lengthpadforkymo = 20;
    options.widthpadforkymo = 3;

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
    if ~ exist(fullfile(stackFolder, 'brightfield.tif'), 'file') || options.forcedir == true
        splitChannelsToStacks(stackFolder);
    end

    if ~exist([outputPath 'refinedBacLoc.mat'], 'file') || options.forcedir == true
        disp(['Now working in folder' stackFolders(i).name]);

        if ~exist([dataOutPath dirName], 'dir')
            disp(dataOutPath);
            disp(dirName);
            mkdir([dataOutPath dirName]);
        end

        % LOCALISE AND TRACK BACTERIA

        wrapperForBacLocTracking_Agar(stackFolder,options);
    end
    
    % wrapper_plotBacandParticleTracks(stackFolder);
    % 
    % PLOT KYMOGRAPHS
    if ~exist([outputPath 'kymographs2'], 'dir') || options.forcedir == true
        fprintf("Plotting Kymographs..")
        wrapper_plotkymographs_agar(stackFolder, options);
    end
    % MATCH AND TRANSLATE TRACKS
    if exist([dataOutPath dirName folderName '\translatedtracks3D.mat'], 'file') || options.forcedir == true
        %then just to check i have done the initial localising and tracking
        if exist([outputPath '\tracks3D.mat'], 'file')
            fprintf("Translating tracks...");
            wrapper_translateTracksAgarPad(stackFolder);
        end
    end


    end


end