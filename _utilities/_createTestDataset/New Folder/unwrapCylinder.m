function [outputArg1,outputArg2] = unwrapCylinder(xyzPoints)
%UNWRAPCYLINDER Summary of this function goes here
%   Detailed explanation goes here
x = cylCoords(:,2); y = cylCoords(:,3); z1 = cylCoords(:,1);
[theta,rho,z] = cart2pol(x,y,z1);


end

