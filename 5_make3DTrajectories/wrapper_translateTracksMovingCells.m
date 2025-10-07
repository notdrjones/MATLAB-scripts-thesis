function [dfTrackingFilteredCells] = wrapper_translateTracksMovingCells(folderPath, options)

if nargin<2

    options.pixelsize = 67; %in nm
    options.celldiameter=1; %in um
    options.poleLen=0.25; % in um
    options.pixelsize = 67; %in nm
    options.helicalpitch = 6; %in um/full rotation
    options.minTrackLength = 10;
    options.cellpadding = 2;
    

end

[folderName, dirName, mainDataFolderPath, dataOutPath] = getFileNames(folderPath);
resultsfolder = [dataOutPath dirName folderName];

bacTracks = importdata([resultsfolder 'allBacteriaTracks.mat']);
rawparticleTracks = importdata([resultsfolder 'tracks3D.mat']);

[~,~,gId] = unique(rawparticleTracks(:,5),'rows');
rawparticleTracks = splitapply( @(x){x}, rawparticleTracks, gId);
particleTracks = cellfun(@(x) interpolateTrack(x, false), rawparticleTracks, 'UniformOutput',false);
particleTracks = cell2mat(particleTracks);
[trackIDsinCells] = matchTrackswithBacteriaAcrossAllFrames(bacTracks, particleTracks, options);

[nr,~]=size(trackIDsinCells);

dfTrackingFilteredCells = [];

for k=1:nr
    currBac = bacTracks{k};
    trackList = trackIDsinCells{k};

    [~,nr2] = size(trackList);
    %add buffer to cell length and width to include all fluorescence info
    cell_len = nanmean(currBac(:,5)) + 1;
    cell_width = nanmean(currBac(:,6)) + 1;
    %nSegments = options.nSegments;
    currCell = [];
    totframes = 0;
    if nr2 > 0
        for j =1:nr2
            trackID = trackList{1,j}; 
            
            currtrack = particleTracks(particleTracks(:,5) == trackID,:);
    
            % disp(currtrack);
            [translatedTrack3D] = translateTrackInMovingCell(currBac,currtrack, options);
            nFrames = height(translatedTrack3D);
            % add a column with particle name
            newcol = ones(nFrames,1)*trackID;
            tracktoConcat = horzcat(translatedTrack3D, newcol);
            totframes = totframes + nFrames;
            currCell = vertcat(currCell, tracktoConcat);  
        end
    
        if ~totframes ==0
            newcol = ones(totframes,1)*k;
            celltoConcat = horzcat(currCell, newcol);
            dfTrackingFilteredCells = vertcat(dfTrackingFilteredCells, celltoConcat);
        end
    end
end

save([resultsfolder 'translatedtracks3D.mat'], 'dfTrackingFilteredCells');

end
