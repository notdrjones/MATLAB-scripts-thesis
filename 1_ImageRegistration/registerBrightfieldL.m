function [movingRegistered] = registerBrightfieldL(stackpath,outputfolder, fixed,flipFlag,tform)
%REGISTER_STACK Summary of this function goes here
% 22/06/2023 - Added memory allocation, 4x speed increase.
% 22/06/2023 - Added "FillValues"=255 so that surrounding registered
% brightifield image does not have black borders but white ones.

stack = loadtiff(stackpath);

if ~exist(outputfolder,'dir')
    mkdir(outputfolder);
end

% Flip images horizontally if necessary, useful specifically for images
% acquired before 05/11/2022
if flipFlag
    stack = flip(stack,2);
end

%-- get folder for output
%outputfolder = [fileparts(stackpath) '/'];

% in the tform creation step you should have used L as the fixed image, if
% not, change the two lines down here
moving = stack;
movingRegistered = stack;

Nframes = size(moving,3);
fprintf("Applying transform... \n")
for i=1:Nframes
    movingRegistered(:,:,i) = imwarp(moving(:,:,i),tform,"OutputView",imref2d(size(fixed)),"FillValues",255);
end

fprintf("Saving images... \n")

options.overwrite = true;
options.message = false;

%saveastiff(uint8(fixed),[outputfolder 'L.tiff'],options);
saveastiff(uint8(movingRegistered), [outputfolder 'brightfield.tiff'],options);
end

