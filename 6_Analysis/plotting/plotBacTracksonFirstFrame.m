function plotBacTracksonFirstFrame(bacTracks,fluorimg, options)

if nargin<2
    options.cropField = [0 0 2496 2500];
    options.pixelsize = 67; %in nm
    options.cellspeedsmoothing = 1;
end

nCells = size(bacTracks,1);
width = options.cropField(3);
height = options.cropField(4);
xlim([0 width]);
ylim([0 height]);
figure;
ax = gca;

imshow(imadjust(fluorimg));

set(gca(),'YDir','reverse');

hold on

%if plot quivers usign theta
bacTracks = cellfun(@(x) interpolateTrack(x, true), bacTracks, 'UniformOutput',false);

for i = 1:nCells
    y = bacTracks{i}(:,3);
    x = bacTracks{i}(:,2);
    % 
    % Plot the line
    plot(x,y, 'LineWidth',2);

    %plot quivers
    % % currBac = bacTracks{i};
    % % vectors = getVectorsSmoothed(currBac, options);
    % % currBacPlusVectors = horzcat(currBac(:,2:3), vectors);
    % % % disp(currBacPlusVectors);
    % % for j = 1:(size(currBac,1)/options.cellspeedsmoothing - 1)
    % %     k = (j)*options.cellspeedsmoothing;
    % %     plotquivers(currBacPlusVectors(k,:),ax);
    % % end
    % % or plot quivers using theta
    % % quiver(ax, currBacFrame(:,2),currBacFrame(:,3), cos(currBacFrame(:,4))*10, sin(currBacFrame(:,4))*10);

    text(x(end), y(end), sprintf(' %d', i), ...
     'VerticalAlignment', 'middle', ...
     'FontSize', 10, ...
     'Color', 'b');
end