function plotBacTrackssonFirstFrame(bacLoc,fluorimg, options)

nCells = size(bacLoc,1);
width = options.cropField(3);
height = options.cropField(4);
xlim([0 width]);
ylim([0 height]);
figure;
imshow(imadjust(fluorimg));
set(gca(),'YDir','reverse');
hold on

% colors = lines(nCells);  % Optional: get different colors for each line

for i = 1:nCells
    plotrectanglecell(bacLoc{i}, i);
end

end