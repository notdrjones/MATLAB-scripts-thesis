function [allTracks] = trackBacteria2D_pcm(bacLoc, options)
%TRACKING_FROM_MICROBEJ Summary of this function goes here
%   Detailed explanation goes here
% Find what frames have bacteria
%

%% Init options parameter    
if nargin < 3 % Use default options
    options.modifier = 'none';
    options.pxsize = 1;
    options.dt = 1;
    options.minDisp = 40;
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
    if ~isfield(options, 'minDisp'), options.minSLV = 0; end
    if ~isfield(options, 'pxsize'), options.pxsize = 1; end
    if ~isfield(options, 'dt'), options.dt = 1; end
    if ~isfield(options, 'save'), options.save = false; end
    if ~isfield(options, 'outputpath'), options.outputpath = [dataOutPath dirName folderName]; end
    
    % tracking params
    if ~isfield(options, 'max_linking_distance'), options.max_linking_distance = 20; end
    if ~isfield(options, 'minTrackLength'), options.minTrackLength = 20; end
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

% Calculate SLV (straight-line-velocity) for each track
maxDisps = cellfun(@(x) calc_maxdisp(x(:,2),x(:,3)), allTracks);

filter_index = maxDisps>=options.minDisp;
allTracks = allTracks(filter_index);



% Fix the tracks
allTracks = cellfun(@(x) fixTrackEmptyFrames(x), allTracks,'UniformOutput',false);

% Interpolate tracks to get rid of NaN values where necessary
allTracks = cellfun(@(x) interpolateTrack(x, options.interpolateTheta), allTracks, 'UniformOutput',false);

fprintf("Trajectories filtered (%i)\n", length(allTracks));

end

