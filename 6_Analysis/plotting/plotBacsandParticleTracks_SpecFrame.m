function plotBacsandParticleTracks_SpecFrame(bacTracks,particleTracks, options)

if nargin<2
    options.frameno = 20;
    options.cropField = [0 0 2496 2500];
    options.pixelsize = 67; %in nm
end


bacTracks = cellfun(@(x) interpolateTrack(x, true), bacTracks, 'UniformOutput',false);
bacLoc = cellfun(@(x) x((find(x(:,1) == options.frameno)),2:6), bacTracks, 'UniformOutput',false);
empty_index = cellfun(@(x) isempty(x), bacLoc);
bacLoc(empty_index,:) = [];
nCells = size(bacLoc,1);

% disp(bacLoc);

width = options.cropField(3);
height = options.cropField(4);
xlim([0 width]);
ylim([0 height]);
figure;
hold on

set(gca(),'YDir','reverse');

% colors = lines(nCells);  % Optional: get different colors for each line

for i = 1:nCells
    plotrectanglecell(bacLoc{i}, i);
end

[nTracks, ~] = size(particleTracks);
colors = lines(nTracks);  % Optional: get different colors for each line

for i = 1:nTracks
    y = particleTracks{i}(:,3);
    x = particleTracks{i}(:,2);
    p_name = particleTracks{i}(1,5);
    % Plot the line
    h = plot(x,y);
    set(h, 'Color', colors(i,:));
    
    % Add a text label near the end of the line
    text(x(end), y(end), sprintf(' %d', p_name), ...
         'VerticalAlignment', 'middle', ...
         'FontSize', 10, ...
         'Color', colors(i,:));
    xpoint = particleTracks{i}(find(particleTracks{i}(:,1) == options.frameno), 2);
    ypoint = particleTracks{i}(find(particleTracks{i}(:,1) == options.frameno), 3);
    disp(xpoint);
    disp(ypoint);
    if ~isempty(xpoint) && ~isempty(ypoint)
        plot(xpoint, ypoint, '-*', 'Markersize', 10);
    end

end


end