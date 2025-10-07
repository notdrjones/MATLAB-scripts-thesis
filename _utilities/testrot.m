
function testrot(centroid_x, centroid_y, cell_len, cell_width, theta)

[x1,y1] = rotatePoints((centroid_x-cell_len/2), (centroid_y-cell_width/2), -theta, centroid_x, centroid_y);
[x2,y2] = rotatePoints((centroid_x-cell_len/2), (centroid_y+cell_width/2), -theta, centroid_x, centroid_y);
[x4,y4] = rotatePoints((centroid_x+cell_len/2), (centroid_y-cell_width/2), -theta, centroid_x, centroid_y);
[x3,y3] = rotatePoints((centroid_x+cell_len/2), (centroid_y+cell_width/2), -theta, centroid_x, centroid_y);
boxpoints = vertcat([x1,y1],[x2,y2],[x3,y3],[x4,y4],[x1,y1]);

p1 = [(centroid_x-cell_len/2)  (centroid_y-cell_width/2)];
p2 = [(centroid_x-cell_len/2)  (centroid_y+cell_width/2)];
p4 = [(centroid_x+cell_len/2)  (centroid_y-cell_width/2)];
p3 = [(centroid_x+cell_len/2)  (centroid_y+cell_width/2)];
boxpoints2 = vertcat(p1,p2,p3,p4,p1);

figure;
xlim([0,20]);
ylim([0,20]);
plot(boxpoints(:,1), boxpoints(:,2));
hold on
plot(boxpoints2(:,1), boxpoints2(:,2));
% xlim([0,20]);
% ylim([0,20]);


% pause(3);
% close;

end