function [af] = fitEllipse2D(xLocs,yLocs,zLocs,a0,lb,ub,plotResults)
%FITELLIPSE2D Summary of this function goes here
%   Detailed explanation goes here
options = optimset('Display','off');
f = @(a) ((yLocs-a(3)).^2)/a(1).^2 + ((zLocs-a(4)).^2)/a(2).^2 -1;
af = lsqnonlin(f, a0, lb, ub, options);

% radiusY, radiusZ, centerY, centerZ


% if plotResults
%     plot3(xLocs,yLocs,zLocs,'*')
%     hold on
%     plot3(mean(xLocs),af(3), af(4), 'r*')
%     t=0:pi/10:2*pi;
%     plot3(mean(xLocs).*ones(size(t)),af(3) + af(1)*cos(t), af(4) + af(2)*sin(t), 'r')
% end

angles = linspace(0,2*pi,100);
yCyl = af(3) + af(1)*cos(angles);
zCyl = af(4) + af(2)*sin(angles);
end

