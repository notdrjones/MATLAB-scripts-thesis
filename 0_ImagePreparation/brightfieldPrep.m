function brightfieldPrep(imagefolder,N,outputfolder,fileprefix,options)
%BRIGHTFIELDPREP Summary of this function goes here
% nb have hard coded out the save after this function to avoid overwriting
% the raw split stacks
%   Detailed explanation goes here
tic

if nargin<5 % you need at least 4
    options.doubleStack = false;
    options.binning = 1; % if not specificied, there's no binning
    options.bgSubtract = 0; % if not specified, no background subtraction

end

if ~isfield(options,'doubleStack'), options.doubleStack = true; end
if ~isfield(options, 'binning'), options.binning = 1; end
if ~isfield(options, 'bgSubtract'), options.bgSubtract=0; end

if ~exist(outputfolder, 'dir')
    mkdir(outputfolder);
end

stack = zeros(1000,1000,N); % This ideally would not be hardcoded, but a function input

binningValue = options.binning;
parfor i=1:N
    % Read the image
    currFrame = imread([imagefolder fileprefix num2str(i-1) '.tiff']);
    
    % Apply binning if necessary
    currFrame = imresize(currFrame,1./binningValue,'bilinear');

    %-- apply tophat and then gaussblur
    currFrame = imcomplement(imtophat(imcomplement(currFrame), strel('disk',30))); % Here I'm using imcomplement twice because MATLAB's imtophat works with objects being bright, and background dark, my images are opposite, but I want the output to be consistent with the input
    currFrame = imgaussfilt(currFrame, 3);

    %-- place the frame inside the stack
    stack(:,:,i) = currFrame;
end

%-- Make sure stack is a uint8 image
stack = uint8(stack);


% Check if user has requested a background subraction
if options.bgSubtract
    fprintf("Calculating background... ");
    stack = applyBackgroundSubtraction(stack,'min','light');
    fprintf("Done. \n")
end

%-- now double the stack 
if options.doubleStack
    stack2 = uint8(zeros(1000,1000,N*2));
    stack2(:,:,1:2:end) = stack(:,:,:);
    stack2(:,:,2:2:end) = stack(:,:,:);
else
    stack2 = stack;
end
%stack2 = uint8(stack2);
% saveoptions.message = false;
% saveastiff(uint8(stack2), [outputfolder 'brightfield_stack.tif'],saveoptions);
toc
end