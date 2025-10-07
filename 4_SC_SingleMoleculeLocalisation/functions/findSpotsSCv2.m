function [imageBinary, centroids] = findSpotsSCv2(frame,options)
% A function to find spots using thresholding methods on an image.
% INPUT
% frame : the image you want to find spots on
% disk_radius : size of disk used for morphological operation
% gaussian : apply a gaussian filter? 1 for yes. 0 for no.
% output : useful for debugging. 1 for yes. 0 for no.

% subarray_halfwidth,inner_radius,sigma_gauss, error_set, clip_override, show_output
if nargin<2 % you need at least image, x, y
    options.gaussian = 1; % apply gaussian blur?
    options.tophat = 1; % apply tophat transform?
    options.gaussianradius = 2; % px
    options.tophatradius = 20; % px

    options.threshold = 0.1;

    options.output = false;
end

if ~isfield(options, 'gaussian'), options.gaussian = true; end
if ~isfield(options, 'tophat'), options.tophat = true; end

if ~isfield(options, 'gaussianradius'), options.gaussianradius = 2;end
if ~isfield(options, 'tophatradius'), options.tophatradius = 20;end


if ~isfield(options, 'output'), options.output = false;end



frame = mat2gray(frame);
if options.output==1
    originalFrame = figure;
    imshow(frame,[])
    title('original image frame')
    %pause
end

if options.gaussian==1
    frame=imgaussfilt(frame,options.gaussianradius);
    if options.output==1
        gaussianFrame = figure;
        imshow(frame,[])
        title('gaussian filtered image')
        %pause
    end
end

%----- Process to find spots
if options.tophat
    frame = imtophat(frame, strel('disk', options.tophatradius)); % get top hat transformed image
end

imageNormalised = frame./max(frame,[],'all'); % normalise image
imageBinary = imageNormalised>options.threshold; % apply a threshold to get spots

% Use regionprops to find location and filter
spotStats = regionprops(imageBinary,frame,'Area', 'Centroid','PixelValues');

%--> Here you could include an area filter to get rid of spurious spots
spotsIntensity = cellfun(@(x) sum(x), {spotStats.PixelValues}); 

%--> centroid filtering
% only pick spots which have a total intensity higher than 10, in the
% gaussblurred image
index = spotsIntensity>20;
spotStats = spotStats(index);

spotsArea = cat(1,spotStats.Area);
indexArea = (spotsArea >= 50 & spotsArea <= 2000);

spotStats = spotStats(indexArea);

% try
% spotStats = spotStats(index);
% catch
%     a=1;
% end

% if length(stats)>5
%     filteredSpotsIntensities = cellfun(@(x) sum(x), {stats.PixelValues});
%     [~, brightestSpotsIndex] = sort(filteredSpotsIntensities,'descend');
%     stats = stats(brightestSpotsIndex(1:5));
% end

try
centroids = cat(1,spotStats(:).Centroid);
catch
    a=1;
end

end
