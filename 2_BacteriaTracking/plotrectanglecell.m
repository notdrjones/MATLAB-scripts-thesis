function plotrectanglecell(currBac, i)

centroid_x = currBac(1,1);
centroid_y = currBac(1,2);
theta = currBac(1,3);
cell_len = currBac(1,4);
cell_width = currBac(1,5);

% disp(cell_len);
% disp(cell_width);
% disp(i);
% disp(theta);

[x1,y1] = rotatePoints((centroid_x-cell_len/2), (centroid_y-cell_width/2), deg2rad(theta), centroid_x, centroid_y);
[x2,y2] = rotatePoints((centroid_x-cell_len/2), (centroid_y+cell_width/2), deg2rad(theta), centroid_x, centroid_y);
[x4,y4] = rotatePoints((centroid_x+cell_len/2), (centroid_y-cell_width/2), deg2rad(theta), centroid_x, centroid_y);
[x3,y3] = rotatePoints((centroid_x+cell_len/2), (centroid_y+cell_width/2), deg2rad(theta), centroid_x, centroid_y);
boxpoints = vertcat([x1,y1],[x2,y2],[x3,y3],[x4,y4],[x1,y1]);

plot(boxpoints(:,1), boxpoints(:,2));

axis equal

text(x1, y1, sprintf(' %d', i), ...
     'VerticalAlignment', 'middle', ...
     'FontSize', 10, ...
     'Color', 'b');
end
