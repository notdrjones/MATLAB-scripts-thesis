function [track3D] = translateTrackInMovingCell(bacteriatrack,particletrack, options)
%function to get trajectories over time relative to cells that are rotating at
%constant helical pitch

%NEED TO INCORPORATE FLIPFLAG IN HERE???

if nargin<3

    options.celldiameter=1; %in um
    options.poleLen=0.25; % in um
    options.pixelsize = 67; %in nm
    options.helicalpitch = 6; %in um/full rotation
end


%get mean cell length and width for use later
cellLen = nanmean(bacteriatrack(:,5));
cellWidth = nanmean(bacteriatrack(:,6));
%normalise all z values to the mean cell width such that in the centre of
%the cell z = 0
minZ = min(particletrack(:,4));
maxZ = max(particletrack(:,4));
middleZ = maxZ - minZ/2;
scaleFactor = cellWidth/(maxZ-minZ);
newZs = particletrack(:,4)*scaleFactor - middleZ*scaleFactor;
array2 = horzcat(particletrack(:,4), newZs);
% disp(array2(1:5,:));
% disp(middleZ);
% disp(scaleFactor);
particletrack(:,4) = newZs;


%need to check the overlap of the particletrack and bacteriatrack
firstparticleframe = particletrack(1,1);
firstbacframe = bacteriatrack(1,1);
if firstparticleframe < firstbacframe
    firstsharedframe = firstbacframe;
else
    firstsharedframe = firstparticleframe;
end

if (firstparticleframe + height(particletrack)) < (firstbacframe + height(bacteriatrack))
    lastsharedframe = firstparticleframe + height(particletrack);
else
    lastsharedframe = firstbacframe + height(bacteriatrack);
end


%then crop both tracks such that they overlap entirely

bacteriatrack = bacteriatrack(bacteriatrack(:,1) > firstsharedframe,:);
bacteriatrack = bacteriatrack(bacteriatrack(:,1) < lastsharedframe,:);
particletrack = particletrack(particletrack(:,1) > firstsharedframe,:);
particletrack = particletrack(particletrack(:,1) < lastsharedframe,:);

%for first frame of track, just translate single localisation relative to
%cell

%establish a cellrot adjustment
totalcellRot = 0; 

%get first localisation
x_3D = particletrack(1,2);
y_3D = particletrack(1,3);
z_3D = particletrack(1,4);
% disp(z_3D);
% disp(particletrack(1,:));
% find centroid of cell from track


x_cent = bacteriatrack(1,2);
y_cent = bacteriatrack(1,3);
theta = bacteriatrack(1,4);

% Now get point in cell frame of reference
x_rel = x_3D - x_cent;
y_rel = y_3D - y_cent;

[xLocRotated, yLocRotated] = rotatePoints(x_rel, y_rel, -deg2rad(theta));

track3D(1,:) = [firstsharedframe xLocRotated yLocRotated z_3D];

T = particletrack(:,1);
%then iterate through the remaining points
for j=2:length(T)
    t = T(j); % the actual frame number
    x_3D = particletrack(j,2);
    y_3D = particletrack(j,3);
    z_3D = particletrack(j,4);
    
    % find centroid of cell from track

    %get centroid location in frame n and n+1

    x_centprev = x_cent;
    y_centprev = y_cent;
    
    track_index = bacteriatrack(:,1)==t;
    x_cent = bacteriatrack(track_index,2);
    y_cent = bacteriatrack(track_index,3);
    theta = bacteriatrack(track_index,4);
    if isnan(theta)
        plus = 1;
        while isnan(theta)
            theta = bacteriatrack(track_index + plus, 4);
            plus = plus +1;
        end
    end
   

    %added in flipflag to stop the poles from 'flipping' - this way the
            %pole considered 'left' remains the same throughout, with large
            %changes in theta causing flipflag to be activated
            
    if j ==2
        if theta <0 
            flipflag  = 1;
        else 
            flipflag = 0;
        end
    else
        if abs(prevtheta - theta) > 90
            if flipflag == 0
                flipflag = 1;
            else
                flipflag = 0;
            end
        end
    end
    prevtheta = theta;
    %get 2D vector of centroid between one frame and the next
    
    v = [(x_cent - x_centprev) (y_cent - y_centprev)];
    % d = norm(v);
    %get projection of vector along angle of the cell to make it more
    %accurate/remove large effects from cell rotation around pole
    u = [cos(deg2rad(theta)), sin(deg2rad(theta))];
    d = dot(v,u);


    cellrot = (d/options.helicalpitch)*2*pi; %in rad
    polelimit = cellLen/2 - options.poleLen;

    
    %translate point in 2D first so that it is relative to a cell with centre
    %(0,0) and long axis horizontal
    x_rel = x_3D - x_cent;
    y_rel = y_3D - y_cent;
    
    if flipflag == 1
        theta = theta + 180;
    end

    [x_rel, y_rel] = rotatePoints(x_rel, y_rel, -deg2rad(theta));


    %then correct all localisations in 3D relative to 
    %if on the cell body, i.e. treat as tube
    if abs(x_rel) < polelimit
        radius = (options.celldiameter)/2;
    %else if close to the pole
    else 
    %function describing relationship between effective radius and distance
    %from cell pole
        radius = sqrt(((options.celldiameter)/2)^2 - (polelimit - cellLen/2 + x_rel)^2);
    end
    %atm not using the calculated radius for the adjustments but might need
    %to in future ... 
    %add cellrot to the overall current cellrot figure
    totalcellRot = totalcellRot + cellrot;
    if totalcellRot > 2*pi
        while totalcellRot > 2*pi
            totalcellRot = totalcellRot - 2*pi;
        end
    end
    %convert y and z to 2D polar coordinates to translate by angle
    [theta, rho] = cart2pol(z_3D,y_rel);
    %because cell rotates in left-handed helix, need to add cellrot
    %to theta (remember y axis is 'inverted' so if we look at yx as though
    %it is xy, angle is increasing
    theta = theta + totalcellRot;
    [z_3D,y_rel] = pol2cart(theta, rho);

        
    %function for translating x y and z according to cell rotation
   
    track3D(j,:) = [t x_rel y_rel z_3D];

end
    

end