function [histo,histoAxes,histoFigure] = makeHistogram(data,normalisationStyle,bins)
%MAKEHISTOGRAM Summary of this function goes here
%   Detailed explanation goes here
histoFigure = figure('Units','inches','Position',[1 1 4 4]);
if nargin<3
    histo = histogram(data,'Normalization',normalisationStyle);
else
    histo = histogram(data,bins,'Normalization',normalisationStyle);
end

histo.FaceColor = [0.14,0.67,0.85];
histo.EdgeColor = [0,0.,0.];
histo.FaceAlpha = 1;%;0.3;
histo.EdgeAlpha = 1;
histo.LineWidth = 1.5;

histoAxes = gca;
histoAxes.Box = "off";
histoAxes.FontName = 'Arial';
histoAxes.FontSize = 15;
histoAxes.LineWidth = 1.5;
histoAxes.TickDir = 'out';
pbaspect([1 1 1]);
% xlabel('V (um/s)')
ylabel(histoAxes,normalisationStyle);
end

