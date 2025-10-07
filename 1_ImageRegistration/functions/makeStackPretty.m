function [prettyStack] = makeStackPretty(stack)
%MAKESTACKPRETY Summary of this function goes here
%   Detailed explanation goes here

N = size(stack,3);

prettyStack = stack;

% Start with difference of gaussians
for i=1:N
    frame = uint16(stack(:,:,i));
    frameBlurred = imgaussfilt(frame,20);

    frameDoG = imsubtract(frame,frameBlurred);
    %denoisedFrame = imnlmfilt(frameDoG);

    prettyStack(:,:,i) = frameDoG;
end
%saveastiff(prettyStack,'test.tiff')
end
