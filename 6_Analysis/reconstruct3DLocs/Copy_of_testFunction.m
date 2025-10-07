function [outputArg1,outputArg2] = testFunction(datafolder)
%TESTFUNCTION Summary of this function goes here
%   Detailed explanation goes here
% Import bacteriaTrack
bacteriaTrack = importdata([datafolder 'bacteriaTrack.mat']);
theta = bacteriaTrack(:,4);

% Import left denoised, and brightfield images
%-- Load the fluorescence and brightfield stack
brightfieldStack = loadtiff([datafolder 'brightfield_cropped.tif']);

for i=1:size(brightfieldStack,3)
    brightfieldStack(:,:,i) = imgaussfilt(brightfieldStack(:,:,i),2);

    if isnan(theta(i))
        theta(i) = theta(i-1);
    end

    [boundaryXY] = findBacteriaBoundary(brightfieldStack(:,:,i));
    [xRot yRot] = rotatePoints(boundaryXY(:,1),boundaryXY(:,2),deg2rad(theta(i)),101/2,101/2);

    %-- Rotate stacks too
    brightfieldStack(:,:,i) = imrotate(brightfieldStack(:,:,i),-theta(i),"nearest","crop");

    imshow(brightfieldStack(:,:,i));
    hold on
    plot(xRot,yRot,'r.');
    drawnow;
    hold off;
end

end
