function skipped = plotProgressOverTimeV2(datafolder,saveflag)
%PLOTPROGRESSOVERTIME Summary of this function goes here
%   Detailed explanation goes here
if nargin<2
    saveflag = false;
end

datafolder = [datafolder 'translatedAndRotated\'];
dt = 0.05;
pxsize = 0.11;

bacteriaTrack = importdata([datafolder 'bacteriaTrackHorizontal.mat']);
edgeTrack = importdata([datafolder 'bacteriaEdgesTrack.mat']);
sprBTrack = importdata([datafolder 'SprBHorizontalTrack.mat']);

f = figure('WindowStyle','normal','Units','inches', 'Position', [1 1 5 5]);

% Plot shaded area
x = bacteriaTrack(:,1).*dt;
yUpper = edgeTrack(:,end).*pxsize;
yLower = edgeTrack(:,2).*pxsize;

bacteriaLength = yUpper-yLower;
L = bacteriaLength(1)./pxsize;
%idxWrongLengths = abs(bacteriaLength-mean(bacteriaLength)) > std(bacteriaLength);

%L = mean(bacteriaLength);
%yUpper(idxWrongLengths) = (bacteriaTrack(idxWrongLengths,2)).*pxsize+L/2;
%yLower(idxWrongLengths) = (bacteriaTrack(idxWrongLengths,2)).*pxsize-L/2;

yUpper = (bacteriaTrack(:,2)+L/2).*pxsize;
yLower = (bacteriaTrack(:,2)-L/2).*pxsize;

xShaded = [x; flip(x)];
yShaded = [yUpper; flip(yLower)];

shadedArea = fill(xShaded, yShaded,'g');
shadedArea.FaceColor = [0.5 0.5 0.5];
shadedArea.FaceAlpha = 0.25;
shadedArea.EdgeColor = [1. 1. 1.];

%-- Plot lines
hold on
bacteriaLine = plot(bacteriaTrack(:,1).*dt,(bacteriaTrack(:,2).*pxsize),'k-','LineWidth',1.5);
%bacteriaLine.Color(4) = 0.5;
if ~isempty(sprBTrack)
    sprBLines = cellfun(@(x,y) plot(x(:,1).*dt,(x(:,2).*pxsize),'LineWidth',1.5),sprBTrack);
    skipped = false;
else
    skipped = true;
end
daspect([1 1 1]);
ax = gca;
ax.Box = "off";
ax.FontName = 'Arial';
ax.FontSize = 15;
ax.LineWidth = 1.5;
ax.TickDir = 'out';
xlabel(ax,'Time (s)');
ylabel(ax, 'x (um)');

%-- Plot Position Difference
f1 = figure('WindowStyle','normal','Units','inches', 'Position', [3 3 5 5]);
hold on
%-- Shaded area
yShadedDiff = [yUpper-bacteriaTrack(:,2).*pxsize; flip(yLower-bacteriaTrack(:,2).*pxsize)];
shadedAreaDiff = fill(xShaded, yShadedDiff,'g');
shadedAreaDiff.FaceColor = [0.5 0.5 0.5];
shadedAreaDiff.FaceAlpha = 0.25;
shadedAreaDiff.EdgeColor = [1. 1. 1.];
plot(bacteriaTrack(:,1).*dt, zeros(size(bacteriaTrack(:,1))),'k--','LineWidth',1.5)

if ~isempty(sprBTrack)
    posDif = cellfun(@(x) findPositionDifference(bacteriaTrack(:,1:2),x(:,1:2)),sprBTrack,'UniformOutput',false);
    cellfun(@(x) plot(x(:,1).*dt,x(:,2).*pxsize,'LineWidth',1.5),posDif);
end
daspect([1 1 1]);
ax2 = gca;
ax2.Box = "off";
ax2.FontName = 'Arial';
ax2.FontSize = 15;
ax2.LineWidth = 1.5;
ax2.TickDir = 'out';
xlabel(ax2,'Time (s)');
ylabel(ax2, 'x_{C}-x_{M} (um)');

%-- Plot velocity difference, smoothed with sgolayfilt

f2 = figure('WindowStyle','normal','Units','inches', 'Position', [8 3 5 5]);
hold on

if ~isempty(sprBTrack)
    velDif = cellfun(@(x) [x(2:end,1).*dt diff(x(:,2).*pxsize)./dt], posDif, 'UniformOutput',false);
    velDifSmoothed = cellfun(@(x) [x(:,1) sgolayfilt(x(:,2),1,35)],velDif,'UniformOutput',false);
    velDifLines = cellfun(@(x) plot(x(:,1),x(:,2),'LineWidth',1.5), velDifSmoothed);
end
plot(bacteriaTrack(:,1).*dt, zeros(size(bacteriaTrack(:,1))),'k--','LineWidth',1.5)
daspect([1 1 1]);
ax3 = gca;
ax3.Box = "off";
ax3.FontName = 'Arial';
ax3.FontSize = 15;
ax3.LineWidth = 1.5;
ax3.TickDir = 'out';
xlabel(ax3,'Time (s)');
ylabel(ax3, 'v_{C}-v_{M} (um/s)');
ylim(ax3,[-2.5 +2.5])

if saveflag
    set(f,'Color','w');
    saveas(f, [datafolder 'horizontalProgressFigure.fig'])
    saveas(f, [datafolder 'horizontalProgressFigure.png'])
    %export_fig(f,[datafolder 'horizontalProgressFigure'], '-pdf','-png');
    close(f);

    set(f1,'Color','w');
    saveas(f1,[datafolder 'horizontalProgressDifferenceFigure.fig']);
    saveas(f1,[datafolder 'horizontalProgressDifferenceFigure.png']);

    %export_fig(f1, [datafolder 'horizontalProgressDifferenceFigure'],'-pdf','-png');
    close(f1);

    set(f2,'Color','w');
    saveas(f2,[datafolder 'horizontalVelocityDifferenceFigure.fig']);
    saveas(f2,[datafolder 'horizontalVelocityDifferenceFigure.png']);
    %export_fig(f2, [datafolder 'horizontalVelocityDifferenceFigure'],'-pdf','-png');
    close(f2);
end
end

function [xDifference] = findPositionDifference(bacteriaTrack,sprBTrack)
% Both tracks have an array [T Vx]
nPoints = size(sprBTrack,1);
xDifference = zeros(nPoints,2);
for i=1:nPoints
    idx = bacteriaTrack(:,1) == sprBTrack(i,1);
    if any(idx)
        xDifference(i,:) = [bacteriaTrack(idx,1) -bacteriaTrack(idx,2)+sprBTrack(i,2)];
    else
        xDifference(i,:) = [nan nan];
    end
end
end