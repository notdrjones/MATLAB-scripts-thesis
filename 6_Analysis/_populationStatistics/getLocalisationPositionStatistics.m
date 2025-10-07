function [outputArg1,outputArg2] = getLocalisationPositionStatistics(datafolder,saveflag)
%GETLOCALISATIONPOSITIONSTATISTICS Summary of this function goes here
%   Detailed explanation goes here
folderlist = getFoldersAndSubfolders(datafolder);
allPositions = cell(length(folderlist),1);

for i=1:length(folderlist)
    currentFilename = [datafolder folderlist{i} 'results\sprBPositionData.mat'];
    if exist(currentFilename,"file")
        currentData = importdata([datafolder folderlist{i} 'results\sprBPositionData.mat']);
        allPositions{i} = currentData;
    end
end

xNormalised = cell2mat(allPositions);

%-- Make and plot the histogram
histoFigure = figure;
histoFigure.Position = [1 1 400 400];
histo = histogram(xNormalised,linspace(-0.5,0.5,10),'Normalization','probability');
histoAxes = gca;
histo.FaceColor = [0.30,0.75,0.93];
histo.EdgeColor = [0,0.45,0.74];
histo.FaceAlpha = 0.3;
histo.EdgeAlpha = 1;
histo.LineWidth = 1.5;

histoAxes.Box = "off";
histoAxes.FontName = 'Arial';
histoAxes.FontSize = 15;
histoAxes.LineWidth = 1.5;
histoAxes.TickDir = 'out';
histoAxes.XLim = [-0.5 0.5];
pbaspect([1 1 1]);
xlabel('x/L_{CELL}');
ylabel('Probability');

if saveflag
    set(histoFigure,'Color','w');
    saveas(histoFigure,[datafolder 'localisationPositionStatistics.fig'])
    saveas(histoFigure,[datafolder 'localisationPositionStatistics.png'])
    exportgraphics(histoFigure,[datafolder 'localisationPositionStatistics.pdf'])
end
end

