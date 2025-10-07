function [x_matched, y_matched, matched] = autoMatchPoint(point, pointsB,searchRadius)
%MATCH_CLOSEST Summary of this function goes here
%   Detailed explanation goes here

% The goal is to match a point, with the closest point in B.
% Points should be in the form [x1 y1;x2 y2; ... ; xN yN]
try
distance = sqrt((point(1,1)-pointsB(:,1)).^2+(point(1,2)-pointsB(:,2)).^2);
[minDistance, minIndex] = min(distance);
if minDistance < searchRadius
    x_matched = pointsB(minIndex,1);
    y_matched = pointsB(minIndex,2);
    matched = true;
else
    x_matched = NaN;
    y_matched = NaN;
    matched = false;
end
catch
    problem=1;
end
end


