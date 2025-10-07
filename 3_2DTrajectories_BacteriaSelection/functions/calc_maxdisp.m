function [maxdisp] = calc_maxdisp(x,y)
%CALC_V Summary of this function goes here
%   Detailed explanation goes here

vx = (x(:)-x(1));
vy = (y(:)-y(1));

disps = sqrt(vx.^2+vy.^2);

maxdisp = max(disps);

end

