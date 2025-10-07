function [fociData] = wrapper_analysefociallcells(folderPath, options)

if nargin<2

    options.cropField = [1536 426 2484 2556];
    options.poleLen=0.5; % in um
    options.segmentwidth = 0.5; % in um
    options.nSegments = 10; 
    options.pixelsize = 67; %in nm
    options.cellpadding = 1; %in pixels
    options.normalisefluorescence = false;
    options.distfromedge = 10;
    options.minFluorescence = 40;
    options.useLandR = true;
end

[folderName, dirName, mainDataFolderPath, dataOutPath] = getFileNames(folderPath);
resultsfolder = [dataOutPath dirName folderName];
datafolder = [mainDataFolderPath dirName folderName];
bacTracks = importdata([resultsfolder 'allBacteriaTracks.mat']);

if options.useLandR == true
    LStack = loadtiff([datafolder 'L.tif']);
    RStack = loadtiff([datafolder 'R.tif']);
    fluorescenceStack = Lstack/2 + Rstack/2;
else
    fluorescenceStack = loadtiff([datafolder 'L.tif']);
end

[fociData] = analyseFociAllCells2(fluorescenceStack, bacTracks, options);

%for first frame, plot the trajectories of cells and their numbers on a
%graph for easy reference


C = bacTracks;
[nCells, ~] = size(C);
width = options.cropField(3);
height = options.cropField(4);
xlim([0 width]);
ylim([0 height]);
figure;
hold on

set(gca(),'YDir','reverse');

colors = lines(nCells);  % Optional: get different colors for each line

for i = 1:nCells
    y = C{i}(:,3);
    x = C{i}(:,2);
    
    % Plot the line
    h = plot(x,y);
    set(h, 'Color', colors(i,:));

    % Add a text label near the end of the line
    text(x(end), y(end), sprintf(' %d', i), ...
         'VerticalAlignment', 'middle', ...
         'FontSize', 10, ...
         'Color', colors(i,:));
end

% set(gca(),'YDir','reverse');

end