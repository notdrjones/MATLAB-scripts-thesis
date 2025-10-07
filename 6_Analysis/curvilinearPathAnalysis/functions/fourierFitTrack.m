function [x,yFit] = fourierFitTrack(datafolder)
%FOURIERFITTRACK Summary of this function goes here
%   Detailed explanation goes here
bacteriaTrack = importdata([datafolder 'bacteriaTrack.mat']);
% This is to deal with 10fps tracks. Ideally to be removed.
for i=2:2:size(bacteriaTrack,1)-1
bacteriaTrack(i,2:3) = (bacteriaTrack(i-1,2:3)+bacteriaTrack(i+1,2:3))./2;
end

% Smooth the points
t = bacteriaTrack(:,1);
x = movmean(bacteriaTrack(:,2),10);
y = movmean(bacteriaTrack(:,3),10);

% Get Fourier Fit
clf
hold on
stepSize = 20;

[f2, ~] = fit(x,y,"fourier2");
yFit = feval(f2,x);
plot(x,y);
hold on
plot(x,yFit,'r--');
end

