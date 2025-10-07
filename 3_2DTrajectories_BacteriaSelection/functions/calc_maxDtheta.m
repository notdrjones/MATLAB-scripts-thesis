function [maxDtheta] = calc_maxDtheta(theta)
%CALC_V Summary of this function goes here
%   Detailed explanation goes here

maxDtheta = max(theta) - min(theta);
%always going to be positive so

%failsafe for if angle changes very slightly across y axis
if maxDtheta > 175
    maxDtheta = 180-maxDtheta;
end

end

