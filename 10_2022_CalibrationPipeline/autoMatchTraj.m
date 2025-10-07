function [index_matching] = autoMatchTraj(pointsA, pointsB,searchRadius)
%MATCH_CLOSEST Summary of this function goes here
%   Detailed explanation goes here

% The goal is to match each point in A, with the closest point in B.
% Points should be in the form [t1 x1 y1; t2 x2 y2; ... ; xN yN]
num_pointsA = size(pointsA,1);
index_matching = zeros(num_pointsA,1); % The index of pointsB closest to each pointA

for i=1:num_pointsA
    distance = sqrt((pointsA(i,2)-pointsB(:,2)).^2+(pointsA(i,3)-pointsB(:,3)).^2);
    [minDistance, minIndex] = min(distance);
    if minDistance < searchRadius
        index_matching(i) = minIndex;
    else
        index_matching(i) = nan;
    end
end
end

