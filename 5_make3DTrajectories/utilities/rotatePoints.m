function [xRotated, yRotated] = rotatePoints(x,y,theta,varargin)
%ROTATEPOINTS Summary of this function goes here
%this function takes points x and y and rotates them anticlockwise theta
%radians 
% Apply rotation matrix

% assume that if there are more inputs, the inputs are xC and yC i.e. the
% rotation centre
if ~isempty(varargin)
    xC = varargin{1};
    yC = varargin{2};
else
    xC = 0;
    yC = 0;
end

% translate x and y to the rotation centre
xTransl = x - xC;        
yTransl = y - yC;

% apply rotation to the translated points
xRot = xTransl.*cos(theta)-yTransl.*sin(theta);
yRot = xTransl.*sin(theta)+yTransl.*cos(theta);

% now apply translation to bring points back to original frame of
% reference.
xRotated = xRot + xC;
yRotated = yRot + yC;
end

