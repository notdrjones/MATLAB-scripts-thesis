function [xR,yR,zR] = rotatePoints3D(xyzPoints,ax,theta,varargin)
%ROTATEPOINTS3D Summary of this function goes here
%   Detailed explanation goes here
x = xyzPoints(:,1);
y = xyzPoints(:,2);
z = xyzPoints(:,3);


% Calculate rotation matrix
if ax==1 % rotation about x-axis
    rotationMatrix = [1    0             0;
                      0 cos(theta) -sin(theta);
                      0 sin(theta) cos(theta)];
elseif ax==2 % rotation about y-axis
        rotationMatrix = [cos(theta) 0 sin(theta);
                          0 1 0;
                          -sin(theta) 0 cos(theta)];
elseif ax ==3 % rotation about z-axis
        rotationMatrix = [cos(theta) -sin(theta) 0
            sin(theta) cos(theta) 0
            0 0 1];
end

% Now calculate cross product between rotationMatrix and each element of
% x,y, z

xyzPointsRotated = zeros(size(xyzPoints));

for i=1:size(xyzPoints,1)
    pointVector = [x(i) y(i) z(i)]';

    rotatedPointVector = rotationMatrix*pointVector;
    xyzPointsRotated(i,:) = rotatedPointVector';
end


xR = xyzPointsRotated(:,1);
yR = xyzPointsRotated(:,2);
zR = xyzPointsRotated(:,3);
end

