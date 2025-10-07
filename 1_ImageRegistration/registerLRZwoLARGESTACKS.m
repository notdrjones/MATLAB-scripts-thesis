function [fixed, movingRegistered] = registerLRZwoLARGESTACKS(stackfolder, outputfolder, tform)
%REGISTER_STACK Summary of this function goes here

% If total image size is >4GB, MM saves stack in two separate stacks.
% stackfolder will therefore contain two files with .ome.tif

stackfiles = dir([stackfolder '*.ome.tif']);

stack = combinelargestacks(stackfiles);

%stack = loadtiff(stackpath);

if ~exist(outputfolder,'dir')
    mkdir(outputfolder);
end
%-- get folder for output
%outputfolder = [fileparts(stackpath) '/'];

imageWidth = size(stack,2);

% L is the first half
L = stack(:,1:imageWidth/2,:);
R = stack(:,imageWidth/2:end,:);

% in the tform creation step you should have used L as the fixed image, if
% not, change the two lines down here
fixed = L;
moving = R;
movingRegistered = zeros(size(fixed)); % Allocate memory

Nframes = size(moving,3);
fprintf("Applying transform... \n")
for i=1:Nframes
    movingRegistered(:,:,i) = imwarp(moving(:,:,i),tform,"OutputView",imref2d(size(fixed)),"interp","nearest");
end

fprintf("Saving images... \n")

options.overwrite = true;
options.message = false;

if isequal(class(fixed),'uint8')
    movingRegistered = uint8(movingRegistered);
else
    movingRegistered = uint16(movingRegistered);
end

%-- Flat-field the stacks.
%fixed = makeStackPretty(fixed);
%movingRegistered = makeStackPretty(movingRegistered);

%-- Save.
saveastiff((fixed),[outputfolder 'L.tiff'],options);
saveastiff((movingRegistered), [outputfolder 'R.tiff'],options);
end

