function [track3D] = getLocsRelativeToCell(bacteriaTrack, particleTrack)

T = particleTrack(:,1); % frames in which particle was found
    
% this loop maybe can be put in parfor for performance?
% now we loop over each frame the particle was found in
for j=1:length(T)
    t = T(j); % the actual frame number
    x_3D = track(j,2);
    y_3D = track(j,3);
    z_3D = track(j,4);
    
    % find centroid of cell from track


    track_index = bacteriaTrack(:,1)==t;
    x = bacteriaTrack(track_index,2);
    y = bacteriaTrack(track_index,3);
    theta = bacteriaTrack(track_index,4);


    % Now get point in LAB frame of reference
    x_rel = x_3D - x;
    y_rel = y_3D - y;
    
    [xLocRotated, yLocRotated] = rotatePoints(x_rel, y_rel, -deg2rad(theta+90));
    
    try
        track3D(j,:) = [t xLocRotated.*pxsize yLocRotated.*pxsize z_3D];
    catch
        abc = 1;
    end
end

end

