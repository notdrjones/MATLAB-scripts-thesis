function [tracks_fixed] = fixTrajLengths(tracks,N)
%FIXTRAJLENGTHS Summary of this function goes here
%   Detailed explanation goes here
nTracks = length(tracks);
tracks_fixed = cell(size(tracks));

for i=1:nTracks
    currentTrack = tracks{i};
    trackLength = length(currentTrack);
    
    T = (1:N)';
    timesteps_available = currentTrack(:,1);

    currentTrack_fixed = NaN(N,3);
    
    for t=1:N
        index = find(timesteps_available==t);
        if ~isempty(index)
            currentTrack_fixed(t,:) = currentTrack(index,:);
        else
            currentTrack_fixed(t,:) = [t NaN NaN];
        end
    end
    
    tracks_fixed{i} = currentTrack_fixed;
end


end

