function plotProgressOverTime(datafolder,saveflag)
%PLOTPROGRESSOVERTIME Summary of this function goes here
%   Detailed explanation goes here
datafolder = [datafolder 'translatedAndRotated\'];
dt = 0.05;
pxsize = 0.11;

bacteriaTrack = importdata([datafolder 'bacteriaTrackHorizontal.mat']);
sprBTrack = importdata([datafolder 'SprBHorizontalTrack.mat']);

f = figure('Units','inches', 'Position', [1 1 5 5]);

bacteriaLine = plot(bacteriaTrack(:,1).*dt,(bacteriaTrack(:,2).*pxsize),'k-','LineWidth',1.5);
bacteriaLine.Color(4) = 0.5;

hold on
if ~isempty(sprBTrack)
    sprBLines = cellfun(@(x,y) plot(x(:,1).*dt,(x(:,2).*pxsize),'LineWidth',1.5),sprBTrack);
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

if saveflag
    saveas(f, [datafolder 'horizontalProgressFigure.fig'])
    export_fig(f,[datafolder 'horizontalProgressFigure'], '-pdf','-png');
    close(f);
end
end