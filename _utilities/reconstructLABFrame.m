function [reconstructedBrightfield,reconstructedFluorescence] = reconstructLABFrame(croppedfolder)
%RECONSTRUCTLABFRAME
% This function takes as inputs
% croppedfolder - the path to one of the folders containg the cropped
% videos
%
% originalL - the original size of the square containing the FOV in px

% -- load brightfield
brightfieldStack = loadtiff([croppedfolder 'brightfield_cropped.tif']);
fluorescenceStack = loadtiff([croppedfolder 'L_cropped.tif']);

%-- bacteria track
track = importdata([croppedfolder 'bacteriaTrack.mat']);
x = track(:,2);
y = track(:,3);

reconstructedBrightfield = zeros(1000,1000,size(brightfieldStack,3))+225;
reconstructedFluorescence = zeros(1000,1000,size(brightfieldStack,3))+mean(fluorescenceStack(:));

% loop through all the frames to crop them one by one, potentially made
% faster by using parfor but for short videos it's not really worth it/can
% actually lead to worse performance

for i=1:size(brightfieldStack,3)
    colsIm = (round(x(i))-100)+(1:101);
    rowsIm = (round(y(i))-100)+(1:101);
    reconstructedBrightfield(rowsIm,colsIm,i) = brightfieldStack(:,:,i);    
    reconstructedFluorescence(rowsIm,colsIm,i) = fluorescenceStack(:,:,i);    
end
end

