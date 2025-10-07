function [bgCorrectedStack] = applyBackgroundSubtraction(stack,method,bgColor)
%BACKGROUNDSUBTRACTION Summary of this function goes here
%   Detailed explanation goes here

% Assumes you pass through a stack with dimensions X x Y x T

if strcmp(bgColor,'light')
    stack = imcomplement(stack);
elseif strcmp(bgColor,'dark')
else
    error("bgColor should be either 'light' or 'dark'");
end


if strcmp(method,'median')
    bgImage = median(stack,3);
elseif strcmp(method,'mean')
    bgImage = mean(stack,3);
elseif strcmp(method,'min')
    bgImage = min(stack,[],3);
else
    error("Please type 'median','mean' or 'min' as a method.")
end

%--- Background Subtraction
bgCorrectedStack = stack - uint8(bgImage);

% Now may need to re-invert the image to give us values similar to what we
% originally had.
if strcmp(bgColor,'light')
    bgCorrectedStack = imcomplement(bgCorrectedStack);
end
end

