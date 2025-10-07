function fixedTrack = fixTrackEmptyFrames(track)
%FIXTRACKEMPTYFRAMES Summary of this function goes here
%   Detailed explanation goes here

% Assumes first three columns are [T X Y .. ..]
% and T is in FRAME N, not TIME

startFrame = track(1,1); endFrame = track(end,1);
allFrames = startFrame:endFrame;

% The "fixed" track should have one point per frame
fixedTrack = zeros(length(allFrames),size(track,2)); % we make sure we allocate all columns for track

% now loop over all frames
index = 1;
for frame = startFrame:endFrame
    % check if there is a datapoint for the frame index
    checkFrame = track(:,1) == frame;
    
    flag = all(~checkFrame); % this will be 1 if there is no match, 0 if there is a match

    if ~flag % a match has been found
        fixedTrack(index,:) = track(checkFrame,:);
    else % no match has been found
        fixedTrack(index,1) = frame;
        try
        fixedTrack(index,2:end) = nan;
        catch
            a=1;
        end
    end
    index = index+1;
end
end

