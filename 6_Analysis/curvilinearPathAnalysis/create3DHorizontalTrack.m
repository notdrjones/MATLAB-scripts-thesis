function [outputArg1,outputArg2] = create3DHorizontalTrack(datafolder,saveFlag)
%CREATE3DHORIZONTALTRACK Summary of this function goes here
%   Detailed explanation goes here

%% -- Import bacteriaTrack, create horizontal Track
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

newBacteriaTrack = [bacteriaTrack(:,1) xRotatedAndTranslated+(100.5) yRotatedAndTranslated+(50.5)];

%% -- Import 3D Localisations in cropped image frame
localisationsCroppedFrame = importdata([datafolder 'localisations3D_CROPPED.mat']);

%% -- Translate and rotate points
localisationsHorizontalFrame = localisationsCroppedFrame;

L = 101;
nFrames = size(newBacteriaTrack,1);

for i=1:nFrames
    % For each frame, if there is a point apply rotation and translation
    currentData = localisationsCroppedFrame{i};

    if ~isempty(currentData)
        % rotate points
        [xRotated, yRotated] = rotatePoints(currentData(:,2),currentData(:,3),deg2rad(theta(i)),L/2,L/2);

        currentData = [xRotated-L/2+newBacteriaTrack(i,2) yRotated-L/2+newBacteriaTrack(i,3) currentData(:,4)];
    end

    % Then add to cell array
    localisationsHorizontalFrame{i} = currentData;
end

%% -- Build tracks
maxLinkingDistance = 10;
minTrackLength = 20;
maxGapClosing = 5;

% Make trajectories using left channel - each cell in "allTracks" has an
% array of N points with columns [T X Y]
[allTracks] = make_trajectories(localisationsHorizontalFrame,'max_linking_distance', maxLinkingDistance,'minTrackLength', minTrackLength, 'max_gap_closing', maxGapClosing,'debug',false);


%% -- Output!
save([datafolder 'translatedAndRotated\bacteriaTrackHorizontal.mat'],"newBacteriaTrack");
save([datafolder 'translatedAndRotated\SprBHorizontalTrack.mat'],"allTracks");
end

