function [outputArg1,outputArg2] = createHorizontalGlidingCell(datafolder,saveflag)
%CREATEHORIZONTALGLIDINGCELL Summary of this function goes here
%   Detailed explanation goes here
%MAKECELLFRAMEVIDEO Summary of this function goes here

if nargin<2
    videoFlag=false;
end

% if videoFlag
%     v = VideoWriter([datafolder 'videoCELL.avi']);
%     open(v);
% end

% Import bacteriaTrack
bacteriaTrack = importdata([datafolder 'bacteriaTrack.mat']);
theta = bacteriaTrack(:,4);
[thetaNew,thetaNewUnwrapped] = fixThetaWrapping(theta);
theta = thetaNew;

for i=2:2:size(bacteriaTrack,1)-1
    bacteriaTrack(i,2:3) = (bacteriaTrack(i-1,2:3)+bacteriaTrack(i+1,2:3))./2;
end

x = bacteriaTrack(:,2);
y = bacteriaTrack(:,3);

xRotatedAndTranslated = x;
yRotatedAndTranslated = y;

xRotatedAndTranslated(1) = 0;
yRotatedAndTranslated(1) = 0;

% Find angle of movement
angleMovement = atan2(diff(y),diff(x));

for i=2:size(x,1)
    currentx = x(i)-x(i-1);
    currenty = y(i)-y(i-1);

    [xR, yR] = rotatePoints(currentx,currenty,-angleMovement(i-1));%,xRotatedAndTranslated(i-1),yRotatedAndTranslated(i-1));

    if abs(angleMovement(i-1))>pi/2 % This means the step was backwards in x
        xRotatedAndTranslated(i) = -xR+xRotatedAndTranslated(i-1);
        yRotatedAndTranslated(i) = yR+yRotatedAndTranslated(i-1);
    else
        xRotatedAndTranslated(i) = xR+xRotatedAndTranslated(i-1);
        yRotatedAndTranslated(i) = yR+yRotatedAndTranslated(i-1);
    end

end


%----
% % Import left denoised, and brightfield images
% %-- Load the fluorescence and brightfield stack
brightfieldStack = loadtiff([datafolder 'brightfield_cropped.tif']);
fluorescenceStack = loadtiff([datafolder 'L_cropped.tif']);

meanFluo = mean(fluorescenceStack(:));
meanBright = mean(brightfieldStack(:));

brightfieldRotatedAndTranslated = uint8(zeros(size(brightfieldStack,1),max(50+(1:101)+round(xRotatedAndTranslated(end))),size(brightfieldStack,3)))+meanBright;
fluorescenceRotatedAndTranslated = brightfieldRotatedAndTranslated-mean(brightfieldStack(:))+meanFluo;

newBacteriaTrack = [bacteriaTrack(:,1) xRotatedAndTranslated+(100.5) yRotatedAndTranslated+(50.5)];
for i=1:size(brightfieldStack,3)
    brightfieldStack(:,:,i) = imgaussfilt(brightfieldStack(:,:,i),2);
    %fluorescenceStack(:,:,i) = imgaussfilt(fluorescenceStack(:,:,i),2);

    if isnan(theta(i))
        theta(i) = theta(i-1);
    end

    %-- Rotate stacks too
    brightfieldStack(:,:,i) = imrotateFill(brightfieldStack(:,:,i),-theta(i),meanBright);
    fluorescenceStack(:,:,i) = imrotateFill(fluorescenceStack(:,:,i),-theta(i),meanFluo);

%    brightfieldStack(:,:,i) = imrotate(brightfieldStack(:,:,i),-theta(i),"nearest","crop");
%    fluorescenceStack(:,:,i) = imrotate(fluorescenceStack(:,:,i),-theta(i),"nearest","crop");
try
    brightfieldRotatedAndTranslated(1:101,50+(1:101)+ceil(xRotatedAndTranslated(i)),i) = brightfieldStack(:,:,i);
    fluorescenceRotatedAndTranslated(1:101,50+(1:101)+ceil(xRotatedAndTranslated(i)),i) = fluorescenceStack(:,:,i);
catch
    a =1;
end
    % imshowpair(brightfieldRotatedAndTranslated(:,:,i),fluorescenceRotatedAndTranslated(:,:,i));
    % drawnow;
end
% 


% idxBright = brightfieldRotatedAndTranslated(:) == 0;
% brightfieldRotatedAndTranslated(idxBright) = meanBright;
% 
% idxFluo = fluorescenceRotatedAndTranslated(:) == 0;
% fluorescenceRotatedAndTranslated(idxFluo) = meanFluo;
% 



if saveflag
    savefolder = [datafolder 'translatedAndRotated\'];
    if ~exist(savefolder,"dir")
        mkdir(savefolder);
    end

    saveastiff(brightfieldRotatedAndTranslated,[savefolder 'brightfieldRotatedAndTranslated.tif']);
    saveastiff(fluorescenceRotatedAndTranslated,[savefolder 'fluorescenceRotatedAndTranslated.tif']);
    save([savefolder 'bacteriaTrackHorizontal.mat'],'newBacteriaTrack');
end

%
%
% %-- Set up the 3 subplots
% s1 = subplot(3,1,1);
% s2 = subplot(3,1,2);
% s3 = subplot(3,1,3);
% set(gcf,'Color','white');
%
%
% %-- And Images
% image1 = imshow(brightfieldStack(30:70,20:85,1),[], 'Parent', s1);
% image2 = imshow(fluorescenceStack(30:70,20:85,1),[], 'Parent', s2);
% image3 = imshow(imfuse(brightfieldStack(30:70,20:85,1),fluorescenceStack(30:70,20:85,1)),[],'Parent',s3);
%
% %-- With titles
% title(s1,'Brightfield (rotated)');
% title(s2,'Fluorescence (rotated)');
% title(s3, 'Overlay (rotated)');
%
% % First frame of the video
% if videoFlag
%     frame = getframe(gcf);
%     writeVideo(v,frame);
% end
%
% for i=2:length(theta)
%     image1.CData = brightfieldStack(30:70,20:85,i);
%     image2.CData = fluorescenceStack(30:70,20:85,i);
%     image3.CData = imfuse(brightfieldStack(30:70,20:85,i),fluorescenceStack(30:70,20:85,i));
%
%     if videoFlag
%         frame = getframe(gcf);
%         writeVideo(v,frame);
%     end
% end
%
% if videoFlag
%     close(v);
% end

end

function [rotatedImage] = imrotateSC(image,theta,fillValue)
    rotatedImage = imrotate(image,theta,"nearest","crop");

    % Find mask rotated image
    rotatedImageMask = ~rotatedImage;
    rotatedImageMask = bwareaopen(rotatedImageMask,250);

    rotatedImage(rotatedImageMask) = fillValue;
end

function rotated_image = imrotateFill(image, rot_angle_degree,fillValue)
    RA = imref2d(size(image));    
    tform = affine2d([cosd(rot_angle_degree)    -sind(rot_angle_degree)     0; ...
                      sind(rot_angle_degree)     cosd(rot_angle_degree)     0; ...
                      0                          0                          1]);
      Rout = images.spatialref.internal.applyGeometricTransformToSpatialRef(RA,tform);
      Rout.ImageSize = RA.ImageSize;
      xTrans = mean(Rout.XWorldLimits) - mean(RA.XWorldLimits);
      yTrans = mean(Rout.YWorldLimits) - mean(RA.YWorldLimits);
      Rout.XWorldLimits = RA.XWorldLimits+xTrans;
      Rout.YWorldLimits = RA.YWorldLimits+yTrans;
      rotated_image = imwarp(image, tform, 'OutputView', Rout, 'interp', 'cubic', 'fillvalues', fillValue);
  end
