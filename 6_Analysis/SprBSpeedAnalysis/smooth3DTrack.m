function [smoothedTrack] = smooth3DTrack(track,nSmoothing)
%SMOOTH3DTRACK Summary of this function goes here
%   Detailed explanation goes here
smoothedTrack = [track(:,1) movmean(track(:,2),nSmoothing) movmean(track(:,3),nSmoothing) movmean(track(:,4),nSmoothing)];
end

