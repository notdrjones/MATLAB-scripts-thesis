function [tracks3D] = createHelixTrajectory(N)
%CREATEHELIXTRAJECTORY 
% A simple code to create a helix trajectory, which represents the output
% after the trajectories have been corrected for cell angle and
% orientation. Can also be used as the starting point to create a "fake"
% dataset to test the various analysis functions.

% TO DO
% - allow users to create multiple trajectories
% - allow users to add noise
% - allow users 

maxNoise = 0.2;
minNoise = -maxNoise;

maxNoise = 0.;
minNoise = 0.;

%t = (0:0.2:5*3.14)';
%N = length(t);
t = linspace(0,20*3.14,N);
t = t';

x = (t-max(t./2)) + (minNoise-maxNoise).*rand(N,1);
y = cos(t/2) + (minNoise-maxNoise).*rand(N,1);  
z = sin(t/2) + (minNoise-maxNoise).*rand(N,1);


plot3(x,y,z)

tracks3D = [t x y z];
end

