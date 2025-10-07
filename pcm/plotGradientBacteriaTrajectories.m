function [fNew] = plotGradientBacteriaTrajectories(allTracks)


[n_tracks,~] = size(allTracks);
if n_tracks ~= 0
    tracksFigure = figure;
    hold on;
    for i_track= 1 : n_tracks
        % axstring = append('ax',int2str(i_track));
        subplot(1,n_tracks,i_track);
        track_points = allTracks{i_track, 1};
        % 
        
        firstframe = min(track_points(:,1));
        lastframe = max(track_points(:,1));
        nFrames = lastframe - firstframe +2;
        % C = jet(nFrames);
        % disp(C);
        % cmap = colormap(C((1):(nFrames),:));
        % disp(cmap); 
        z = zeros(size(track_points(:,2)));
        disp(size(z));
        disp(size(track_points(:,1)));
        surface([track_points(:,2).';track_points(:,2).'],[track_points(:, 3).';track_points(:, 3).'],[z.';z.'],[track_points(:,1).';track_points(:,1).'],...
            'facecol','no',...
            'edgecol','interp',...
            'linew',2);
        xlim([0,400]);
        ylim([0,250]);
        % daspect([1 1 1])
    end
    
    if n_tracks > 1
        for i_track= 2 : n_tracks
            % axstring = append('ax',int2str(i_track));
            set(subplot(1,n_tracks,i_track), 'Position', get(subplot(1,n_tracks,1), 'Position'));
            axis(subplot(1,n_tracks,i_track), 'off');
        end
    end
    fNew = figure;
    copyobj(subplot(1,n_tracks,1), fNew);
else 
    fNew = figure;
end


end