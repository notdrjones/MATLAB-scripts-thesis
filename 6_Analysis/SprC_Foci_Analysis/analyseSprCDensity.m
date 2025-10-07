function [outputArg1,outputArg2] = analyseSprCDensity(croppedFolderDirectory)
%ANALYSESPRCDENSITY Summary of this function goes here
%   Detailed explanation goes here

% -- load brightfield
brightfieldIm = loadtiff([croppedFolderDirectory 'brightfield_cropped.tif']);

%-- load left fluorescence image. For foci we only use the one.
leftIm = loadtiff([croppedFolderDirectory 'L_cropped.tif']);

%-- load bacteria track, and split in t x y theta arrays.
track = importdata([croppedFolderDirectory 'bacteriaTrack.mat']);

t = track(:,1);
x = track(:,2);
y = track(:,3);
%theta = track(:,4); % so that rotation is correct

timepoints = length(t); % Number of points in the bacteria track array.


cols = parula(timepoints);

for i=1:t
    %-- Find cell medial axis and borders
    brightfieldFrame = brightfieldIm(:,:,i);
    frameBinary = brightfieldFrame<250;
    frameBinary = imdilate(frameBinary, strel('disk',5));

    [boundaryCell, ~] = bwboundaries(frameBinary,'noholes');
    % we expect only one boundary to be found - that of the bacteria.
    xBoundary = boundaryCell{1}(:,2);
    yBoundary = boundaryCell{1}(:,1);

    xBoundarySmooth = smooth(xBoundary);
    yBoundarySmooth = smooth(yBoundary);

    % -- Rotate both brightfield and left images
    theta = track(i,4); % get angle from track.
    
    % angle may be NaN if the bacteria was not tracked in that frame, but
    % trajectories got stitched together.
    I = 1;
    while isnan(theta) % Go backwards in trajectory until there's an appropriate angle to be used.
        theta = track(i-I,4);
        I = I +1;
    end

    rotatedBrightfield = imrotate(brightfieldIm(:,:,i),-theta,'bilinear','crop');
    rotatedFluorescence = imrotate(leftIm(:,:,i),-theta,'bilinear','crop');

    [xBoundaryRotated, yBoundaryRotated] = rotatePoints(xBoundarySmooth,yBoundarySmooth,deg2rad(theta),size(brightfieldFrame,1)/2,size(brightfieldFrame,1)/2);
    
    % Create a further cropped out image.
    % This image has a size big enough just to contain xBoundaryRotated and
    % yBoundaryRotated.

    xMin = ceil(min(xBoundaryRotated)-5);
    xMax = ceil(max(xBoundaryRotated)+5);
    
    yMin = ceil(min(yBoundaryRotated)-5);
    yMax = ceil(max(yBoundaryRotated)+5);

   imshow(imgaussfilt(rotatedFluorescence(yMin:yMax,xMin:xMax),3))


    subplot(2,1,1);
    imshowpair(rotatedBrightfield,imgaussfilt(rotatedFluorescence,3));
    hold on
    plot(xBoundaryRotated,yBoundaryRotated,'r-','LineWidth',2);
    subplot(2,1,2);



end

end

