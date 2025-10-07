function exportReportTheta(datafolder)
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

    % Open tack
    bacteriaTrackPath = [datafolder folderlist{i} 'bacteriaTrack.mat'];
    bacteriaTrack = importdata(bacteriaTrackPath);
    theta = bacteriaTrack(:,4);
    [thetaNew,thetaNewUnwrapped] = fixThetaWrapping(theta);

    % Copy to currentAx
    plt = plot(bacteriaTrack(:,1),thetaNew);%,bacteriaTrack(:,1),rad2deg(unwrap(deg2rad(bacteriaTrack(:,4)))));
    hold on
    
    plt2 = plot(bacteriaTrack(:,1),thetaNewUnwrapped);

    plt.LineWidth = 1;
    plt.Color = [0,0.45,0.74];
   

    currentAx = gca;
    currentAx.Box = "off";
    currentAx.YLim = [-Inf Inf];
    %currentAx.YTick = [-90 -45 0 45 90];
    currentAx.FontName = 'Arial';
    currentAx.FontSize = 15;
    currentAx.LineWidth = 1.5;
    currentAx.TickDir = 'out';
    pbaspect(currentAx,[1 1 1]);


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
        export_fig(f,[datafolder 'reportTheta.pdf'],'-append','-nofontswap','-nocrop');
        clf
        tiledLay = tiledlayout(3,3);
        tiledLay.TileSpacing = 'loose';
        tiledLay.Padding = 'loose';
    end
end
close(f);
end
