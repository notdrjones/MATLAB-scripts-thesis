function [trackIDsinCells] = matchTrackswithBacteriaAcrossAllFrames(bacteriaTracks, tracks3D, options)


if nargin<3
    options.save = false;
    options.L = 100;
    options.minTrackLength = 10;
    options.cellpadding = 2;
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
tracks3D = cellfun(@(x) interpolateTrack(x, false), tracks3D, 'UniformOutput',false);
nTracks = height(tracks3D);
%establish a cell array with the same number of rows as bacteriaTracks
% so that tracks can be assigned whilst keeping cell indices
[nr,~]=size(bacteriaTracks);
trackIDsinCells = cell(nr, 1);


for k=1:nr
    % disp('bac');
    % disp(k);
    currBac = bacteriaTracks{k,:};
    % disp(currBac);
    currCell = {};
    %work out mean dimensions of cell and add 5 pixel buffer
    cell_len = nanmean(currBac(:,5)) + options.cellpadding;
    cell_width = nanmean(currBac(:,6)) + options.cellpadding;
    firstbacframe = currBac(1,1);
    % disp('currBac')
    % disp(firstbacframe);
    % disp(length(currBac));
    % disp(currBac);
    for i=1:nTracks
        track = tracks3D{i}; % load up current track
        p_name = track(1,5);
        disp(p_name);
        %get first frame
        %need to check the overlap of the particletrack and bacteriatrack
        firstparticleframe = track(1,1);
        

        %need if statement to avoid errors from tracks that don't overlap
        %with bacteria tracks
        if (firstparticleframe < (height(currBac)+ firstbacframe -1 - options.minTrackLength)) && (firstbacframe < (height(track)+ firstparticleframe - 1- options.minTrackLength))
            if firstparticleframe < firstbacframe
                firstsharedframe = firstbacframe;
            else
                firstsharedframe = firstparticleframe;
            end
            
            if (firstparticleframe + height(track)) < (firstbacframe + height(currBac))
                lastsharedframe = firstparticleframe + height(track) -1;
            else
                lastsharedframe = firstbacframe + height(currBac) -1;
            end
            
            %then crop both tracks such that they overlap entirely
            
            currBac = currBac(currBac(:,1) > firstsharedframe-1,:);
            currBac = currBac(currBac(:,1) < lastsharedframe+1,:);
            track = track(track(:,1) > firstsharedframe-1,:);
            track = track(track(:,1) < lastsharedframe+1,:);
            disp(currBac(:,1));
            disp(track(:,1));

            %get bacteria location in first frame of track
            TFinList= [];
            for j=1:height(currBac)
            
                centroid_x = currBac(j, 2);
                centroid_y = currBac(j, 3);
                theta = currBac(j,4);
                % disp('getting cell angle');
                if isnan(theta)
                    plus = 1;
                    while isnan(theta)
                        theta = currBac(j + plus, 4);
                        plus = plus +1;
                    end
                end
                % disp('making box');
                %make box from cell
                [x1,y1] = rotatePoints2((centroid_x-cell_len/2), (centroid_y-cell_width/2), deg2rad(theta), centroid_x, centroid_y);
                [x2,y2] = rotatePoints2((centroid_x-cell_len/2), (centroid_y+cell_width/2), deg2rad(theta), centroid_x, centroid_y);
                [x4,y4] = rotatePoints2((centroid_x+cell_len/2), (centroid_y-cell_width/2), deg2rad(theta), centroid_x, centroid_y);
                [x3,y3] = rotatePoints2((centroid_x+cell_len/2), (centroid_y+cell_width/2), deg2rad(theta), centroid_x, centroid_y);
                boxpoints = vertcat([x1,y1],[x2,y2],[x3,y3],[x4,y4],[x1,y1]);
    
                disp(currBac(j,1));
                disp(track(j,1));
                disp(j);
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
                
                TFin = inpolygon(x_firstframe, y_firstframe, boxpoints(:,1), boxpoints(:,2));
                TFinList = vertcat(TFinList, TFin);
            end
            if any(TFinList) == true
                disp('particle');
                disp(p_name);
                currCell = [currCell, p_name];
            
            end
        end
    end
    trackIDsinCells{k,1} = currCell;
end
end