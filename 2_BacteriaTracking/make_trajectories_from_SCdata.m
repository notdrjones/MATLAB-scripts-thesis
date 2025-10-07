function [allTracks] = make_trajectories_from_SCdata(locCell, varargin)
% First convert the locCell to make it suitable for use in the tracking
% software
nFrames = height(locCell);
locCell = locCell(~cellfun('isempty',locCell));
locCell_points = cellfun(@(x) x(:,2:3), locCell,'UniformOutput',false);

defaultLinkingDistance = 20;
defaultGapClosing = 3;
defaultMinTrackLength = 75;
defaultmaxRot = 90;
defaultmaxLenVar = 3;

p = inputParser;
validInput = @(x) isnumeric(x) && (x>0);
addRequired(p,'locCell',@(x) iscell(x));
addOptional(p,'max_linking_distance',defaultLinkingDistance,validInput);
addOptional(p,'max_gap_closing',defaultGapClosing,validInput);
addOptional(p,'minTrackLength', defaultMinTrackLength,validInput);
%the max amount a cell can rotate between adjacent frames before the
%trajectory is cut off
addOptional(p,'maxRot', defaultmaxRot,validInput);
%the max amount a cell can change in size from median before the
%trajectory is cut off
addOptional(p,'maxLenVar', defaultmaxLenVar,validInput);

parse(p,locCell,varargin{:});

max_linking_distance = p.Results.max_linking_distance;
max_gap_closing = p.Results.max_gap_closing;
minTrackLength = p.Results.minTrackLength;
maxRot = p.Results.maxRot;
maxLenVar = p.Results.maxLenVar;

%% --- Build Trajectories
debug = false; % outputs status tracking

[ tracks, adjacency_tracks ] = simpletracker(locCell_points,...
    'MaxLinkingDistance', max_linking_distance, ...
    'MaxGapClosing', max_gap_closing, ...
    'Debug', debug);

n_tracks = numel(tracks); % how many tracks?

all_points = vertcat(locCell{:}); % converts allSpotLocation to an array from a cell

% Create a cell for all tracks, increasing allowance for tracks that get
% split up
allTracks = cell(1,1);
% Now create a cell with all the tracks
for i_track = 1 : n_tracks  
    % We use the adjacency tracks to retrieve the points coordinates. It
    % saves us a loop.
    
    track = adjacency_tracks{i_track};
    track_points = all_points(track, :);
    
    % Put a restriction on size tracks
    % For now, the restriction is that you only accept tracks where there
    % is a point for each single frame.
    if size(track_points,1)>=minTrackLength
        [thetachanges] = getChangesinCellAngle(track_points);
        check1 = thetachanges > maxRot;
        check2 = thetachanges < 180-maxRot;
        check3 = check1 + check2;
        check4 = check3 > 1;

        [sizechanges] = getChangesinCellLen(track_points);
        check5 = sizechanges > maxLenVar;
        
        if any(check4) || any(check5)
            [goodruns] = findrunsofzeros(check1, check2, minTrackLength);
            for j =1:height(goodruns)
                runstart = goodruns(j,1);
                runend = goodruns(j,2);
                new_track_points = track_points(runstart:runend,:);
                allTracks= [allTracks; new_track_points]; 
            end
        else
           allTracks= [allTracks; track_points]; 
        end
    end

end
%remove first line bc it will be empty
allTracks(1,:) = [];
% Remove empty tracks and get new n_tracks
empty_index = cellfun(@(x) isempty(x), allTracks);
allTracks(empty_index,:) = [];

n_tracks = length(allTracks);
fprintf("Trajectories built (%i) \n", n_tracks)

%% For debug
% tracksFigure = figure;
% hold on;
% 
% for i_track= 1 : n_tracks
%     track_points = allTracks{i_track};
%     % 
%     % firstframe = min(track_points(:,1));
%     % lastframe = max(track_points(:,1));
%     % C = jet(nFrames);
%     % disp(C);
%     % cmap = colormap(C((firstframe):(lastframe),:));
%     % disp(cmap);
%     clr = hsv(nFrames);
%     gscatter(track_points(:,2), track_points(:, 3), track_points(:,1), clr, 'filled', siz = [0.1,0.1]);    
%     daspect([1 1 1])
% end
end