function plotBacTracksandParticleTracks(bacTracks,particleTracks, options)

nCells = size(bacTracks,1);
width = options.cropField(3);
height = options.cropField(4);
xlim([0 width]);
ylim([0 height]);
figure;
hold on

set(gca(),'YDir','reverse');

% colors = lines(nCells);  % Optional: get different colors for each line

for i = 1:nCells
    y = bacTracks{i}(:,3);
    x = bacTracks{i}(:,2);

    % Plot the line
    h = plot(x,y);
    set(h, 'Color', 'b');

    % Add a text label near the end of the line
    text(x(end), y(end), sprintf(' %d', i), ...
         'VerticalAlignment', 'middle', ...
         'FontSize', 10, ...
         'Color', 'b');
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
end


end