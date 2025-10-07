function [v, reversalRate] = analyseBacteriaTracks(folderPath, analysisOptions)
%BACTERIATRACKANALYSIS Summary of this function goes here
%   Detailed explanation goes here

% What quantities are we interested in?
% Average velocity
% Path direction to spot reversal
% 

allTracks = importdata([folderPath '\allBacteriaTracks.mat']);

if nargin < 2 % Use default options
    analysisOptions.modifier = 1;
    analysisOptions.pxsize = 1;
    analysisOptions.dt = 1;
    analysisOptions.save = false;
end

if ~isfield(analysisOptions, 'modifier'), analysisOptions.modifier = 1; end
if ~isfield(analysisOptions, 'pxsize'), analysisOptions.pxsize = 1; end
if ~isfield(analysisOptions, 'dt'), analysisOptions.dt = 1; end
if ~isfield(analysisOptions, 'save'), analysisOptions.save = false; end

% Check if modifier is different than 1. This is to deal with stacks where
% it was necessary to duplicate each image to map 10fps to 20fps.

if analysisOptions.modifier ~= 1
    allTracks = cellfun(@(x) x(1:analysisOptions.modifier:end,:), allTracks,'UniformOutput',false);
end

%-- Set dt, px size
dt = analysisOptions.dt;
pxsize = analysisOptions.pxsize;

%-- Convert allTracks to real-life dimensions
allTracks = cellfun(@(x) [x(:,1).*dt x(:,2:3).*pxsize x(:,4:end)],allTracks,'UniformOutput',false);

%-- Calculate average velocity
v = cellfun(@(x) mean(calculateInstantVelocity(x),'omitnan'), allTracks);

%-- Calculate average direction of motion and reversals.

% Start by "smoothing out" the trajectory.
allTracksSmooth = cellfun(@(x) [x(:,1) movmean(x(:,2),10) movmean(x(:,3),10)], allTracks,'UniformOutput',false);

% Use the smooth trajectories to find reversalRate
reversalRate = cellfun(@(x) calculateReversalRate(x), allTracksSmooth);



if analysisOptions.save
    % if data is being saved, create a folder to store the info
    outputfolder = [folderPath '\bacteriaTrackingResults\'];
    mkdir(outputfolder);

    % save output to folder
    save([outputfolder 'reversalRateArray.mat'], 'reversalRate');
    save([outputfolder 'smooothBacteriaTracks.mat'], 'allTracksSmooth');
    save([outputfolder 'averageVelocitiesArray.mat'], 'v');
end
end

