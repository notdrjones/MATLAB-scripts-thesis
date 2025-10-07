function [bacLoc] = findBacteriaStackv3(stackfilename,saveflag,options)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
    options.cropField = [0 0 5496 3672];
    options.dotransform = true;
    options.rotationangle = 0;
    options.translation = [-12 12];

    options.doShapeAnalysis = false;
    options.distfromedge = 10;
    options.threshold = 200;
    
    options.maxArea = 5000; %px2
    options.minArea = 500; %px2

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

fprintf("Loading brightfield stack..")
stack = loadtiff(stackfilename);
stack = stack(:,:,1:50);
nFrames = size(stack,3);
disp(nFrames);

fprintf("Prepping brightfield stack..")
stack = prepBrightfieldStack(stack, options);

newstack = zeros(size(stack));
bacLoc = cell(nFrames,1);


C = jet(nFrames);

% imshow(stack(:,:,1),[]);
tic
   fprintf("Finding Bacteria..")
parfor t=1:nFrames
    % figure;
    % imshow(stack(:,:,t),[]);
    
    [centroids,theta,majorAxisLens,minorAxisLens] = findBacteriav3(stack(:,:,t),options);
    
    % imshow(imadjust(stack(:,:,t)));
    % hold on
    % %scatter(centroids(:,1),centroids(:,2),10,C(t,:),'filled');
    % %plot(centroids(:,1),centroids(:,2),'bo','MarkerFaceColor','b');
    % %cellfun(@(x) plot())
    % % cellfun(@(x) plot(x(:,1), x(:,2), 'b-', 'LineWidth', 2), boundaries)
    % % scatter(centroids(:,1), centroids(:,2),15, 'red','filled')
    % hold off
    % drawnow;

    % realt = nFrames +1 - t;
    T = ones(size(theta)).*t;
    
    bacLoc{t,1} = [T centroids theta majorAxisLens minorAxisLens];
    
    % bacLoc{t,2} = medialAx;
    % bacLoc{t,3} = boundaries;
    %majorAxisLens minorAxisLens

    close all;
end
toc

outputname = strrep(stackfilename, 'brightfield.tif', 'bacLoc.mat');
save(outputname, 'bacLoc');

% saveastiff(newstack, [stackfilename(1:end-15) 'bfprocessed.tif']);

end

