function exportReportWobble(datafolder)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Start by getting the folderlist
folderlist = getFoldersAndSubfolders(datafolder);

% and set-up the figure
f = figure;
f.Units = 'Inches';
f.Position = [0 0 8.27 11.69];

nFolders = length(folderlist);

tiledLay = tiledlayout(3,3);
tiledLay.TileSpacing = 'loose';
tiledLay.Padding = 'loose';
for i=1:nFolders
    nexttile;
    currentAx = gca;

    % Open figure
    figurePath = [datafolder folderlist{i} 'results\wobblePlot.fig'];
    tempFigure = openfig(figurePath);
    figure(tempFigure);
    tempAx = gca;
    propertiesToCopy = {'XLim','YLim','LineWidth','Color','Box','PlotBoxAspectRatio','XLabel','YLabel','TickDir'};
    copiedProperties = get(tempAx,propertiesToCopy);

    % Copy to currentAx
    figure(f);
    copyobj(tempAx.Children,currentAx);
    set(currentAx,propertiesToCopy,copiedProperties);
    drawnow()


    close(tempFigure);
    

    separatedString = split(folderlist{i},'\');
    titleString = separatedString{2};
    titleString = strrep(titleString,'_','');
    t = title(titleString);
    t.FontSize = 8;

    if mod(i,9)==0 || i == nFolders
        AxesH = axes('Units', 'Normalized', 'Position', [0,0,1,1], 'Visible', 'off','NextPlot', 'add');
        text(0.05, 0.99, [num2str(ceil(i/9)) '/' num2str(ceil(nFolders/9))], 'Parent', AxesH,'Units', 'normalized','VerticalAlignment', 'top', 'HorizontalAlignment', 'left');
        text(0.05, 0.05, ['Report generated on ' string(datetime)], 'Parent', AxesH,'Units', 'normalized','VerticalAlignment', 'top', 'HorizontalAlignment', 'left');
        set(f,'Color','w');
        export_fig(f,[datafolder 'reportWobble.pdf'],'-append','-nofontswap','-nocrop');
        clf
        tiledLay = tiledlayout(3,3);
        tiledLay.TileSpacing = 'loose';
        tiledLay.Padding = 'loose';
    end
end
close(f);
end
