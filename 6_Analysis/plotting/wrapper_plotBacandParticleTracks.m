function wrapper_plotBacandParticleTracks(folderPath, options)

if nargin<2
    options.cropField = [0 0 2496 2500];
    options.pixelsize = 67; %in nm
    options.cellpadding = 1; %in pixels
    options.cellIDlist = [60,61];
    options.agar = false;
    options.celloutline = false;
    options.plotonimage = false;
    options.cellspeedsmoothing = 1;

    options.frameno = 34;
end

[folderName, dirName, mainDataFolderPath, dataOutPath] = getFileNames(folderPath);
resultsfolder = [dataOutPath dirName folderName];
datafolder = [mainDataFolderPath dirName folderName];


if options.agar == true
    bacTracks = importdata([resultsfolder 'refinedBacLoc.mat']);
else
    bacTracks = importdata([resultsfolder 'allBacteriaTracks.mat']);

% if you want to plot the first frame as a rectangle
    if options.celloutline == true
        bacTracks = cellfun(@(x) getFirstFrameBacLoc(x), bacTracks,'UniformOutput',false);
    end
end

if options.plotonimage == true
    fprintf("Loading fluorescence file..")
    fluorstack = loadtiff([datafolder 'L.tif']);
    fluorimg = fluorstack(:,:,1);
    
    if (options.celloutline == true) || (options.agar == true)
        plotBacsonFirstFrame_Agar(bacTracks,fluorimg, options);
    else
        plotBacTracksonFirstFrame(bacTracks,fluorimg, options);
    end
else
    particleTracks = importdata([resultsfolder 'tracks3D.mat']);
    [~,~,gId] = unique(particleTracks(:,5),'rows');
    particleTracks = splitapply( @(x){x}, particleTracks, gId);

    if (options.celloutline == true) || (options.agar == true)
        plotBacsandParticleTracks_Agar(bacTracks,particleTracks, options);
    else
        %for moving cell trajectories
        plotBacTracksandParticleTracks(bacTracks,particleTracks, options);
        %particleTracks = [];
        %plotBacsandParticleTracks_SpecFrame(bacTracks,particleTracks, options);
    end
end


end
