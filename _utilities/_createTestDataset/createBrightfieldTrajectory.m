function bacteriaTrack = createBrightfieldTrajectory(N)
%CREATEBRIGHTFIELDTRAJECTORY Summary of this function goes here
% A simple utility to create the equivalent of a bacLoc file, i.e. a
% brightfield trajectory. 

% v.0 - only a simple diagonal line.

v = 1; % um/s
t = (0:N-1)'.*0.05;

x = t.*v;
y = t.*v;


scatter(x,y,10,t,'filled')

% T X Y THETA

theta = atan2(diff(y),diff(x));
theta(end+1) = theta(end);

bacteriaTrack = [t x y theta];
end

