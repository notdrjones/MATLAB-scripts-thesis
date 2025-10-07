function [tracksFigure] = plotGradientBacteriaTrajectories2(allTracks)


[n_tracks,~] = size(allTracks);
    tracksFigure = figure;
    hold on;
    for i_track= 1 : n_tracks
        
        track_points = allTracks{i_track, 1};
        % 
        
        firstframe = min(track_points(:,1));
        lastframe = max(track_points(:,1));
        nFrames = lastframe - firstframe +2;
        % C = jet(nFrames);
        % disp(C);
        % cmap = colormap(C((1):(nFrames),:));
        % disp(cmap); 
        clr = hsv(1000);
        gscatter(track_points(:,2), track_points(:, 3), (track_points(:,1)-firstframe+1), clr, "o",[2,2],"filled", 'off');    
        % daspect([1 1 1])
        xlim([0,400]);
        ylim([0,250]);
        
    end
   


end