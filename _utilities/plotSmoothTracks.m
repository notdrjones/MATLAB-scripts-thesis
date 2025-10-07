function [x,y,z] = plotSmoothTracks(txyzPoints,smoothingWindow)
%PLOTSMOOTHTRACKS Summary of this function goes here
%   Detailed explanation goes here

txyzPointsSmoothed = movmean(txyzPoints,smoothingWindow,1);

t = txyzPointsSmoothed(:,1);
x = txyzPointsSmoothed(:,2);
y = txyzPointsSmoothed(:,3);
z = txyzPointsSmoothed(:,4);

plot3(x.*0.1,y*0.1,z,'-');
end

