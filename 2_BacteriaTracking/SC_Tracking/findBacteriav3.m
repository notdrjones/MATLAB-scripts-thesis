function [centroids,theta,majorAxisLens,minorAxisLens] = findBacteriav3(frame,options)
%TRACKBACTERIAFROMMASK Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
    options.doShapeAnalysis = false;
    options.threshold = 200;
    
    options.maxArea = 5000; %px2
    options.minArea = 300; %px2

    options.maxMajorAxis = 130;
    options.minMajorAxis = 30;
    options.maxMinorAxis = 40;
    options.minMinorAxis = 1;
end

if ~isfield(options,'doShapeAnalysis'), options.doShapeAnalysis = false; end
if ~isfield(options, 'threshold'), options.threshold = 230; end

if ~isfield(options, 'maxArea'), options.maxArea = 5000; end
if ~isfield(options, 'minArea'), options.minArea = 300; end

if ~isfield(options, 'maxMajorAxis'), options.maxMajorAxis = 130; end
if ~isfield(options, 'minMajorAxis'), options.minMajorAxis = 30; end
if ~isfield(options, 'maxMinorAxis'), options.maxMinorAxis = 40; end
if ~isfield(options, 'minMinorAxis'), options.minMinorAxis = 1; end

frame(frame==0) = 255; % This is to deal with black borders added by registration process.


% frame = imgaussfilt(frame,3);
frame = uint8(rescale(frame,0,255));
% 
% figure;
% imshow(frame);

% thresholding
% 
disp(options.threshold);
BW = frame<options.threshold;

%or threshold using interactive gui
% 
% threshold = thresholdwgui(frame);
% disp(threshold);
% BW = frame<threshold;
% 
% figure;
% imshow(BW);
% pause(5);

%binarize image
frameBinary = imbinarize(bwareaopen(BW,options.minArea)-bwareaopen(BW,options.maxArea)); 

% get regionprops of binary image
stats = regionprops(frameBinary,'Centroid','MajorAxisLength', 'MinorAxisLength','Orientation', 'PixelIdxList');

% filter by minor and major axis length
index = cat(1,stats.MajorAxisLength) < options.maxMajorAxis;
stats = stats(index);

index = cat(1,stats.MajorAxisLength) > options.minMajorAxis;
stats = stats(index);

index = cat(1,stats.MinorAxisLength) < options.maxMinorAxis;
stats = stats(index);

index = cat(1,stats.MinorAxisLength) > options.minMinorAxis;
stats = stats(index);

%-- Store values in output variables

centroids = cat(1,stats.Centroid);
% disp('centroids:');
% disp(centroids);
theta = cat(1,stats.Orientation);
majorAxisLens = cat(1,stats.MajorAxisLength);
minorAxisLens = cat(1,stats.MinorAxisLength);

%-- for each cell found, get the medial axis and recalculate center
nBac = length(stats); % number of found bacteria

medialAx = cell(nBac,1);
boundaries = cell(nBac,1);
angles = zeros(nBac,1);

if options.doShapeAnalysis
    %-- DEBUG
    % imshowpair(frameBinary,frame);
    %hold on
    %plot(centroids(:,1), centroids(:,2),'r+')
    
    %-- Add a dilation to cell shape
    frameBinary = imdilate(frameBinary, strel('disk',5));
    
    parfor i=1:nBac
        % get pixel list
        pxlist = stats(i).PixelIdxList;
    
        % create an image with only the object of interest
        singleCellFrame = false(size(frameBinary));
        singleCellFrame(pxlist) = true;
    
        %--- MEDIAL AXIS - Useful for angle measurements
        % this creates a skeleton image keep branches of length 30px or more.
        cellSkel = bwskel(singleCellFrame,'MinBranchLength',30);
        imshow(cellSkel);
        [ySkelUnordered, xSkelUnordered] = find(cellSkel);
        
        % xB and yB are often not in an ordered array, this can cause problems
        % use bwtraceboundary to fix that
        try
        orderedSkel = bwtraceboundary(cellSkel,[ySkelUnordered(1) xSkelUnordered(1)],'N');
        % plot(orderedSkel(:,2),orderedSkel(:,1),'g','LineWidth',2);
        catch
            continue;
        end
    
        xSkel = orderedSkel(:,2); 
        ySkel = orderedSkel(:,1);
    
        xSkelSmooth = smooth(xSkel);
        ySkelSmooth = smooth(ySkel);
        
        medialAx{i} = [xSkelSmooth ySkelSmooth];
        %centroids(i,:) = [xC yC];
       
        %plot(xB,yB,'r-','LineWidth',1);
        %plot(xSkelSmooth,ySkelSmooth,'b-','LineWidth',1);
        %plot(xC,yC, 'r+', 'LineWidth',2);
    
        %-- CELL SHAPE
        [boundaryCell, ~] = bwboundaries(singleCellFrame,'noholes');
        xBoundary = boundaryCell{1}(:,2);
        yBoundary = boundaryCell{1}(:,1);
    
        xBoundarySmooth = smooth(xBoundary);
        yBoundarySmooth = smooth(yBoundary);
    
        boundaries{i} = [xBoundarySmooth yBoundarySmooth];
        %-- Find the angle of the cell
        xSkelCentred = xSkelSmooth-centroids(i,1); 
        ySkelCentred = ySkelSmooth-centroids(i,2);
    
        skelFit = polyfit(xSkelCentred,ySkelCentred,1);
        
        cellAngle = atan(skelFit(1)); % range atan is [-pi/2 pi/2]
        
        if cellAngle<0
            cellAngle = cellAngle+pi; % so that range is now [0 pi]
        end
        
        angles(i) = cellAngle;


    end
end

% head(centroids);

% % --- DEBUG PLOT
% if ~isempty(centroids)
% imshow(frame, []);
% hold on
% plot(centroids(:,1),centroids(:,2),'r+');
% cellfun(@(x) plot(x(:,1),x(:,2),'b-','LineWidth',2),boundaries)
% cellfun(@(x) plot(x(:,1),x(:,2),'r-','LineWidth',2),medialAx)
% hold off
% drawnow
% end

% plot(centroids(:,1),centroids(:,2),'w+','LineWidth',2);
end

