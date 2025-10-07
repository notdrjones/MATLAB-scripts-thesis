function [avgV] = calc_v(x,y,pxsize,dt)
%CALC_V Summary of this function goes here
%   Detailed explanation goes here

x = x.*pxsize;
y = y.*pxsize;

%vx = diff(x)./dt;
%vy = diff(y)./dt;

T = dt.*length(x);
vx = (x(end)-x(1))./T;
vy = (y(end)-y(1))./T;

v = sqrt(vx.^2+vy.^2);

avgV = v;
end

