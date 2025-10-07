function [allUnrolledPoints] = fitCylinderTo3DLocsAndUnroll(xyzPoints, plotResults)
%FITCYLINDERTO3DLOCS Summary of this function goes here
%   Detailed explanation goes here

T = xyzPoints(:,1);
xyzPoints = xyzPoints(:,2:end-1);

% The data has already been rotated, so localisations should make up cell
% shape as a bacterium with it's long axis parallel to x-axis

% Localisations in YZ-plane should make a circle, or an ellipse

idxNan = isnan(xyzPoints(:,3));
xyzPoints(idxNan,:) = [];


% To avoid effect from endcaps, we discard
% localisations on the edge of
% bacterium
xMin = min(xyzPoints(:,1));
xMax = max(xyzPoints(:,1));

indexAllowedPoints = (xyzPoints(:,1)>xMin+0.1) & (xyzPoints(:,1)<xMax-0.1);

% Get filtered yLocs and zLocs
xLocs = xyzPoints(:,1);
yLocs = xyzPoints(:,2);
zLocs = xyzPoints(:,3);

%T = (1:length(xLocs))';

% Check how long cylinder is, divide in 2.5um sections (for now)
xEdges = min(xLocs):100:max(xLocs); % 1.25

% xEdges(1)=min(xLocs);
% % Need to ensure last edge is actually max(xLocs)
 xEdges(end) = max(xLocs);
% 
xBinCentres = (xEdges(1:end-1)+xEdges(2:end))./2;
% xBinCentres = mean(xEdges);
% 
[~, ~, xBins] = histcounts(xLocs,xEdges);
% 
maxBin = max(xBins);
% 
% xBins = ones(size(xLocs));
% maxBin =1;

scatter3(xLocs,yLocs,zLocs,10,xBins,'filled');
figure

% Now unroll points 
allUnrolledPoints = [];

%figure
%hold on

% [Ry Rz yC zC]
a0 = [(max(yLocs)-min(yLocs))./2 (max(zLocs)-min(zLocs))./2 mean(yLocs) mean(zLocs)]; % Initial guess for ellipse parameters
ub = [(max(yLocs)-min(yLocs))./2 (max(zLocs)-min(zLocs))./2 mean(yLocs)+0.1 mean(zLocs)+0.1];
lb = [ub(1)-1 ub(2)-1 mean(yLocs)-0.1 mean(zLocs)-0.1];

for i=1:maxBin
    [af] = fitEllipse2D(xLocs(xBins==i),yLocs(xBins==i),zLocs(xBins==i),a0,lb,ub,plotResults);
    %af = [1 1 0 0];
    %af = [0.2204    0.1921    7.2034   -0.7944];
    % Generate a reference ellipsoid at bin centre
    angles = (linspace(-pi,pi,2000))';
    
    yRef = af(3) + af(1)*sin(angles);
    zRef = af(4) + af(2)*cos(angles);
    xRef = ones(size(yRef)).*xBinCentres(i);

    fprintf("%f \n", (af(1)./af(2)))
    xyzPointsUnrolled = unwrapCircle([xLocs(xBins==i,:) yLocs(xBins==i,:) zLocs(xBins==i,:)], [xRef yRef zRef],T(xBins==i));

    allUnrolledPoints = [allUnrolledPoints; xyzPointsUnrolled ones(size(xyzPointsUnrolled)).*i];
end

figure;
subplot(2,1,1)
scatter3(xLocs,yLocs,zLocs,10,T,'filled')
daspect([1 1 1])

subplot(2,1,2)
% scatter((allUnrolledPoints(:,1)),(allUnrolledPoints(:,2)),10,allUnrolledPoints(:,3),'filled');
scatter((allUnrolledPoints(:,1)),(allUnrolledPoints(:,2)),10,allUnrolledPoints(:,3),'filled');
daspect([1 1 1])
end

