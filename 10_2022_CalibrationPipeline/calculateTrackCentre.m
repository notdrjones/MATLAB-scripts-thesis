function [track_centres] = calculateTrackCentre(tracks)
n_tracks = length(tracks);

track_centres = zeros(n_tracks, 3);
for i_track=1:n_tracks
    track_points = tracks{i_track};
    track_centres(i_track,:) = mean(track_points);
end
end

