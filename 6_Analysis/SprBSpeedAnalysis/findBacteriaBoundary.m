function [boundaryXY] = findBacteriaBoundary(frame)
%FINDBACTERIABOUNDARY Summary of this function goes here
%   Detailed explanation goes here

thresholdedFrame = frame<100;
edgeFrame = edge(thresholdedFrame);
boundaries = bwboundaries(edgeFrame);

boundaryXY = flip(boundaries{1},2);
end

