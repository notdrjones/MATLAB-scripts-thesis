function [imageBinary, centroids] = findSpotsSC(frame,gaussian,thresholdValue, output)
% A function to find spots using thresholding methods on an image.
% INPUT
% frame : the image you want to find spots on
% disk_radius : size of disk used for morphological operation
% gaussian : apply a gaussian filter? 1 for yes. 0 for no.
% output : useful for debugging. 1 for yes. 0 for no.

frame = mat2gray(frame);
originalframe = frame;
if output==1
    originalFrame = figure;
    imshow(frame,[])
    title('original image frame')
    %pause
end

if gaussian==1
    frame=imgaussfilt(frame,3);
    if output==1
        gaussianFrame = figure;
        imshow(frame,[])
        title('gaussian filtered image')
        %pause
    end
end

%----- Process to find spots
disk_radius = 20;
imageTopHat = imtophat(frame, strel('disk', disk_radius)); % get top hat transformed image

%-- Now need to threshold the image to find maxima
pxAverage = mean(imageTopHat(:)); % The average of all the pixel values
pxStd = std(imageTopHat(:)); % The standard deviation of all pixel values

% We assume brightest spots will be the ones who are on the tail end of the
% pixel histogram

hMaximaThreshold = pxAverage+2*pxStd; % Threshold for h-maxima transform (essentially what pixel values we want to keep)

imageBinary = imextendedmax(imageTopHat,hMaximaThreshold);


%imageNormalised = frame./max(frame,[],'all'); % normalise image
%imageBinary = imageNormalised>thresholdValue; % apply a threshold to get spots

% Use regionprops to find location and filter
spotStats = regionprops(imageBinary,frame,'Area', 'Centroid','PixelValues');

%--> Here you could include an area filter to get rid of spurious spots
spotsIntensity = cellfun(@(x) sum(x), {spotStats.PixelValues}); 

%--> centroid filtering
% only pick spots which have a total intensity higher than 10, in the
% gaussblurred image
index = spotsIntensity>10;
spotStats = spotStats(index);

spotsArea = cat(1,spotStats.Area);
indexArea = (spotsArea >= 20 & spotsArea <= 500);

spotStats = spotStats(indexArea);

% We know that these are videos with single cells, there really should be
% no more than 5 fluorophores detected. If that happens, just keep the best
% 5. 
if length(spotStats)>5
    filteredSpotsIntensities = cellfun(@(x) sum(x), {spotStats.PixelValues});
    [~, brightestSpotsIndex] = sort(filteredSpotsIntensities,'descend');
    spotStats = spotStats(brightestSpotsIndex(1:5));
end

try
centroids = cat(1,spotStats(:).Centroid);
catch
    a=1;
end

end
