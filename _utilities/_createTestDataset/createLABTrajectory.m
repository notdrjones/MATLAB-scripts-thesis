function [helixTrackLAB,fiducialTrackLAB] = createLABTrajectory(bacteriaTrack,fiducialTrack,helixTrack)
%CREATELABTRAJECTORY Summary of this function goes here
%   Detailed explanation goes here

%-- Check that all three have the same number of timesteps
lengthCheck = isequal(length(bacteriaTrack),length(fiducialTrack),length(helixTrack));

if ~lengthCheck
    error('The three trajectories need to have the same number of datapoints for this script to work.');
end

N = length(bacteriaTrack); % number of timesteps

%-- Apply a rotation in YZ plane
phi = linspace(0,3*pi,N);

for i=1:N
    [fiducialTrack(i,3), fiducialTrack(i,4)] = rotatePoints(fiducialTrack(i,3),fiducialTrack(i,4),phi(i));
    [helixTrack(i,3), helixTrack(i,4)] = rotatePoints(helixTrack(i,3),helixTrack(i,4),phi(i));
end

%-- Pre-allocate space.
helixTrackLAB = helixTrack;
fiducialTrackLAB = fiducialTrack;

% [xRotated, yRotated] = rotatePoints(x,y,theta,varargin)
for i=1:N
    % Start by applying rotation to each timestep, we assume [0,0] is the
    % centre of the bacterium.
    [helixTrackLAB(i,2), helixTrackLAB(i,3)] = rotatePoints(helixTrack(i,2),helixTrack(i,3),bacteriaTrack(i,4));
    [fiducialTrackLAB(i,2), fiducialTrackLAB(i,3)] = rotatePoints(fiducialTrack(i,2),fiducialTrack(i,3),bacteriaTrack(i,4));
end

% Then apply translation
helixTrackLAB(:,2:3) = helixTrackLAB(:,2:3) + bacteriaTrack(:,2:3);
fiducialTrackLAB(:,2:3) = fiducialTrackLAB(:,2:3) + bacteriaTrack(:,2:3);

clf
plot3(fiducialTrackLAB(:,2),fiducialTrackLAB(:,3),fiducialTrackLAB(:,4))
daspect([1 1 1])
hold on
plot3(helixTrackLAB(:,2),helixTrackLAB(:,3),helixTrackLAB(:,4))
end