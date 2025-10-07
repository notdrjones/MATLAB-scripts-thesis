function [dfTrackingFilteredCells] = wrapper_translateTracksAgarPad(folderPath, options)

if nargin<2

    options.pixelsize = 67; %in nm
    options.celldiameter=1; %in um
    options.poleLen=0.25; % in um
    options.pixelsize = 67; %in nm
    options.helicalpitch = 6; %in um/full rotation
    options.minTrackLength = 20;
    

end

[folderName, dirName, mainDataFolderPath, dataOutPath] = getFileNames(folderPath);
resultsfolder = [dataOutPath dirName folderName];

bacTracks = importdata([resultsfolder 'refinedBacLoc.mat']);
particleTracks = importdata([resultsfolder 'tracks3D.mat']);
% [~,~,gId] = unique(particleTracks(:,5),'rows');
% particleTracks = splitapply( @(x){x}, particleTracks, gId);
[trackIDsinCells] = matchTrackswithBacteria_Agar(bacTracks, particleTracks, options);
disp(trackIDsinCells);
[nr,~]=size(trackIDsinCells);

dfTrackingFilteredCells = [];

for k=1:nr
    currBac = bacTracks{k};
    trackList = trackIDsinCells{k};
    % disp(size(trackList));
    [~,nr2] = size(trackList);
    
    cell_len = ceil(currBac(1,4)) + 2;
    cell_width = ceil(currBac(1,5)) + 2;   
    centroid_x = currBac(1,1);
    centroid_y = currBac(1,2);
    theta = currBac(1,3);
    %nSegments = options.nSegments;
    currCell = [];
    totframes = 0;
    if nr2 > 0
        for j =1:nr2
            trackID = trackList{1,j}; 
            % disp(trackID);
            currtrack = particleTracks(particleTracks(:,5) == trackID,:);
            % disp(currtrack);
            [translatedTrack3D] = translateTrackAgarPadCell(currBac,currtrack, options);
            nFrames = height(translatedTrack3D);
            % add a column with particle name
            newcol = ones(nFrames,1)*trackID;
            tracktoConcat = horzcat(translatedTrack3D, newcol);
            totframes = totframes + nFrames;
            currCell = vertcat(currCell, tracktoConcat);
            % disp(size(currCell));
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
