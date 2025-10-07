function [rotImg] = rotateimage(img, theta)

Rdefault = imref2d(size(img)); % The default coordinate system used by imrotate
tX = mean(Rdefault.XWorldLimits);
tY = mean(Rdefault.YWorldLimits);
tTranslationToCenterAtOrigin = [1 0 0; 0 1 0; -tX -tY,1];
tRotation = [cosd(theta) -sind(theta) 0; sind(theta) cosd(theta) 0; 0 0 1];
tTranslationBackToOriginalCenter = [1 0 0; 0 1 0; tX tY,1];
tformCenteredRotation = tTranslationToCenterAtOrigin*tRotation*tTranslationBackToOriginalCenter;
tformCenteredRotation = affine2d(tformCenteredRotation);
rotImg = imwarp(img,tformCenteredRotation, 'linear');

end