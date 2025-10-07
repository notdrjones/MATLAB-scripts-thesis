function [outputArg1,outputArg2] = findProgressAlongCurve(x,y,xC,yC)
%FINDCLOSESTPOINTTOCURVE Summary of this function goes here
%   Detailed explanation goes here

% Calculate arclength and seglen
[arclen,seglen] = calculateArclength(xC,yC);
seglen = [0; seglen];

% Now for each point, find closest point along arclength
nPoints = size(x,1);

% Initialise array
pointProgress = zeros(size(x));
for i=1:nPoints
    xCurrent = x(i);
    yCurrent = y(i);

    distanceArray = sqrt((xCurrent-xC).^2+(yCurrent-yC).^2);
    [~, idxMin] = min(distanceArray);

    % idxMin is the closest point on the curve to the sprb
    pointProgress(i) = seglen(idxMin);   
end
end

