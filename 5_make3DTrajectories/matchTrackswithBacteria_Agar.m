function [trackIDsinCells] = matchTrackswithBacteria_Agar(bacteriaTracks, tracks3D, options)


if nargin<3
    options.save = false;
    options.L = 100;
    options.minTrackLength = 20;
end


% [folderName, dirName, mainDataFolderPath, dataOutPath] = getFileNames(folderPath);
% resultsfolder = [dataOutPath dirName folderName];
% 
% bacteriaTracks = importdata([datafolder 'allBacteriaTracks.mat']);
% 
% dfTrackingFiltered = importdata([datafolder 'tracks3D.mat']);
% % NEED TO CHECK WHICH COLUMN PARTICLE ACTUALLY IS AND REPLACE BELOW


[~,~,gId] = unique(tracks3D(:,5),'rows');
tracks3D = splitapply( @(x){x}, tracks3D, gId);
nTracks = height(tracks3D);
%establish a cell array with the same number of rows as bacteriaTracks
% so that tracks can be assigned whilst keeping cell indices
[nr,~]=size(bacteriaTracks);
trackIDsinCells = cell(nr, 1);


for k=1:nr
    % disp('bac');
    % disp(k);
    currBac = bacteriaTracks{k};
    % disp(currBac);
    currCell = {};
    cell_len = ceil(currBac(1,4)) + 5;
    cell_width = ceil(currBac(1,5)) + 5;
        
    centroid_x = currBac(1,1);
    centroid_y = currBac(1,2);
    theta = currBac(1,3);
    
    [x1,y1] = rotatePoints2((centroid_x-cell_len/2), (centroid_y-cell_width/2), deg2rad(theta), centroid_x, centroid_y);
    [x2,y2] = rotatePoints2((centroid_x-cell_len/2), (centroid_y+cell_width/2), deg2rad(theta), centroid_x, centroid_y);
    [x4,y4] = rotatePoints2((centroid_x+cell_len/2), (centroid_y-cell_width/2), deg2rad(theta), centroid_x, centroid_y);
    [x3,y3] = rotatePoints2((centroid_x+cell_len/2), (centroid_y+cell_width/2), deg2rad(theta), centroid_x, centroid_y);
    boxpoints = vertcat([x1,y1],[x2,y2],[x3,y3],[x4,y4],[x1,y1]);

    for i=1:nTracks
        track = tracks3D{i}; % load up current track
        p_name = track(1,5);
        % disp(p_name);

        TFinList= [];
        for j=1:height(track)
            % work out if particle falls into the box of the cell
            x_firstframe = track(j,2);
            y_firstframe = track(j,3);
            % disp('checking if particle in box');

            % figure;
            % plot(boxpoints(:,1), boxpoints(:,2));
            % hold on
            % plot(x_firstframe,y_firstframe, 'b--o', 'MarkerSize', 10);
            % axis equal;
            % pause(3);
            % close;
            % 
            TFin = inpolygon(x_firstframe, y_firstframe, boxpoints(:,1), boxpoints(:,2));
            TFinList = vertcat(TFinList, TFin);
        end
        
        if any(TFinList) == true
            % disp('particle');
            % disp(p_name);
            currCell = [currCell, p_name];
        
        end

    end

    trackIDsinCells{k,1} = currCell;
end
end