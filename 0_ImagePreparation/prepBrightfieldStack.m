function processedStack = prepBrightfieldStack(stack,options)
%BRIGHTFIELDPREP Summary of this function goes here
%   Detailed explanation goes here
tic

if nargin<2 % you need at least 4
    options.binning = 1; % if not specificied, there's no binning
    options.bgSubtract = 1; % if not specified, no background subtraction

    options.cropField = [0 0 5496 3672];

end

if ~isfield(options, 'binning'), options.binning = 1; end
if ~isfield(options, 'bgSubtract'), options.bgSubtract=0; end


N = size(stack,3);

binningValue = options.binning;
parfor i=1:N
    % Read the image
    currFrame = uint8(stack(:,:,i));

    currFrame = imcrop(currFrame, options.cropField);

    currFrame = imgaussfilt(currFrame,2);

    currFrame = imbandpass(currFrame, 5, 20);

    if options.bgSubtract == false
        currFrame = bkgrdSubtractSingleFrame(currFrame, 99, 10);
        currFrame = imgaussfilt(currFrame,5);
    % else
    %     currFrame = currFrame./imgaussfilt(currFrame,20);
    end

    % Apply binning if necessary
    if binningValue>1
        currFrame = imresize(currFrame,1./binningValue,'bilinear');
    end
    
    % currFrame = uint8(rescale(currFrame,0,255));
    
    %-- place the frame inside the stack
    processedStack(:,:,i) = currFrame;
    
end

% Check if user has requested a background subraction
if options.bgSubtract == true
    fprintf("Calculating background... ");
    processedStack = applyBackgroundSubtraction(processedStack,'mean','light');
    fprintf("Done. \n")
end


toc
end