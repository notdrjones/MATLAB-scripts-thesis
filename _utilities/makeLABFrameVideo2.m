function makeLABFrameVideo2(datafolder,videoFlag)
%MAKECELLFRAMEVIDEO Summary of this function goes here

%imagefolder = datafolder(1:strfind(datafolder,'\cropped\'));

if videoFlag
    v = VideoWriter([datafolder 'videoLAB.avi']);
    open(v);
end

% Import bacteriaTrack
bacteriaTrack = importdata([datafolder 'bacteriaTrack.mat']);

% Track bounding box
padding = 100;
xmin = min(bacteriaTrack(:,2))-padding;
xmax = max(bacteriaTrack(:,2))+padding;
ymin = min(bacteriaTrack(:,3))-padding;
ymax = max(bacteriaTrack(:,3))+padding;

Lx = (xmax-xmin);
Ly = (ymax-ymin);

cropRectangle = [xmin ymin Lx Ly];

% Import left denoised, and brightfield images
%-- Load the fluorescence and brightfield stack
%brightfieldStack = loadtiff([datafolder 'brightfield_cropped.tif']);
%fluorescenceStack = loadtiff([datafolder 'L_cropped.tif']);
[brightfieldStack,fluorescenceStack] = reconstructLABFrame(datafolder);

for i=1:size(fluorescenceStack,3)
    brightfieldStack(:,:,i) = imgaussfilt(brightfieldStack(:,:,i),2);
    fluorescenceStack(:,:,i) = imgaussfilt(fluorescenceStack(:,:,i),2);

    %-- Crop stacks too
    brightfieldStackC(:,:,i) = imcrop(brightfieldStack(:,:,i),cropRectangle);
    fluorescenceStackC(:,:,i) = imcrop(fluorescenceStack(:,:,i),cropRectangle);
end


%-- Set up the 3 subplots
s1 = subplot(3,1,1);
s2 = subplot(3,1,2);
s3 = subplot(3,1,3);
set(gcf,'Color','white');


%-- And Images
image1 = imshow(brightfieldStackC(:,:,1),[], 'Parent', s1);
image2 = imshow(fluorescenceStackC(:,:,1),[], 'Parent', s2);
image3 = imshow(imfuse(brightfieldStackC(:,:,1),fluorescenceStackC(:,:,1)),[],'Parent',s3);

%-- With titles
title(s1,'Brightfield');
title(s2,'Fluorescence');
title(s3, 'Overlay');

% First frame of the video
if videoFlag
    frame = getframe(gcf);
    writeVideo(v,frame);
end

for i=2:size(brightfieldStackC,3)
    image1.CData = brightfieldStackC(:,:,i);
    image2.CData = fluorescenceStackC(:,:,i);
    image3.CData = imfuse(brightfieldStackC(:,:,i),fluorescenceStackC(:,:,i));

    if videoFlag
        frame = getframe(gcf);
        writeVideo(v,frame);
    end
end

if videoFlag
    close(v);
end


end

