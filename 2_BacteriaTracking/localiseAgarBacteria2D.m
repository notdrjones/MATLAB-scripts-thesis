function [finalBacLocs] = localiseAgarBacteria2D(bacLoc, stackFolder, options)
%TRACKING_FROM_MICROBEJ Summary of this function goes here
%   Detailed explanation goes here
% Find what frames have bacteria
%

[folderName, dirName, mainDataFolderPath, dataOutPath] = getFileNames(stackFolder);
outputPath = [dataOutPath dirName folderName];
%% Init options parameter    
if nargin < 3 % Use default options
    options.modifier = 'none';
    options.pxsize = 1;
    options.dt = 1;
    options.maxDisp = 10;
    options.maxDtheta = 5;
    options.save = true;

    options.max_linking_distance = 20; % this is always in px
    options.minTrackLength = 20; % always in frames
    options.max_gap_closing = 6; % frames
    options.maxRotExcl = 90; % frames
    options.maxLenVar = 3; %relative
    options.interpolateTheta = true;
else

    % if any parameter is not included in the option structure, change it to
    % the default value
    if ~isfield(options, 'modifier'), options.modifier = 'none'; end
    if ~isfield(options, 'minSLV'), options.minSLV = 0; end
    if ~isfield(options, 'pxsize'), options.pxsize = 1; end
    if ~isfield(options, 'dt'), options.dt = 1; end
    if ~isfield(options, 'save'), options.save = false; end
    if ~isfield(options, 'outputpath'), options.outputpath = [dataOutPath dirName folderName]; end
    
    % tracking params
    if ~isfield(options, 'max_linking_distance'), options.max_linking_distance = 20; end
    if ~isfield(options, 'minTrackLength'), options.minTrackLength = 5; end
    if ~isfield(options, 'max_gap_closing'), options.max_gap_closing = 6; end
end

% 
% bacLoc = bacLoc(:,1);
% 
% %-- Check if any cell is empty, if they are just set it to [NaN NaN NaN
% %NaN], this prevents the code from breaking at a later stage.
% emptyCellIndex = cellfun(@(x) isempty(x), bacLoc);
% 
% bacLoc(emptyCellIndex) = {nan(1,4)};

% Build the trajectories
[allTracks] = make_trajectories_from_SCdata(bacLoc,'max_linking_distance', options.max_linking_distance,'minTrackLength', options.minTrackLength,'max_gap_closing', options.max_gap_closing, 'maxRot', options.maxRotExcl, 'maxLenVar', options.maxLenVar);


fprintf("All Bacteria (%i)\n", length(allTracks));

% Calculate total displacement of bacteria at each time point to remove
% bacteria that travel too far
maxDisps = cellfun(@(x) calc_maxdisp(x(:,2),x(:,3)), allTracks);

filter_index = maxDisps<=options.maxDisp;
allTracks = allTracks(filter_index);

fprintf("All Bacteria (%i)\n", length(allTracks));
% repeat again for bacteria that change angle too much
maxDeltaThetas = cellfun(@(x) calc_maxDtheta(x(:,4)), allTracks);


filter_index = maxDeltaThetas<=options.maxDtheta;
allTracks = allTracks(filter_index);


fprintf("All Bacteria (%i)\n", length(allTracks));
% calculate the average of all the localisations after removing the 'odd'
% frames with unusual lengths and widths (more than 20% above or below average)
bacLocs = cellfun(@(x) getRefinedBacLoc(x), allTracks,'UniformOutput',false);

%to prevent overlapping cells, take the first instance of any cell and
%remove all later ones that overlap
finalBacLocs = {};
for i=1:height(bacLocs)
    currBac = bacLocs{i};
    centroid_x = currBac(1,1);
    centroid_y = currBac(1,2);
    theta = currBac(1,3);
    cell_len = currBac(1,4);
    cell_width = currBac(1,5);
    [x1,y1] = rotatePoints2((centroid_x-cell_len/2), (centroid_y-cell_width/2), -deg2rad(theta), centroid_x, centroid_y);
    [x2,y2] = rotatePoints2((centroid_x-cell_len/2), (centroid_y+cell_width/2), -deg2rad(theta), centroid_x, centroid_y);
    [x4,y4] = rotatePoints2((centroid_x+cell_len/2), (centroid_y-cell_width/2), -deg2rad(theta), centroid_x, centroid_y);
    [x3,y3] = rotatePoints2((centroid_x+cell_len/2), (centroid_y+cell_width/2), -deg2rad(theta), centroid_x, centroid_y);
    boxpoints = vertcat([x1,y1],[x2,y2],[x3,y3],[x4,y4],[x1,y1]);
    poly1 = polyshape(boxpoints(:,1), boxpoints(:,2));
    area1 = polyarea(boxpoints(:,1), boxpoints(:,2));
    check = 0;
    for j=1:(i-1)
        currBac = bacLocs{j};
        centroid_x = currBac(1,1);
        centroid_y = currBac(1,2);
        theta = currBac(1,3);
        cell_len = currBac(1,4);
        cell_width = currBac(1,5);
        [x1,y1] = rotatePoints2((centroid_x-cell_len/2), (centroid_y-cell_width/2), -deg2rad(theta), centroid_x, centroid_y);
        [x2,y2] = rotatePoints2((centroid_x-cell_len/2), (centroid_y+cell_width/2), -deg2rad(theta), centroid_x, centroid_y);
        [x4,y4] = rotatePoints2((centroid_x+cell_len/2), (centroid_y-cell_width/2), -deg2rad(theta), centroid_x, centroid_y);
        [x3,y3] = rotatePoints2((centroid_x+cell_len/2), (centroid_y+cell_width/2), -deg2rad(theta), centroid_x, centroid_y);
        boxpoints = vertcat([x1,y1],[x2,y2],[x3,y3],[x4,y4],[x1,y1]);
        poly2 = polyshape(boxpoints(:,1), boxpoints(:,2));
        polyout = intersect(poly1, poly2);
        area2 = polyarea(boxpoints(:,1), boxpoints(:,2));
        if area1 > area2
            area = area2;
        else
            area = area1;
        end
        theyintersect = polyout.NumRegions>(area/8);
        if theyintersect == 1
            check = 1;
        end
    end
    if check ==0
        finalBacLocs = [finalBacLocs; bacLocs{i}];
    end
end
fprintf("Bacteria filtered (%i)\n", length(finalBacLocs));
%invert theta to account for y flipping
finalBacLocs = cellfun(@(x) inverttheta(x,3), finalBacLocs,'UniformOutput',false);

if options.save
    % Need to save tracks and options
    %options.nFrames = nFrames;
    save([outputPath 'refinedBacLoc.mat'], 'finalBacLocs');
    fprintf("Data saved to (%s)\n", outputPath);
end
end

