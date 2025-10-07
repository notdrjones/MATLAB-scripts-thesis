function allTracks = wrapperForBacTracking_MultiFolder_pcm(dirPath,options)

% modified version of script for acquisitions from phase contrast
% microscope in the lab


%establish values for parameters for prepping image and tracking

if nargin<2
    options.forcedir = false;
    % prep options
    options.cropField = [0 0 2496 2500];
    options.binning=1;
    options.bgSubtract=true;
    options.threshold = 150;
    options.dotransform = true;
    options.rotationangle = 0;
    options.translation = [-12 12];
    % bacteria identification options
    
    options.doShapeAnalysis = false;
    options.distfromedge = 10;
    options.maxArea = 100; %px2
    options.minArea = 20; %px2

    options.maxMajorAxis = 20;
    options.minMajorAxis = 6;
    options.maxMinorAxis = 5;
    options.minMinorAxis = 1;

    % tracking options
    options.save = false;

    options.modifier = 'none';
    options.pxsize = 1;
    options.dt = 1;
    options.minDisp = 40;

    options.max_linking_distance = 10; % this is always in px
    options.minTrackLength = 20; % always in frames
    options.max_gap_closing = 3; % frames
    options.maxRotExcl = 30; % frames
    options.maxLenVar = 1.5; %relative
    options.interpolateTheta = true;


end

files = dir(fullfile(dirPath, '*.tif'));
disp(files);
nFiles = numel(files);
for i = 1:nFiles
    filename = files(i).name;
    filebasename = filename(1:end-4);
    disp(['Now working in folder' filename]);
    
    outputPath =  [dirPath filebasename];

    brightfieldPath = fullfile(dirPath, filename);
    
    %-- Track Bacteria (steps 2 and 3)


    
    if ~ exist([dirPath filebasename 'allBacteriaTracks.mat'], 'file') || options.forcedir == true

        bacLoc = findBacteriaStackv3(brightfieldPath,true, options);
        
        fprintf("Tracking Bacteria..")
        
        allTracks = trackBacteria2D_pcm(bacLoc, options);

        save([outputPath 'allBacteriaTracks.mat'], 'allTracks');
        fprintf("Data saved to (%s)\n", outputPath);
    else
        allTracks = importdata([outputPath 'allBacteriaTracks.mat']);
    end 
    
    tracksFigure = plotGradientBacteriaTrajectories2(allTracks);
    shg
    pause(5);

    if ~ exist([outputPath 'allVelocities.xlsx'], 'file') || options.forcedir == true
        velocities = getVelocitiesSegments(allTracks);
        writetable(array2table(velocities), [outputPath 'allVelocities.xlsx'])
    end



end