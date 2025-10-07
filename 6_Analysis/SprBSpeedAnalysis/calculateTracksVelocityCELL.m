function [outputArg1,outputArg2] = calculateTracksVelocity(datafolder)
%CALCULATETRACKVELOCITY Summary of this function goes here
%   Detailed explanation goes here

% Load LAB Frame 3D Tracks
allTracks3D = importdata([datafolder 'allTracks3D_CELL.mat']);
bacteriaTrack = importdata([datafolder 'bacteriaTrack.mat']);

for i=2:2:size(bacteriaTrack,1)-1
    bacteriaTrack(i,2:3) = (bacteriaTrack(i-1,2:3)+bacteriaTrack(i+1,2:3))./2;
end

% Convert bacteriaTrack to um from px
pxsize = 0.1;
dt = 0.05;
bacteriaTrack(:,2:3) = bacteriaTrack(:,2:3).*pxsize;
dx = diff(bacteriaTrack(:,2));
dy = diff(bacteriaTrack(:,3));
bacteriaVelocity = sqrt(dx.^2+dy.^2)./dt;
bacteriaVelocityArray = [bacteriaTrack(2:end,1) bacteriaVelocity];

% Calculate 

trackVelocities = cellfun(@(x) calculateSingleTrack3DVelocity(x,0.05),allTracks3D,'UniformOutput',false);

% cellfun(@(x) histogram(x,linspace(0,10,30),'Normalization','probability'), trackVelocities)
trackVelocitiesRelative = cellfun(@(x) calculateVelocityRatio(x,bacteriaVelocityArray),trackVelocities,'UniformOutput',false);
clf
hold on
cellfun(@(x) histogram(x,linspace(0,2,30),'Normalization','probability'), trackVelocitiesRelative)

end

