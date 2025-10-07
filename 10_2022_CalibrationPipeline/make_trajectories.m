function [allTracks] = make_trajectories(locCell, varargin)
defaultLinkingDistance = 20;
defaultGapClosing = 3;
defaultMinTrackLength = 75;

p = inputParser;
validInput = @(x) isnumeric(x) && (x>0);
addRequired(p,'locCell',@(x) iscell(x));
addOptional(p,'max_linking_distance',defaultLinkingDistance,validInput);
addOptional(p,'max_gap_closing',defaultGapClosing,validInput);
addOptional(p,'minTrackLength', defaultMinTrackLength,validInput);
addOptional(p,'debug',false,@(x) islogical(x));

parse(p,locCell,varargin{:});

max_linking_distance = p.Results.max_linking_distance;
max_gap_closing = p.Results.max_gap_closing;
minTrackLength = p.Results.minTrackLength;
debug = p.Results.debug;

%% --- Build Trajectories
debug = false; % outputs status tracking

[ tracks, adjacency_tracks ] = simpletracker(locCell,...
    'MaxLinkingDistance', max_linking_distance, ...
    'MaxGapClosing', max_gap_closing, ...
    'Debug', debug);

n_tracks = numel(tracks); % how many tracks?

all_points = vertcat(locCell{:}); % converts allSpotLocation to an array from a cell

% Create an array with timepoints, useful for later
allSpotTime = cell(size(locCell));
for t=1:length(locCell)
    allSpotTime{t} = t.*ones(size(locCell{t},1),1);
end
all_timepoints = vertcat(allSpotTime{:});

% Create a cell for all tracks
allTracks = cell(n_tracks,1);
% Now create a cell with all the tracks
for i_track = 1 : n_tracks  
    % We use the adjacency tracks to retrieve the points coordinates. It
    % saves us a loop.
    
    track = adjacency_tracks{i_track};
    track_points = [all_timepoints(track,:) all_points(track, :)];

    % Put a restriction on size tracks
    % For now, the restriction is that you only accept tracks where there
    % is a point for each single frame.
    if size(track_points,1)>=minTrackLength
        allTracks{i_track} = track_points;
    end
end

% Remove empty tracks and get new n_tracks
empty_index = cellfun(@(x) isempty(x), allTracks);
allTracks(empty_index,:) = [];

n_tracks = length(allTracks);
fprintf("Trajectories built (%i) \n", n_tracks)

%% For debug
if debug
    tracksFigure = figure;
    hold on;
    for i_track= 1 : n_tracks
        track_points = allTracks{i_track};

        C = turbo(size(track_points,1));
        scatter(track_points(:,2), track_points(:, 3),2,C,'filled');
        daspect([1 1 1])
    end
end
end