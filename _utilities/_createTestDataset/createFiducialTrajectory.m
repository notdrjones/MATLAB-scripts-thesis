function [tracks3D] = createFiducialTrajectory(N)
%CREATEFIDUCIALTRAJECTORY Summary of this function goes here
% A simple code to create a trajectory belonging to a fiducial marker, which represents the output
% after the trajectories have been corrected for cell angle and
% orientation. Can also be used as the starting point to create a "fake"
% dataset to test the various analysis functions.

% To start, let's assume the fiducial just does a simple circle in YZ at
% the middle of our bacterium (i.e. coordinates 0,0)

% Noise parameters
maxNoise = 0.2;
minNoise = -maxNoise;

t = linspace(0,5*3.14,N);
t = t';

x = zeros(N,1) + (minNoise-maxNoise).*rand(N,1);
y = zeros(N,1) + (minNoise-maxNoise).*rand(N,1);
z = 1+zeros(N,1) + (minNoise-maxNoise).*rand(N,1);

plot3(x,y,z)

tracks3D = [t x y z];
end