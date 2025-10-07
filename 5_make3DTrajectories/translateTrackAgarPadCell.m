function [track3D] = translateTrackAgarPadCell(bacteriaLoc,particletrack, options)
%function to get trajectories over time relative to cells that are rotating at
%constant helical pitch

%NEED TO INCORPORATE FLIPFLAG IN HERE???

if nargin<3

    options.celldiameter=1; %in um
    options.poleLen=0.25; % in um
    options.pixelsize = 67; %in nm

end


%get mean cell length and width for use later
cellLen = bacteriaLoc(1,4);
cellWidth = bacteriaLoc(1,5);

x_cent = bacteriaLoc(1,1);
y_cent = bacteriaLoc(1,2);
theta = bacteriaLoc(1,3);

T = particletrack(:,1);
track3D = zeros(length(T),4);
%then iterate through the remaining points
for j=1:size(particletrack,1)
    t = T(j); % the actual frame number
    % disp(j);
    x_3D = particletrack(j,2);
    y_3D = particletrack(j,3);
    z_3D = particletrack(j,4);
    
        
    % Now get point in cell frame of reference
    x_rel = x_3D - x_cent;
    y_rel = y_3D - y_cent;
    
    [xLocRotated, yLocRotated] = rotatePoints(x_rel, y_rel, -deg2rad(theta));

    
    %function for translating x y and z according to cell rotation
   
    track3D(j,:) = [t xLocRotated yLocRotated z_3D];

end
    

end