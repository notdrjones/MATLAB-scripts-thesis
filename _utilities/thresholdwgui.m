function [highThreshold] = thresholdwgui(img)


subplot(2, 3, 1);
imshow(img, []);
axis off;

% Set up figure properties.
set(gcf, 'Name', 'Thresholding Demo by ImageAnalyst', 'NumberTitle', 'off') 
set(gcf, 'Toolbar', 'none', 'Menu', 'none');
set(gcf, 'Position', get(0,'Screensize')); % Enlarge figure to full screen.

startingLowThreshold = 0;
startingHighThreshold = 255;

imageToThreshold = img;



%====================== KEY PART RIGHT HERE!!!! ===================================================
% Threshold with starting range startingLowThreshold to startingHighThreshold.
[lowThreshold, highThreshold] = threshold(startingLowThreshold, startingHighThreshold, imageToThreshold);
%====================== KEY PART RIGHT HERE!!!! ===================================================


