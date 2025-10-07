function makeCELLFrameVideo(datafolder,videoFlag)
%MAKECELLFRAMEVIDEO Summary of this function goes here

if videoFlag
    v = VideoWriter([datafolder 'videoCELL.avi']);
    open(v);
end

% Import bacteriaTrack
bacteriaTrack = importdata([datafolder 'bacteriaTrack.mat']);
theta = bacteriaTrack(:,4);

% Import left denoised, and brightfield images
%-- Load the fluorescence and brightfield stack
brightfieldStack = loadtiff([datafolder 'brightfield_cropped.tif']);
fluorescenceStack = loadtiff([datafolder 'L_cropped.tif']);

for i=1:size(fluorescenceStack,3)
    brightfieldStack(:,:,i) = imgaussfilt(brightfieldStack(:,:,i),2);
    fluorescenceStack(:,:,i) = imgaussfilt(fluorescenceStack(:,:,i),2);

    if isnan(theta(i))
        theta(i) = theta(i-1);
    end

    %-- Rotate stacks too
    brightfieldStack(:,:,i) = imrotate(brightfieldStack(:,:,i),-theta(i),"nearest","crop");
    fluorescenceStack(:,:,i) = imrotate(fluorescenceStack(:,:,i),-theta(i),"nearest","crop");
end


%-- Set up the 3 subplots
s1 = subplot(3,1,1);
s2 = subplot(3,1,2);
s3 = subplot(3,1,3);
set(gcf,'Color','white');


%-- And Images
image1 = imshow(brightfieldStack(30:70,20:85,1),[], 'Parent', s1);
image2 = imshow(fluorescenceStack(30:70,20:85,1),[], 'Parent', s2);
image3 = imshow(imfuse(brightfieldStack(30:70,20:85,1),fluorescenceStack(30:70,20:85,1)),[],'Parent',s3);

%-- With titles
title(s1,'Brightfield (rotated)');
title(s2,'Fluorescence (rotated)');
title(s3, 'Overlay (rotated)');

% First frame of the video
if videoFlag
    frame = getframe(gcf);
    writeVideo(v,frame);
end

for i=2:length(theta)
    image1.CData = brightfieldStack(30:70,20:85,i);
    image2.CData = fluorescenceStack(30:70,20:85,i);
    image3.CData = imfuse(brightfieldStack(30:70,20:85,i),fluorescenceStack(30:70,20:85,i));

    if videoFlag
        frame = getframe(gcf);
        writeVideo(v,frame);
    end
end

if videoFlag
    close(v);
end


end

