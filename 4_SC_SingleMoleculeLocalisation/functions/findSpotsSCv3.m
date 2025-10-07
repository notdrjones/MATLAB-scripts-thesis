function [processedframe, imageBinary, centroids] = findSpotsSCv3(frame,options)
% A function to find spots using thresholding methods on an image.
% INPUT
% frame : the image you want to find spots on
% disk_radius : size of disk used for morphological operation
% gaussian : apply a gaussian filter? 1 for yes. 0 for no.
% output : useful for debugging. 1 for yes. 0 for no.


% TO DO
% - add image opening 

% subarray_halfwidth,inner_radius,sigma_gauss, error_set, clip_override, show_output
if nargin<2 % you need at least image, x, y
    options.flatfield = 1; % apply flat-field?
    options.nonlocaldenoise = 1; % apply non-local means denoising?

    options.gaussian = 1; % apply gaussian blur?
    options.tophat = 1; % apply tophat transform?

    options.gaussianradius = 2; % px
    options.tophatradius = 20; % px
    options.threshold = 0.1;

    options.output = false;

    % Binary processing
    options.openImage = false;
    options.diskRadius = 2;
    options.applyWatershed = false;

    % Filtering
    options.minIntensity = 20;
    options.maxArea = 2000;
    options.minArea = 20;
    options.nSpots = 5;
end

if ~isfield(options, 'flatfield'), options.flatfield = true; end
if ~isfield(options, 'nonlocaldenoise'), options.nonlocaldenoise = true; end
if ~isfield(options, 'gaussian'), options.gaussian = true; end
if ~isfield(options, 'tophat'), options.tophat = true; end
if ~isfield(options, 'gaussianradius'), options.gaussianradius = 2;end
if ~isfield(options, 'tophatradius'), options.tophatradius = 20;end
if ~isfield(options, 'output'), options.output = false;end

if ~isfield(options, 'minIntensity'), options.minIntensity = 20;end
if ~isfield(options, 'maxArea'), options.maxArea = 2000;end
if ~isfield(options, 'minArea'), options.minArea = 20;end
if ~isfield(options, 'nSpots'), options.nSpots = 5;end

if ~isfield(options, 'openImage'), options.openImage = false;end
if ~isfield(options, 'diskRadius'), options.diskRadius = 2;end

if ~isfield(options, 'applyWatershed'), options.applyWatershed=false; end
if ~isfield(options, 'threshold'), options.threshold = 0.1; end

%frame = mat2gray(frame);
if options.output==1
    originalFrame = figure;
    imshow(frame,[])
    title('original image frame')
    %pause
end

processedframe = frame;

if options.flatfield
    processedframe = imsubtract(frame,imgaussfilt(frame,20));
end

if options.nonlocaldenoise
    processedframe = imnlmfilt(processedframe);
end

if options.tophat
    processedframe = imtophat(processedframe, strel('disk', options.tophatradius)); % get top hat transformed image
end

if options.gaussian
    processedframe=imgaussfilt(processedframe,options.gaussianradius);
    if options.output==1
        gaussianFrame = figure;
        imshow(frame,[])
        title('gaussian filtered image')
        %pause
    end
end

%----- END OF IMAGE PREPARATION -----%

%---- IMAGE THRESHOLDING ----%
%imageBinary = imextendedmax(processedframe,options.threshold);
imageBinary = processedframe>options.threshold;

if options.openImage
    imageBinary = imopen(imageBinary,strel('disk',options.diskRadius));
end

if options.applyWatershed
    % Calculate distance transform
    distanceTransform = bwdist(~imageBinary);
    % Watershed transform
    watershedImage = watershed(distanceTransform,8);
    watershedImage(~imageBinary) = 0; % Set all pixels which are not objects to zero
    % Turn image binary into watershed
    imageBinary = watershedImage;
end

%---- END OF IMAGE THRESHOLDING ----%

%---- START SPOT ANALYSIS ----%
% Use regionprops to find location and filter
spotStats = regionprops(imageBinary,frame,'Area', 'Centroid','PixelValues');

% Filter based on intensity
spotsIntensity = cellfun(@(x) sum(x), {spotStats.PixelValues}); 
index = spotsIntensity>options.minIntensity;
spotStats = spotStats(index);

% Filter based on area
spotsArea = cat(1,spotStats.Area);
indexArea = (spotsArea >= options.minArea & spotsArea <= options.maxArea);
spotStats = spotStats(indexArea);

if length(spotStats)>options.nSpots
    filteredSpotsIntensities = cellfun(@(x) sum(x), {spotStats.PixelValues});
    [~, brightestSpotsIndex] = sort(filteredSpotsIntensities,'descend');
    spotStats = spotStats(brightestSpotsIndex(1:options.nSpots));
end

try
    centroids = cat(1,spotStats(:).Centroid);
catch
    centroids = [NaN NaN];
end

end
